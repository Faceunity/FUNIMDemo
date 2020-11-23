//
//  NEYUVConverter.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/7/19.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "NEYUVConverter.h"
#import "libyuv.h"

@implementation NEYUVConverter

+ (CVPixelBufferRef)i420FrameToPixelBuffer:(void *)i420Frame width:(int)frameWidth height:(int)frameHeight
{
    
    int width = frameWidth;
    int height = frameHeight;
    
    if (i420Frame == nil) {
        return NULL;
    }
    
    CVPixelBufferRef pixelBuffer = NULL;
    
    
    NSDictionary *pixelBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSDictionary dictionary], (id)kCVPixelBufferIOSurfacePropertiesKey,
                                           nil];
    
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                          width,
                                          height,
                                          kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                                          (__bridge CFDictionaryRef)pixelBufferAttributes,
                                          &pixelBuffer);
    
    if (result != kCVReturnSuccess) {
        NSLog(@"Failed to create pixel buffer: %d", result);
        return NULL;
    }
    
    
    
    result = CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    if (result != kCVReturnSuccess) {
        CFRelease(pixelBuffer);
        NSLog(@"Failed to lock base address: %d", result);
        return NULL;
    }
    
    
    uint8 *dstY = (uint8 *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    int dstStrideY = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    uint8* dstUV = (uint8*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    int dstStrideUV = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);

    const uint8 *src_y = (uint8 *)i420Frame;
    const uint8 *src_u = src_y + width * height;
    const uint8 *src_v = src_u + width * height / 4;
    
    int src_stride_y = width;
    int src_stride_u = width >> 1;
    int src_stride_v = width >> 1;
    
    int ret = libyuv::I420ToNV12(src_y, src_stride_y, src_u, src_stride_u, src_v, src_stride_v, dstY, dstStrideY, dstUV, dstStrideUV, width, height);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    

    if (ret) {
        NSLog(@"Error converting I420 VideoFrame to NV12: %d", result);
        CFRelease(pixelBuffer);
        return NULL;
    }

    
    return pixelBuffer;
}


+ (CMSampleBufferRef)pixelBufferToSampleBuffer:(CVPixelBufferRef)pixelBuffer
{
    CMSampleBufferRef sampleBuffer;
    CMTime frameTime = CMTimeMakeWithSeconds([[NSDate date] timeIntervalSince1970], 1000000000);
    CMSampleTimingInfo timing = {frameTime, frameTime, kCMTimeInvalid};
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    
    OSStatus status = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    if (status != noErr) {
        NSLog(@"Failed to create sample buffer with error %d.", (int)status);
    }
    
    CVPixelBufferRelease(pixelBuffer);
    if(videoInfo)
        CFRelease(videoInfo);
    
    return sampleBuffer;
}

@end
