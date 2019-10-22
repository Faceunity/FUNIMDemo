# FUNIMDemo 快速接入文档

**编译时注意：由于网易SDK>100M,没有和demo一块提交。[下载sdk](https://netease.im/im-sdk-demo) 加入vendors目录**

FUNIMDemo 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo/tree/dev) 面部跟踪和虚拟道具功能 和 网易云信视频通话功能的 Demo。

本文是 FaceUnity SDK 快速对接网易云信的导读说明，关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)

## 快速集成方法

### 一、获取视频数据输出

1、在 NTESNetChatViewController.m  的 `- (void)doStartByCaller` 方法和 `-(void)response:(BOOL)accept`  中分别加入 `videoHanlde`Block 即可获取 发起视频通话的时候获取的视频数据，具体如下

```C
#pragma mark /**---- FaceUnity 获取视频数据 ----**/
    option.videoCaptureParam.videoHandler = ^(CMSampleBufferRef  _Nonnull sampleBuffer) {
        [wself responVideoCallWithBuffer:sampleBuffer ];
    };
#pragma mark /**---- FaceUnity 获取视频数据 ----**/





#pragma mark /**---- FaceUnity 获取视频数据 ----**/
    option.videoCaptureParam.videoHandler = ^(CMSampleBufferRef  _Nonnull sampleBuffer) {
        [wself responVideoCallWithBuffer:sampleBuffer ];
    };
#pragma mark /**---- FaceUnity 获取视频数据 ----**/
```

2、在 NTESNetChatViewController.h 声明 `processVideoCallWithBuffer:` 和 `responVideoCallWithBuffer` 方法用于接收视频数据，这两个方法为空方法，用于子类重写。

```C
#pragma mark /**---- 子类重写，在此加入 FaceUnity 效果 ----**/
// 发起通话
- (void)processVideoCallWithBuffer:(CMSampleBufferRef)sampleBuffer ;
// 接听通话
- (void)responVideoCallWithBuffer:(CMSampleBufferRef)sampleBuffer ;
#pragma mark /**---- 子类重写，在此加入 FaceUnity 效果 ----**/
```

### 二、导入 SDK

将 FaceUnity 文件夹全部拖入工程中，并且添加依赖库 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`stdc++.tbd`

### 三、快速加载道具

在 NTESVideoChatViewController.m 的 `viewWillAppear:` 方法中调用快速加载道具函数，该函数会创建一个美颜道具及指定的贴纸道具。

```c
[[FUManager shareManager] loadItems];
```

注：FUManager 的 shareManager 函数中会对 SDK 进行初始化，并设置默认的美颜参数。

### 四、图像处理

在 NTESVideoChatViewController.m 中重写 `processVideoCallWithBuffer:` 和 `responVideoCallWithBuffer:` 方法，在其中处理图像，并将处理完成的图像发送给网易云信SDK。

```c

#pragma mark /**---- 子类重写，在此加入 FaceUnity 效果 ----**/
// 发起通话
- (void)processVideoCallWithBuffer:(CMSampleBufferRef)sampleBuffer {
    [super processVideoCallWithBuffer:sampleBuffer];
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    
    [[NIMAVChatSDK sharedSDK].netCallManager sendVideoSampleBuffer:sampleBuffer];
}
// 接听通话
- (void)responVideoCallWithBuffer:(CMSampleBufferRef)sampleBuffer {
    [super responVideoCallWithBuffer:sampleBuffer];
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    
    [[NIMAVChatSDK sharedSDK].netCallManager sendVideoSampleBuffer:sampleBuffer];
}
#pragma mark /**---- 子类重写，在此加入 FaceUnity 效果 ----**/
```

### 五、切换道具及调整美颜参数

本例中通过添加 FUAPIDemoBar 来实现切换道具及调整美颜参数的具体实现，FUAPIDemoBar 是快速集成用的UI，客户可自定义UI。

在 NTESVideoChatViewController.m 中添加 demoBar 属性，并实现 demoBar 代理方法，以进一步实现道具的切换及美颜参数的调整。

