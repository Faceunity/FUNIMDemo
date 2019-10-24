//
//  NTESVideoChatViewController.m
//  NIM
//
//  Created by chris on 15/5/5.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESVideoChatViewController.h"
#import "UIView+Toast.h"
#import "NTESTimerHolder.h"
#import "NTESAudioChatViewController.h"
#import "NTESMainTabController.h"
#import "NTESNetCallChatInfo.h"
#import "NTESSessionUtil.h"
#import "NTESVideoChatNetStatusView.h"
#import "NTESGLView.h"
#import "NTESBundleSetting.h"
#import "NTESRecordSelectView.h"
#import "UIView+NTES.h"

#import "FUManager.h"
#import <FUAPIDemoBar/FUAPIDemoBar.h>

#define NTESUseGLView

@interface NTESVideoChatViewController ()
@property (nonatomic,assign) NIMNetCallCamera cameraType;

@property (nonatomic,strong) CALayer *localVideoLayer;

@property (nonatomic,assign) BOOL oppositeCloseVideo;

#if defined (NTESUseGLView)
@property (nonatomic, strong) NTESGLView *remoteGLView;
#endif

@property (nonatomic,weak) UIView   *localView;

@property (nonatomic,weak) UIView   *localPreView;


@property (nonatomic, assign) BOOL calleeBasy;


@property (nonatomic, strong) FUAPIDemoBar *demoBar ;
@end

@implementation NTESVideoChatViewController




#pragma mark /**---- 子类重写，在此加入 FaceUnity 效果 ----**/
// 发起通话
- (void)processVideoCallWithBuffer:(CMSampleBufferRef)sampleBuffer {
    [super processVideoCallWithBuffer:sampleBuffer];
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    
    [[NIMAVChatSDK sharedSDK].netCallManager sendVideoSampleBuffer:sampleBuffer];
    
    NSLog(@"--- 111");
}
// 接听通话
- (void)responVideoCallWithBuffer:(CMSampleBufferRef)sampleBuffer {
    [super responVideoCallWithBuffer:sampleBuffer];
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [[FUManager shareManager] renderItemsToPixelBuffer:pixelBuffer];
    
    [[NIMAVChatSDK sharedSDK].netCallManager sendVideoSampleBuffer:sampleBuffer];
}
#pragma mark /**---- 子类重写，在此加入 FaceUnity 效果 ----**/



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[FUManager shareManager] loadItems];
    [self.view addSubview:self.demoBar];
}

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
- (void)demoBarDidSelectedItem:(NSString *)itemName {
    
    [[FUManager shareManager] loadItem:itemName];
}

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

-(void)dealloc {
    
    /**     -----  FaceUnity  ----     **/
    [[FUManager shareManager] destoryItems];
    /**     -----  FaceUnity  ----     **/
}





- (instancetype)initWithCallInfo:(NTESNetCallChatInfo *)callInfo
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.callInfo = callInfo;
        self.callInfo.isMute = NO;
        self.callInfo.useSpeaker = NO;
        self.callInfo.disableCammera = NO;
        if (!self.localPreView) {
            //没有的话，尝试去取一把预览层（从视频切到语音再切回来的情况下是会有的）
            self.localPreView = [NIMAVChatSDK sharedSDK].netCallManager.localPreview;
        }
        [[NIMAVChatSDK sharedSDK].netCallManager switchType:NIMNetCallMediaTypeVideo];
        
        [[NIMAVChatSDK sharedSDK].netCallManager switchVideoQuality:NIMNetCallVideoQuality480pLevel];
        
        [[NIMAVChatSDK sharedSDK].netCallManager setSmoothFilterIntensity:0];
        [[NIMAVChatSDK sharedSDK].netCallManager selectBeautifyType:0];
    }
    return self;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.callInfo.callType = NIMNetCallTypeVideo;
        _cameraType = [[NTESBundleSetting sharedConfig] startWithBackCamera] ? NIMNetCallCameraBack :NIMNetCallCameraFront;
    }
    return self;
}

- (void)viewDidLoad {
    self.localView = self.smallVideoView;
    [super viewDidLoad];
    
    if (self.localPreView) {
        self.localPreView.frame = self.localView.bounds;
        [self.localView addSubview:self.localPreView];
    }
    
    [self initUI];
}

- (void)initUI
{
    self.localRecordingView.layer.cornerRadius = 10.0;
    self.localRecordingRedPoint.layer.cornerRadius = 4.0;
    self.lowMemoryView.layer.cornerRadius = 10.0;
    self.lowMemoryRedPoint.layer.cornerRadius = 4.0;
    self.refuseBtn.exclusiveTouch = YES;
    self.acceptBtn.exclusiveTouch = YES;
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [self initRemoteGLView];
    }
}

