//
//  NETSDemoP2PViewController.m
//  NERtcP2pSample
//
//  Created by NetEase on 2020/08/01.
//  Copyright (c) 2014-2020 NetEase, Inc. All rights reserved.
//  

#import "NETSDemoP2PViewController.h"
#import "NTESDemoUserModel.h"
#import <NERtcSDK/NERtcSDK.h>
#import "AppKey.h"

#import <Masonry/Masonry.h>

/** faceU */
#import "FUDemoManager.h"
#import <FURenderKit/FUCaptureCamera.h>

@interface NETSDemoP2PViewController ()<NERtcEngineDelegateEx,FUCaptureCameraDelegate>

//渲染视图控件，SDK需要通过设置渲染view来建立canvas
@property (weak, nonatomic) IBOutlet UIView *localRender;  //本地渲染视图
@property (weak, nonatomic) IBOutlet UIView *remoteRender; //远端渲染视图
@property (weak, nonatomic) IBOutlet UILabel *remoteStatLab;

//上个页面传过来的参数
@property (nonatomic, copy) NSString *roomId;  //房间ID
@property (nonatomic, assign) uint64_t userId; //本人uid

//Demo的 canvas 模型，包括uid 和 container, 用来建立sdk canvas
@property (nonatomic, strong) NTESDemoUserModel *localCanvas;  //本地
@property (nonatomic, strong) NTESDemoUserModel *remoteCanvas; //远端

/** 外部设备采集 */
@property(nonatomic, strong) FUCaptureCamera *mCamera;
@property(nonatomic, strong) FUDemoManager *demoManager;

@end

@implementation NETSDemoP2PViewController


+ (instancetype)instanceWithRoomId:(NSString *)roomId
                            userId:(uint64_t)userId {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    NETSDemoP2PViewController *ret = [storyBoard instantiateViewControllerWithIdentifier:@"NETSDemoP2PViewController"];
    ret.roomId = roomId;
    ret.userId = userId;
    
    //初始化SDK
    [ret setupRTCEngine];
    return ret;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.isuseFU) {
        
        // FaceUnity UI
        [FUDemoManager setupFUSDK];
        [[FUDemoManager shared] addDemoViewToView:self.view originY:CGRectGetHeight(self.view.bounds) - FUBottomBarHeight - FUSafaAreaBottomInsets() - 88];
    }
    
    //直接加入channel
    [self joinChannelWithRoomId:_roomId userId:_userId];
}

#pragma mark - Functions


#pragma mark ----NERtcEngineVideoFrameObserver

//- (void)onNERtcEngineVideoFrameCaptured:(CVPixelBufferRef)bufferRef rotation:(NERtcVideoRotationType)rotation{
//
//    if (self.isuseFU) {
//        [[FUManager shareManager] renderItemsToPixelBuffer:bufferRef];
//    }
//}


#pragma mark -  Loading


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.mCamera startCapture];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

#pragma mark ----- FaceUnity ----

- (FUCaptureCamera *)mCamera{

    if (_mCamera == nil) {

        _mCamera = [[FUCaptureCamera alloc] initWithCameraPosition:(AVCaptureDevicePositionFront) captureFormat:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
        _mCamera.delegate = self;
    }

    return _mCamera;
}

#pragma mark ----------FUCameraDelegate-----

- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer captureDevicePosition:(AVCaptureDevicePosition)position{
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (self.isuseFU) {
        
        if(fuIsLibraryInit()){
            [[FUDemoManager shared] checkAITrackedResult];
            if ([FUDemoManager shared].shouldRender) {
                [[FUTestRecorder shareRecorder] processFrameWithLog];
                [FUDemoManager updateBeautyBlurEffect];
                FURenderInput *input = [[FURenderInput alloc] init];
                input.renderConfig.imageOrientation = FUImageOrientationUP;
                input.pixelBuffer = pixelBuffer;
                input.renderConfig.readBackToPixelBuffer = YES;
                //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
                input.renderConfig.gravityEnable = YES;
                FURenderOutput *output = [[FURenderKit shareRenderKit] renderWithInput:input];
            }
        }
    }
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


//初始化SDK
- (void)setupRTCEngine {
    
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    
//    NSDictionary *params = @{
//        kNERtcKeyPublishSelfStreamEnabled: @YES,    // 打开推流
//        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户
//    };
//    [coreEngine setParameters:params];
    
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.engineDelegate = self;
    context.appKey = AppKey;
    [coreEngine setupEngineWithContext:context];
    [coreEngine setExternalVideoSource:YES isScreen:NO];
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
    NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
    config.maxProfile = kNERtcVideoProfileHD720P;
    config.cropMode = kNERtcVideoCropMode16_9;
    config.frameRate = kNERtcVideoFrameRateFps30;
    config.minFrameRate = 15; //视频最小帧率
    config.bitrate = 0; //视频编码码率
    config.minBitrate = 0; //视频编码最小码率
    config.degradationPreference = kNERtcDegradationBalanced; ;//带宽受限时的视频编码降级偏好
    [coreEngine setLocalVideoConfig:config];
}

//建立本地canvas模型
- (NERtcVideoCanvas *)setupLocalCanvas {
    _localCanvas = [[NTESDemoUserModel alloc] init];
    _localCanvas.uid = _userId;
    _localCanvas.renderContainer = self.localRender;
    return [_localCanvas setupCanvas];
}

//建立远端canvas模型
- (NERtcVideoCanvas *)setupRemoteCanvasWithUid:(uint64_t)uid {
    _remoteCanvas = [[NTESDemoUserModel alloc] init];
    _remoteCanvas.uid = uid;
    _remoteCanvas.renderContainer = self.remoteRender;
    return [_remoteCanvas setupCanvas];
}

//加入房间
- (void)joinChannelWithRoomId:(NSString *)roomId
                       userId:(uint64_t)userId {
    __weak typeof(self) weakSelf = self;
    
    [NERtcEngine.sharedEngine joinChannelWithToken:@"" channelName:roomId myUid:userId completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd, uint64_t uid) {
        if (error) {
            
            //加入失败了，弹框之后退出当前页面
            NSString *msg = [NSString stringWithFormat:@"join channel fail.code:%@", @(error.code)];
            [weakSelf showDismissAlert:msg];
        } else {
            
            //加入成功，建立本地canvas渲染本地视图
            NERtcVideoCanvas *canvas = [weakSelf setupLocalCanvas];
            [NERtcEngine.sharedEngine setupLocalVideoCanvas:canvas];
        }
    }];
}

#pragma mark - Actions
//UI 挂断按钮事件
- (IBAction)onHungupAction:(UIButton *)sender {
    
    [self.mCamera stopCapture];
    [NERtcEngine.sharedEngine leaveChannel];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        [NERtcEngine destroyEngine];
    });
    
    if (self.isuseFU) {
    
        [FUDemoManager destory];
    }
    [self dismiss];
}