```C
// demoBar 初始化
-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 164 - 166, self.view.frame.size.width, 164)];
        
        _demoBar.itemsDataSource = [FUManager shareManager].itemsDataSource;
        _demoBar.selectedItem = [FUManager shareManager].selectedItem ;
        
        _demoBar.filtersDataSource = [FUManager shareManager].filtersDataSource ;
        _demoBar.beautyFiltersDataSource = [FUManager shareManager].beautyFiltersDataSource ;
        _demoBar.filtersCHName = [FUManager shareManager].filtersCHName ;
        _demoBar.selectedFilter = [FUManager shareManager].selectedFilter ;
        [_demoBar setFilterLevel:[FUManager shareManager].selectedFilterLevel forFilter:[FUManager shareManager].selectedFilter] ;
        
        _demoBar.skinDetectEnable = [FUManager shareManager].skinDetectEnable;
        _demoBar.blurShape = [FUManager shareManager].blurShape ;
        _demoBar.blurLevel = [FUManager shareManager].blurLevel ;
        _demoBar.whiteLevel = [FUManager shareManager].whiteLevel ;
        _demoBar.redLevel = [FUManager shareManager].redLevel;
        _demoBar.eyelightingLevel = [FUManager shareManager].eyelightingLevel ;
        _demoBar.beautyToothLevel = [FUManager shareManager].beautyToothLevel ;
        _demoBar.faceShape = [FUManager shareManager].faceShape ;
        
        _demoBar.enlargingLevel = [FUManager shareManager].enlargingLevel ;
        _demoBar.thinningLevel = [FUManager shareManager].thinningLevel ;
        _demoBar.enlargingLevel_new = [FUManager shareManager].enlargingLevel_new ;
        _demoBar.thinningLevel_new = [FUManager shareManager].thinningLevel_new ;
        _demoBar.jewLevel = [FUManager shareManager].jewLevel ;
        _demoBar.foreheadLevel = [FUManager shareManager].foreheadLevel ;
        _demoBar.noseLevel = [FUManager shareManager].noseLevel ;
        _demoBar.mouthLevel = [FUManager shareManager].mouthLevel ;
        
        _demoBar.delegate = self;
    }
    return _demoBar ;
}

/**      FUAPIDemoBarDelegate       **/

// 切换贴纸
- (void)demoBarDidSelectedItem:(NSString *)itemName {
    
    [[FUManager shareManager] loadItem:itemName];
}

// 更新美颜参数
- (void)demoBarBeautyParamChanged {
    
    [FUManager shareManager].skinDetectEnable = _demoBar.skinDetectEnable;
    [FUManager shareManager].blurShape = _demoBar.blurShape;
    [FUManager shareManager].blurLevel = _demoBar.blurLevel ;
    [FUManager shareManager].whiteLevel = _demoBar.whiteLevel;
    [FUManager shareManager].redLevel = _demoBar.redLevel;
    [FUManager shareManager].eyelightingLevel = _demoBar.eyelightingLevel;
    [FUManager shareManager].beautyToothLevel = _demoBar.beautyToothLevel;
    [FUManager shareManager].faceShape = _demoBar.faceShape;
    [FUManager shareManager].enlargingLevel = _demoBar.enlargingLevel;
    [FUManager shareManager].thinningLevel = _demoBar.thinningLevel;
    [FUManager shareManager].enlargingLevel_new = _demoBar.enlargingLevel_new;
    [FUManager shareManager].thinningLevel_new = _demoBar.thinningLevel_new;
    [FUManager shareManager].jewLevel = _demoBar.jewLevel;
    [FUManager shareManager].foreheadLevel = _demoBar.foreheadLevel;
    [FUManager shareManager].noseLevel = _demoBar.noseLevel;
    [FUManager shareManager].mouthLevel = _demoBar.mouthLevel;
    
    [FUManager shareManager].selectedFilter = _demoBar.selectedFilter ;
    [FUManager shareManager].selectedFilterLevel = _demoBar.selectedFilterLevel;
}
```



### 五、道具销毁

通话结束时结束时需要调用 `[[FUManager shareManager] destoryItems]`  销毁道具。

**快速集成完毕，关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)**