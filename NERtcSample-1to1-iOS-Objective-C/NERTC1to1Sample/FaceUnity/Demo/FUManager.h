//
//  FUManager.h
//  FULiveDemo
//
//  Created by 刘洋 on 2017/8/18.
//  Copyright © 2017年 刘洋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <FURenderKit/FURenderKit.h>

@protocol FUManagerProtocol <NSObject>

//用于检测是否有ai人脸和人形
- (void)faceUnityManagerCheckAI;

@end

@interface FUManager : NSObject

@property (nonatomic, weak) id<FUManagerProtocol>delegate;

@property (nonatomic, assign, readonly) FUDevicePerformanceLevel devicePerformanceLevel;

/// 用于道具是否镜像
@property (nonatomic, assign) BOOL flipx;

+ (FUManager *)shareManager;

/// 初始化FURenderKit
- (void)setupRenderKit;

/// 销毁全部道具
- (void)destoryItems;

/// 切换前后摄像头
- (void)onCameraChange;

/// 更新美颜磨皮效果（根据人脸检测置信度设置不同磨皮效果）
- (void)updateBeautyBlurEffect;

/// 渲染接口
- (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
