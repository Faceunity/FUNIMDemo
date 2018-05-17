//
//  NTESBundleSetting.m
//  NIM
//
//  Created by chris on 15/7/1.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NTESBundleSetting.h"

@implementation NTESBundleSetting

+ (instancetype)sharedConfig
{
    static NTESBundleSetting *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESBundleSetting alloc] init];
    });
    return instance;
}


- (BOOL)removeSessionWhenDeleteMessages{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled_remove_recent_session"] boolValue];
}

- (BOOL)dropTableWhenDeleteMessages
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled_drop_msg_table"] boolValue];
    
}

- (BOOL)localSearchOrderByTimeDesc{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"local_search_time_order_desc"] boolValue];
}


- (BOOL)autoRemoveRemoteSession{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"auto_remove_remote_session"] boolValue];
}

- (BOOL)autoRemoveSnapMessage{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"auto_remove_snap_message"] boolValue];
}

- (BOOL)needVerifyForFriend
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"add_friend_need_verify"] boolValue];
}

- (BOOL)showFps{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"show_fps_for_app"] boolValue];
}

- (BOOL)disableProximityMonitor
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"disable_proxmity_monitor"] boolValue];
}


- (BOOL)animatedImageThumbnailEnabled
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"animated_image_thumbnail_enabled"] boolValue];
}

- (BOOL)enableRotate
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"enable_rotate"] boolValue];
}

- (BOOL)usingAmr
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"using_amr"] boolValue];
}

- (BOOL)enableSyncWhenFetchRemoteMessages
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"sync_when_remote_fetch_messages"] boolValue];
}

- (BOOL)countTeamNotification
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"count_team_notification"] boolValue];
}


- (NSArray *)ignoreTeamNotificationTypes
{
    static NSArray *types = nil;
    if (types == nil)
    {
        NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"ignore_team_types"];
        if ([value isKindOfClass:[NSString class]])
        {
            NSString *typeDescription = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([typeDescription length])
            {
                types = [typeDescription componentsSeparatedByString:@","];
            }
        }
    }
    if (types == nil)
    {
        types = [NSArray array];
    }
    return types;
}


- (BOOL)serverRecordAudio
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"server_record_audio"] boolValue];
}

- (BOOL)serverRecordVideo
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"server_record_video"] boolValue];
}

- (BOOL)serverRecordWhiteboardData
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"server_record_whiteboard_data"] boolValue];
}


- (NSInteger)maximumLogDays
{
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"maximum_log_days"];
    NSInteger days = object? [object integerValue]: 7;
    return days;
}


- (NIMNetCallVideoCrop)videochatVideoCrop
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_video_crop"] integerValue];
}

- (BOOL)videochatAutoRotateRemoteVideo
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_auto_rotate_remote_video"] boolValue];
}