//UI 关闭本地音频按钮事件
- (IBAction)onAudioMuteAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [NERtcEngine.sharedEngine enableLocalAudio:!sender.selected];
}

//UI 关闭本地视频按钮事件
- (IBAction)onVideoMuteAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [NERtcEngine.sharedEngine enableLocalVideo:!sender.selected];
}

//UI 切换摄像头按钮事件
- (IBAction)onSwitchCameraAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    [self.mCamera changeCameraInputDeviceisFront:!sender.selected];
    
//    [[NERtcEngine sharedEngine] switchCamera];
    
    if (self.isuseFU) {
//        [FUManager shareManager].flipx = ![FUManager shareManager].flipx;
        [FUDemoManager resetTrackedResult];
    }
}

#pragma mark - SDK回调（含义请参考NERtcEngineDelegateEx定义）
- (void)onNERtcEngineDidError:(NERtcError)errCode {
    NSString *msg = [NSString stringWithFormat:@"nertc engine did error.code:%@", @(errCode)];
    [self showDismissAlert:msg];
}

- (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID
                                  userName:(NSString *)userName {

    //如果已经setup了一个远端的canvas，则不需要再建立了
    if (_remoteCanvas != nil) {
        return;
    }
    
    //建立远端canvas，用来渲染远端画面
    NERtcVideoCanvas *canvas = [self setupRemoteCanvasWithUid:userID];
    [NERtcEngine.sharedEngine setupRemoteVideoCanvas:canvas
                                           forUserID:userID];
}

- (void)onNERtcEngineUserVideoDidStartWithUserID:(uint64_t)userID
                                    videoProfile:(NERtcVideoProfileType)profile {
    //如果已经订阅过远端视频流，则不需要再订阅了
    if (_remoteCanvas.subscribedVideo) {
        return;
    }
    
    //订阅远端视频流
    _remoteCanvas.subscribedVideo = YES;
    [NERtcEngine.sharedEngine subscribeRemoteVideo:YES
                                 forUserID:userID
                                streamType:kNERtcRemoteVideoStreamTypeHigh];
}

- (void)onNERtcEngineUserVideoDidStop:(uint64_t)userID {
    if (userID == _remoteCanvas.uid) {
        _remoteStatLab.hidden = YES;
    }
}

- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID
                                     reason:(NERtcSessionLeaveReason)reason {
    
    //如果远端的人离开了，重置远端模型和UI
    if (userID == _remoteCanvas.uid) {
        _remoteStatLab.hidden = NO;
        [_remoteCanvas resetCanvas];
        _remoteCanvas = nil;
    }
}

#pragma mark - Getter
//判断当前房间是否已经满员
- (BOOL)membersIsFull {
    return (_remoteCanvas != nil);
}

#pragma mark - Helper
- (void)showDismissAlert:(NSString *)msg {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"退出提示"
                                                                     message:msg
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"退出"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismiss];
    }];
    [alertVC addAction:sure];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
