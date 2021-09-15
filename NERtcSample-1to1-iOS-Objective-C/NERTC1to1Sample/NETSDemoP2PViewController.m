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
#import "FUManager.h"
#import "FUAPIDemoBar.h"
#import "FUCamera.h"

// 将性能写入csv文件
#import "FUTestRecorder.h"


@interface NETSDemoP2PViewController ()<NERtcEngineDelegateEx,FUAPIDemoBarDelegate,FUCameraDelegate>

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

/**faceu bar */
@property(nonatomic, strong) FUAPIDemoBar *demoBar;

///** 外部设备采集 */
//@property(nonatomic, strong) FUCamera *mCamera;


@end

@implementation NETSDemoP2PViewController

- (void)dealloc {
    
    [[FUManager shareManager] destoryItems];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NERtcEngine destroyEngine];
    });
    
}

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
    
    /** 初始化 Faceu */
    [self setupFaceUnity];
    
    
    //直接加入channel
    [self joinChannelWithRoomId:_roomId userId:_userId];
}

#pragma mark - Functions

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


#pragma mark -  FUAPIDemoBarDelegate

-(void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
}

-(void)switchRenderState:(BOOL)state{
    [FUManager shareManager].isRender = state;
}

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

#pragma mark -  Loading


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.mCamera startCapture];
//    [_mCamera changeSessionPreset:AVCaptureSessionPreset1280x720];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [self.mCamera resetFocusAndExposureModes];
//    [self.mCamera stopCapture];
//
//    /* 清一下信息，防止快速切换有人脸信息缓存 */
//    [[FUManager shareManager] onCameraChange];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
}

//-(FUCamera *)mCamera {
//    if (!_mCamera) {
//        _mCamera = [[FUCamera alloc] init];
//        _mCamera.delegate = self ;
//    }
//    return _mCamera ;
//}

//#pragma mark ----------FUCameraDelegate-----
//
//- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
//
//    [[FUTestRecorder shareRecorder] processFrameWithLog];
//    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
//
//    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
//    NERtcVideoFrame *videoFrame = [[NERtcVideoFrame alloc] init];
//    videoFrame.format = kNERtcVideoFormatNV12;
//    videoFrame.width = (uint32_t)CVPixelBufferGetWidth(pixelBuffer);
//    videoFrame.height = (uint32_t)CVPixelBufferGetHeight(pixelBuffer);
//    videoFrame.timestamp = 0;
//    videoFrame.buffer = (void *)pixelBuffer;
//    [[NERtcEngine sharedEngine] pushExternalVideoFrame:videoFrame];
//    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
//
//}

#pragma mark - Private

//初始化NERtcSDK
- (void)setupRTCEngine {
    // 默认情况下日志会存储在App沙盒的Documents目录下
    NERtcLogSetting *logSetting = [[NERtcLogSetting alloc] init];
#if DEBUG
    logSetting.logLevel = kNERtcLogLevelInfo;
#else
    logSetting.logLevel = kNERtcLogLevelWarning;
#endif
    
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.engineDelegate = self;
    context.appKey = AppKey;
    context.logSetting = logSetting;
    [[NERtcEngine sharedEngine] setupEngineWithContext:context];
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
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    
    // 1v1视频通话+美颜场景的视频推荐配置
    // 其他场景下请联系云信技术支持获取配置
    NERtcVideoEncodeConfiguration *config = [[NERtcVideoEncodeConfiguration alloc] init];
    config.width = 640;
    config.height = 360;
    config.frameRate = kNERtcVideoFrameRateFps15;
    [coreEngine setLocalVideoConfig:config];
    
    // 1v1视频通话+美颜场景的音频推荐配置
    // 其他场景下请联系云信技术支持获取配置
    [coreEngine setAudioProfile:kNERtcAudioProfileStandard
                       scenario:kNERtcAudioScenarioSpeech];
    
    NSDictionary *params = @{
        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户
    };
    [coreEngine setParameters:params];
    
    [coreEngine enableLocalAudio:YES];
    [coreEngine enableLocalVideo:YES];
    
    __weak typeof(self) weakSelf = self;
    [coreEngine joinChannelWithToken:@""
                         channelName:roomId
                               myUid:userId
                          completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
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
    [NERtcEngine.sharedEngine leaveChannel];
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
    [NERtcEngine.sharedEngine switchCamera];
    
//    sender.selected = !sender.selected;
//
//    [self.mCamera changeCameraInputDeviceisFront:!sender.selected];
//    [[FUManager shareManager] onCameraChange];
//    [FUManager shareManager].flipx = ![FUManager shareManager].flipx;
//    [FUManager shareManager].trackFlipx = ![FUManager shareManager].trackFlipx;
    
}

#pragma mark - NERtcSDK回调（含义请参考NERtcEngineDelegateEx定义）
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

- (void)onNERtcEngineVideoFrameCaptured:(CVPixelBufferRef)bufferRef rotation:(NERtcVideoRotationType)rotation {
    [[FUManager shareManager] renderItemsToPixelBuffer:bufferRef];
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