- (UIViewContentMode)videochatRemoteVideoContentMode
{
    NSInteger setting = [[[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_remote_video_content_mode"] integerValue];
    return (setting == 0) ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
}

- (NIMNetCallVideoQuality)preferredVideoQuality
{
    NSInteger videoQualitySetting = [[[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_preferred_video_quality"] integerValue];
    if ((videoQualitySetting >= NIMNetCallVideoQualityDefault) &&
        (videoQualitySetting <= NIMNetCallVideoQuality720pLevel)) {
        return (NIMNetCallVideoQuality)videoQualitySetting;
    }
    return NIMNetCallVideoQualityDefault;
}


- (BOOL)startWithBackCamera
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_start_with_back_camera"] boolValue];
}

- (NIMNetCallVideoCodec)perferredVideoEncoder
{
    NSInteger videoEncoderSetting = [[[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_preferred_video_encoder"] integerValue];

    if ((videoEncoderSetting >= NIMNetCallVideoCodecDefault) &&
        (videoEncoderSetting <= NIMNetCallVideoCodecHardware)) {
        return (NIMNetCallVideoCodec)videoEncoderSetting;
    }
    return NIMNetCallVideoCodecDefault;
}

- (NIMNetCallVideoCodec)perferredVideoDecoder
{
    NSInteger videoDecoderSetting = [[[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_preferred_video_decoder"] integerValue];
    
    if ((videoDecoderSetting >= NIMNetCallVideoCodecDefault) &&
        (videoDecoderSetting <= NIMNetCallVideoCodecHardware)) {
        return (NIMNetCallVideoCodec)videoDecoderSetting;
    }
    return NIMNetCallVideoCodecDefault;

}
- (NSUInteger)videoMaxEncodeKbps
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_video_encode_max_kbps"] integerValue];
}

- (NSUInteger)localRecordVideoKbps
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_local_record_video_kbps"] integerValue];
}

- (BOOL)autoDeactivateAudioSession
{
    id setting = [[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_auto_disable_audiosession"];
    
    if (setting) {
        return [setting boolValue];
    }
    else {
        return YES;
    }
}

- (BOOL)audioDenoise
{
    id setting = [[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_audio_denoise"];
    
    if (setting) {
        return [setting boolValue];
    }
    else {
        return YES;
    }
    
}

- (BOOL)audioHowlingSuppress
{
    id setting = [[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_audio_howling_suppress"];
    
    if (setting) {
        return [setting boolValue];
    }
    else {
        return NO;
    }
}


- (BOOL)voiceDetect
{
    id setting = [[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_voice_detect"];
    
    if (setting) {
        return [setting boolValue];
    }
    else {
        return YES;
    }
    
}

- (BOOL)preferHDAudio
{
    id setting = [[NSUserDefaults standardUserDefaults] objectForKey:@"videochat_prefer_hd_audio"];
    
    if (setting) {
        return [setting boolValue];
    }
    else {
        return NO;
    }
}

- (NIMAVChatScene)scene
{
    id setting = [[NSUserDefaults standardUserDefaults] objectForKey:@"avchat_scene"];
    
    if (setting) {
        return [setting unsignedIntegerValue];
    }
    else {
        return NIMAVChatSceneDefault;
    }
}

- (NSInteger)chatroomRetryCount
{
    id count = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatroom_enter_retry_count"];
    return count == nil ? 3 : [count integerValue];
}

- (NSString *)description
{
    return [NSString stringWithFormat:
                @"\n\n\n" \
                "enabled_remove_recent_session %d\n" \
                "local_search_time_order_desc %d\n" \
                "auto_remove_remote_session %d\n" \
                "auto_remove_snap_message %d\n" \
                "add_friend_need_verify %d\n" \
                "show app %d\n" \
                "maximum log days %zd\n" \
                "using amr %d\n" \
                "ignore_team_types %@ \n" \
                "server_record_audio %d\n" \
                "server_record_video %d\n" \
                "server_record_whiteboard_data %d\n" \
                "videochat_video_crop %zd\n" \
                "videochat_auto_rotate_remote_video %d \n" \
                "videochat_preferred_video_quality %zd\n" \
                "videochat_start_with_back_camera %zd\n" \
                "videochat_preferred_video_encoder %zd\n" \
                "videochat_preferred_video_decoder %zd\n" \
                "videochat_video_encode_max_kbps %zd\n" \
                "videochat_local_record_video_kbps %zd\n" \
                "videochat_auto_disable_audiosession %zd\n" \
                "videochat_audio_denoise %zd\n" \
                "videochat_voice_detect %zd\n" \
                "videochat_audio_howling_suppress %zd\n" \
                "videochat_prefer_hd_audio %zd\n"\
                "avchat_scene %zd\n"\
                "chatroom_retry_count %zd\n"\
                "sync_when_remote_fetch_messages %zd\n"\
                "\n\n\n",
                [self removeSessionWhenDeleteMessages],
                [self localSearchOrderByTimeDesc],
                [self autoRemoveRemoteSession],
                [self autoRemoveSnapMessage],
                [self needVerifyForFriend],
                [self showFps],
                [self maximumLogDays],
                [self usingAmr],
                [self ignoreTeamNotificationTypes],
                [self serverRecordAudio],
                [self serverRecordVideo],
                [self serverRecordWhiteboardData],
                [self videochatVideoCrop],
                [self videochatAutoRotateRemoteVideo],
                [self preferredVideoQuality],
                [self startWithBackCamera],
                [self perferredVideoEncoder],
                [self perferredVideoDecoder],
                [self videoMaxEncodeKbps],
                [self localRecordVideoKbps],
                [self autoDeactivateAudioSession],
                [self audioDenoise],
                [self voiceDetect],
                [self audioHowlingSuppress],
                [self preferHDAudio],
                [self scene],
                [self chatroomRetryCount],
                [self enableSyncWhenFetchRemoteMessages]
            ];
}
@end
