# FUNIMDemo 快速接入文档

FUNIMDemo 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo/tree/dev) 面部跟踪和虚拟道具功能 和 网易云信视频通话2.0功能的 Demo。

本文是 FaceUnity SDK 快速对接自定义视频采集网易云信视频通话的导读说明，关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev) 云信音视频通话自定义视频采集请查看 [云信音视频2.0 自定义视频采集](http://dev.yunxin.163.com/docs/product/%E9%9F%B3%E8%A7%86%E9%A2%91%E9%80%9A%E8%AF%9D2.0/%E8%BF%9B%E9%98%B6%E5%8A%9F%E8%83%BD/%E8%A7%86%E9%A2%91%E7%AE%A1%E7%90%86/%E8%87%AA%E5%AE%9A%E4%B9%89%E8%A7%86%E9%A2%91%E9%87%87%E9%9B%86?#iOS)

## 快速集成方法

### 一、导入 SDK

将  FaceUnity  文件夹全部拖入工程中，NamaSDK所需依赖库为 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

- 备注: 上述NamaSDK 使用 Pods 管理 会自动添加依赖,运行在iOS11以下系统时,需要手动添加`CoreML.framework`,并在**TARGETS -> Build Phases-> Link Binary With Libraries**将`CoreML.framework`手动修改为可选**Optional**

### FaceUnity 模块简介

```C
-FUManager              //nama 业务类
-FUCamera               //视频采集类     
-authpack.h             //权限文件
+FUAPIDemoBar     //美颜工具条,可自定义
+item         //美妆贴纸 xx.bundel文件
```

### 二、加入展示 FaceUnity SDK 美颜贴纸效果的UI

1、在 `NETSDemoP2PViewController.m`中添加头文件，并创建页面属性

```C

/**faceU */
#import "FUManager.h"
#import "FUAPIDemoBar.h"

/** faceu bar */
@property(nonatomic, strong) FUAPIDemoBar *demoBar;

/**外部设备采集 */
@property(nonatomic, strong) FUCamera *mCamera;

```

2、初始化 UI，并遵循代理  FUAPIDemoBarDelegate ，实现代理方法 `bottomDidChange:` 切换贴纸 和 `filterValueChange:` 更新美颜参数。

```C
    _demoBar = [[FUAPIDemoBar alloc] init];
    _demoBar.mDelegate = self;
    [self.view addSubview:_demoBar];
    [_demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (@available(iOS 11.0, *)) {
           
            make.left.mas_equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.mas_equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom)
            .mas_offset(-100);
        
        } else {
        
            make.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-100);
        }

        make.height.mas_equalTo(195);
        
    }];

```

#### 切换贴纸

```C
// 切换贴纸
-(void)bottomDidChange:(int)index{
    if (index < 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeBeautify];
    }
    if (index == 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeStrick];
    }
    
    if (index == 4) {
        [[FUManager shareManager] setRenderType:FUDataTypeMakeup];
    }
    if (index == 5) {
        [[FUManager shareManager] setRenderType:FUDataTypebody];
    }
}

```

#### 更新美颜参数

```C
// 更新美颜参数    
- (void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
}
```

### 三、在 `viewDidLoad:` 中调用 `setupFaceUnity` 初始化 SDK  并将 demoBar 添加到页面上

```C
/// faceunity
- (void)setupFaceUnity{

    [[FUTestRecorder shareRecorder] setupRecord];
    
    [[FUManager shareManager] loadFilter];
    [FUManager shareManager].flipx = YES;
    [FUManager shareManager].trackFlipx = YES;
    [FUManager shareManager].isRender = YES;
    
    _demoBar = [[FUAPIDemoBar alloc] init];
    _demoBar.mDelegate = self;
    [self.view addSubview:_demoBar];
    [_demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (@available(iOS 11.0, *)) {
           
            make.left.mas_equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.mas_equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom)
            .mas_offset(-100);
        
        } else {
        
            make.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-100);
        }

        make.height.mas_equalTo(195);
        
    }];
    
}

```

### 四、获取视频数据输出

在 NETSDemoP2PViewController.m 的 FUCameraDelegate 的代理方法中获取视频数据

```objc

#pragma mark ----------FUCameraDelegate-----

- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    [[FUTestRecorder shareRecorder] processFrameWithLog];
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    NERtcVideoFrame *videoFrame = [[NERtcVideoFrame alloc] init];
    videoFrame.format = kNERtcVideoFormatNV12;
    videoFrame.width = (uint32_t)CVPixelBufferGetWidth(pixelBuffer);
    videoFrame.height = (uint32_t)CVPixelBufferGetHeight(pixelBuffer);
    videoFrame.timestamp = 0;
    videoFrame.buffer = (void *)pixelBuffer;
    [[NERtcEngine sharedEngine] pushExternalVideoFrame:videoFrame];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
}


```

### 五、销毁道具和切换摄像头

1 视图控制器生命周期结束时 `[[FUManager shareManager] destoryItems];`销毁道具。

2 切换摄像头需要调用 `[[FUManager shareManager] onCameraChange];`切换摄像头

### [云信采集美颜](http://dev.yunxin.163.com/docs/product/%E9%9F%B3%E8%A7%86%E9%A2%91%E9%80%9A%E8%AF%9D2.0/%E8%BF%9B%E9%98%B6%E5%8A%9F%E8%83%BD/%E8%A7%86%E9%A2%91%E7%AE%A1%E7%90%86/%E7%BE%8E%E9%A2%9C?#iOS)
### 关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)
