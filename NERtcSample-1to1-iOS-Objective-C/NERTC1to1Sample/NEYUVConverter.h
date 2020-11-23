//
//  NEYUVConverter.h
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2017/7/19.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMSampleBuffer.h>

typedef NS_ENUM(NSUInteger, NEI420FramePlane) {
    NEI420FramePlaneY = 0,
    NEI420FramePlaneU = 1,
    NEI420FramePlaneV = 2,
};

@interface NEYUVConverter : NSObject

+ (CVPixelBufferRef)i420FrameToPixelBuffer:(void *)i420Frame width:(int)frameWidth height:(int)frameHeight;

+ (CMSampleBufferRef)pixelBufferToSampleBuffer:(CVPixelBufferRef)pixelBuffer;

@end