- (void)initRemoteGLView {
#if defined (NTESUseGLView)
    _remoteGLView = [[NTESGLView alloc] initWithFrame:_bigVideoView.bounds];
    [_remoteGLView setContentMode:[[NTESBundleSetting sharedConfig] videochatRemoteVideoContentMode]];
    [_remoteGLView setBackgroundColor:[UIColor clearColor]];
    _remoteGLView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_bigVideoView addSubview:_remoteGLView];
#endif
}


#pragma mark - Call Life
- (void)startByCaller{
    [super startByCaller];
    [self startInterface];
}

- (void)startByCallee{
    [super startByCallee];
    [self waitToCallInterface];
}
- (void)onCalling{
    [super onCalling];
    [self videoCallingInterface];
}

- (void)waitForConnectiong{
    [super waitForConnectiong];
    [self connectingInterface];
}

- (void)onCalleeBusy
{
    _calleeBasy = YES;
    if (_localPreView)
    {
        [_localPreView removeFromSuperview];
    }
}

#pragma mark - Interface
//正在接听中界面
- (void)startInterface{
    self.acceptBtn.hidden = YES;
    self.refuseBtn.hidden   = YES;
    self.hungUpBtn.hidden   = NO;
    self.connectingLabel.hidden = NO;
    self.connectingLabel.text = @"正在呼叫，请稍候...";
    self.switchModelBtn.hidden = YES;
    self.switchCameraBtn.hidden = NO;
    self.muteBtn.hidden = NO;
    self.disableCameraBtn.hidden = NO;
    self.localRecordBtn.hidden = NO;
    self.muteBtn.enabled = NO;
    self.disableCameraBtn.enabled = NO;
    self.localRecordBtn.enabled = NO;
    
    self.localRecordingView.hidden = YES;
    self.lowMemoryView.hidden = YES;
    [self.hungUpBtn removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.hungUpBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
    self.localView = self.bigVideoView;
}

//选择是否接听界面
- (void)waitToCallInterface{
    self.acceptBtn.hidden = NO;
    self.refuseBtn.hidden   = NO;
    self.hungUpBtn.hidden   = YES;
    NSString *nick = [NTESSessionUtil showNick:self.callInfo.caller inSession:nil];
    self.connectingLabel.text = [nick stringByAppendingString:@"的来电"];
    self.muteBtn.hidden = YES;
    self.switchCameraBtn.hidden = YES;
    self.disableCameraBtn.hidden = YES;
    self.localRecordBtn.hidden = YES;
    self.localRecordingView.hidden = YES;
    self.lowMemoryView.hidden = YES;
    self.switchModelBtn.hidden = YES;
}

//连接对方界面
- (void)connectingInterface{
    self.acceptBtn.hidden = YES;
    self.refuseBtn.hidden   = YES;
    self.hungUpBtn.hidden   = NO;
    self.connectingLabel.hidden = NO;
    self.connectingLabel.text = @"正在连接对方...请稍后...";
    self.switchModelBtn.hidden = YES;
    self.switchCameraBtn.hidden = YES;
    self.muteBtn.hidden = YES;
    self.disableCameraBtn.hidden = YES;
    self.localRecordBtn.hidden = YES;
    self.localRecordingView.hidden = YES;
    self.lowMemoryView.hidden = YES;
    [self.hungUpBtn removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.hungUpBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
}

//接听中界面(视频)
- (void)videoCallingInterface{
    
    NIMNetCallNetStatus status = [[NIMAVChatSDK sharedSDK].netCallManager netStatus:self.peerUid];
    [self.netStatusView refreshWithNetState:status];
    self.acceptBtn.hidden = YES;
    self.refuseBtn.hidden   = YES;
    self.hungUpBtn.hidden   = NO;
    self.connectingLabel.hidden = YES;
    self.muteBtn.hidden = NO;
    self.switchCameraBtn.hidden = NO;
    self.disableCameraBtn.hidden = NO;
    self.localRecordBtn.hidden = NO;
    self.switchModelBtn.hidden = NO;
    
    self.muteBtn.enabled = YES;
    self.disableCameraBtn.enabled = YES;
    self.localRecordBtn.enabled = YES;
    
    self.muteBtn.selected = self.callInfo.isMute;
    self.disableCameraBtn.selected = self.callInfo.disableCammera;
    self.localRecordBtn.selected = ![self allRecordsStopped];
;
    self.localRecordingView.hidden = [self allRecordsStopped];
;
    self.lowMemoryView.hidden = YES;
    [self.switchModelBtn setTitle:@"语音模式" forState:UIControlStateNormal];
    [self.hungUpBtn removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.hungUpBtn addTarget:self action:@selector(hangup) forControlEvents:UIControlEventTouchUpInside];
//    self.localVideoLayer.hidden = NO;
    self.localPreView.hidden = NO;
}

//切换接听中界面(语音)
- (void)audioCallingInterface{
    
    NTESAudioChatViewController *vc = [[NTESAudioChatViewController alloc] initWithCallInfo:self.callInfo];
    [UIView  beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    [self.navigationController pushViewController:vc animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
    NSMutableArray * vcs = [self.navigationController.viewControllers mutableCopy];
    [vcs removeObject:self];
    self.navigationController.viewControllers = vcs;
}

- (void)udpateLowSpaceWarning:(BOOL)show {
    self.lowMemoryView.hidden = !show;
    self.localRecordingView.hidden = show;
}


#pragma mark - IBAction

- (IBAction)acceptToCall:(id)sender{
    BOOL accept = (sender == self.acceptBtn);
    //防止用户在点了接收后又点拒绝的情况
    [self response:accept];
}

- (IBAction)mute:(BOOL)sender{
    self.callInfo.isMute = !self.callInfo.isMute;
    self.player.volume = !self.callInfo.isMute;
    [[NIMAVChatSDK sharedSDK].netCallManager setMute:self.callInfo.isMute];
    self.muteBtn.selected = self.callInfo.isMute;
}

- (IBAction)switchCamera:(id)sender{
    if (self.cameraType == NIMNetCallCameraFront) {
        self.cameraType = NIMNetCallCameraBack;
    }else{
        self.cameraType = NIMNetCallCameraFront;
    }
    [[NIMAVChatSDK sharedSDK].netCallManager switchCamera:self.cameraType];
    self.switchCameraBtn.selected = (self.cameraType == NIMNetCallCameraBack);
}


- (IBAction)disableCammera:(id)sender{
    self.callInfo.disableCammera = !self.callInfo.disableCammera;
    [[NIMAVChatSDK sharedSDK].netCallManager setCameraDisable:self.callInfo.disableCammera];
    self.disableCameraBtn.selected = self.callInfo.disableCammera;
    if (self.callInfo.disableCammera) {
        [self.localPreView removeFromSuperview];
        [[NIMAVChatSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeCloseVideo];
    }else{
        [self.localView addSubview:self.localPreView];

        [[NIMAVChatSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeOpenVideo];
    }
}

- (IBAction)localRecord:(id)sender {
    //出现录制选择框
    if ([self allRecordsStopped]) {
        [self showRecordSelectView:YES];
    }
    //同时停止所有录制
    else
    {
        //结束语音对话
        if (self.callInfo.audioConversation) {
            [self stopAudioRecording];
            if([self allRecordsStopped])
            {
                self.localRecordBtn.selected = NO;
                self.localRecordingView.hidden = YES;
                self.lowMemoryView.hidden = YES;
            }
        }
        [self stopRecordTaskWithVideo:YES];
    }

}


- (IBAction)switchCallingModel:(id)sender{
    [[NIMAVChatSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeToAudio];
    [self switchToAudio];
}

- (IBAction)swichPetsiton:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [[NIMAVChatSDK sharedSDK].netCallManager switchVideoQuality:NIMNetCallVideoQuality480pLevel];
    }else{
        [[NIMAVChatSDK sharedSDK].netCallManager switchVideoQuality:NIMNetCallVideoQuality720pLevel];
    }
}

#pragma mark - NTESRecordSelectViewDelegate

-(void)onRecordWithAudioConversation:(BOOL)audioConversationOn myMedia:(BOOL)myMediaOn otherSideMedia:(BOOL)otherSideMediaOn
{
    if (audioConversationOn) {
        //开始语音对话
        if ([self startAudioRecording]) {
            self.callInfo.audioConversation = YES;
            self.localRecordBtn.selected = YES;
            self.localRecordingView.hidden = NO;
            self.lowMemoryView.hidden = YES;
        }
    }
    [self recordWithAudioConversation:audioConversationOn myMedia:myMediaOn otherSideMedia:otherSideMediaOn video:YES];
}


#pragma mark - NIMNetCallManagerDelegate
- (void)onLocalDisplayviewReady:(UIView *)displayView
{
    if (_calleeBasy) {
        return;
    }
    
    if (self.localPreView) {
        [self.localPreView removeFromSuperview];
    }
    
    self.localPreView = displayView;
    displayView.frame = self.localView.bounds;

    [self.localView addSubview:displayView];
}

#if defined(NTESUseGLView)
- (void)onRemoteYUVReady:(NSData *)yuvData
                   width:(NSUInteger)width
                  height:(NSUInteger)height
                    from:(NSString *)user
{
    if (([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) && !self.oppositeCloseVideo) {
        
        if (!_remoteGLView) {
            [self initRemoteGLView];
        }
        [_remoteGLView render:yuvData width:width height:height];
    }
}
#else
- (void)onRemoteImageReady:(CGImageRef)image{
    if (self.oppositeCloseVideo) {
        return;
    }
    self.bigVideoView.contentMode = UIViewContentModeScaleAspectFill;
    self.bigVideoView.image = [UIImage imageWithCGImage:image];
}
#endif

- (void)onControl:(UInt64)callID
             from:(NSString *)user
             type:(NIMNetCallControlType)control{
    [super onControl:callID from:user type:control];
    switch (control) {
        case NIMNetCallControlTypeToAudio:
            [self switchToAudio];
            break;
        case NIMNetCallControlTypeCloseVideo:
            [self resetRemoteImage];
            self.oppositeCloseVideo = YES;
            [self.view makeToast:@"对方关闭了摄像头"
                        duration:2
                        position:CSToastPositionCenter];
            break;
        case NIMNetCallControlTypeOpenVideo:
            self.oppositeCloseVideo = NO;
            [self.view makeToast:@"对方开启了摄像头"
                        duration:2
                        position:CSToastPositionCenter];
            break;
        default:
            break;
    }
}


-(void)onCallEstablished:(UInt64)callID
{
    if (self.callInfo.callID == callID) {
        [super onCallEstablished:callID];
        
        self.durationLabel.hidden = NO;
        self.durationLabel.text = self.durationDesc;
        
        if (self.localView == self.bigVideoView) {
            self.localView = self.smallVideoView;
            
            if (self.localPreView) {
                [self onLocalDisplayviewReady:self.localPreView];
            }
        }
    }
}

- (void)onNetStatus:(NIMNetCallNetStatus)status user:(NSString *)user
{
    if ([user isEqualToString:self.peerUid]) {
        [self.netStatusView refreshWithNetState:status];
    }
}


- (void)onRecordStarted:(UInt64)callID fileURL:(NSURL *)fileURL                          uid:(NSString *)userId
{
    [super onRecordStarted:callID fileURL:fileURL uid:userId];
    if (self.callInfo.callID == callID) {
        self.localRecordBtn.selected = YES;
        self.localRecordingView.hidden = NO;
        self.lowMemoryView.hidden = YES;
    }
}


- (void)onRecordError:(NSError *)error
                    callID:(UInt64)callID
                       uid:(NSString *)userId;

{
    [super onRecordError:error callID:callID uid:userId];
    if (self.callInfo.callID == callID) {
        //判断是否全部结束
        if([self allRecordsStopped])
        {
            self.localRecordBtn.selected = NO;
            self.localRecordingView.hidden = YES;
            self.lowMemoryView.hidden = YES;
        }
    }
}

- (void) onRecordStopped:(UInt64)callID
                      fileURL:(NSURL *)fileURL
                          uid:(NSString *)userId;

{
    [super onRecordStopped:callID fileURL:fileURL uid:userId];
    if (self.callInfo.callID == callID) {
        if([self allRecordsStopped])
        {
            self.localRecordBtn.selected = NO;
            self.localRecordingView.hidden = YES;
            self.lowMemoryView.hidden = YES;
        }
    }
}

#pragma mark - M80TimerHolderDelegate

- (void)onNTESTimerFired:(NTESTimerHolder *)holder{
    [super onNTESTimerFired:holder];
    self.durationLabel.text = self.durationDesc;
}

#pragma mark - Misc
- (void)switchToAudio{
    [self audioCallingInterface];
}

- (NSString*)durationDesc{
    if (!self.callInfo.startTime) {
        return @"";
    }
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    NSTimeInterval duration = time - self.callInfo.startTime;
    return [NSString stringWithFormat:@"%02d:%02d",(int)duration/60,(int)duration%60];
}

- (void)resetRemoteImage{
#if defined (NTESUseGLView)
    [self.remoteGLView render:nil width:0 height:0];
#endif

    self.bigVideoView.image = [UIImage imageNamed:@"netcall_bkg.png"];
}

@end
