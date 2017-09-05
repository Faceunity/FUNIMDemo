//
//  NIMKitDefaultDataProvider.m
//  NIMKit
//
//  Created by chris on 2016/10/31.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIMKit.h"
#import "NIMKitDataProviderImpl.h"
#import "NIMKitInfoFetchOption.h"
#import "UIImage+NIMKit.h"

#pragma mark - kit data request
@interface NIMKitDataRequest : NSObject

@property (nonatomic,assign) NSInteger maxMergeCount; //最大合并数

- (void)requestUserIds:(NSArray *)userIds;

@end


@implementation NIMKitDataRequest{
    NSMutableArray *_requstUserIdArray; //待请求池
    BOOL _isRequesting;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _requstUserIdArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)requestUserIds:(NSArray *)userIds
{
    for (NSString *userId in userIds)
    {
        if (![_requstUserIdArray containsObject:userId])
        {
            [_requstUserIdArray addObject:userId];
        }
    }
    [self request];
}


- (void)request
{
    static NSUInteger MaxBatchReuqestCount = 10;
    if (_isRequesting || [_requstUserIdArray count] == 0) {
        return;
    }
    _isRequesting = YES;
    NSArray *userIds = [_requstUserIdArray count] > MaxBatchReuqestCount ?
    [_requstUserIdArray subarrayWithRange:NSMakeRange(0, MaxBatchReuqestCount)] : [_requstUserIdArray copy];
    
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].userManager fetchUserInfos:userIds
                                        completion:^(NSArray *users, NSError *error) {
                                            [weakSelf afterReuquest:userIds];
                                            if (!error) {
                                                [[NIMKit sharedKit] notfiyUserInfoChanged:userIds];
                                            }
                                        }];
}

- (void)afterReuquest:(NSArray *)userIds
{
    _isRequesting = NO;
    [_requstUserIdArray removeObjectsInArray:userIds];
    [self request];
    
}

@end

#pragma mark - data provider impl

@interface NIMKitDataProviderImpl()<NIMUserManagerDelegate,NIMTeamManagerDelegate,NIMLoginManagerDelegate>

@property (nonatomic,strong) UIImage *defaultUserAvatar;

@property (nonatomic,strong) UIImage *defaultTeamAvatar;

@property (nonatomic,strong) NIMKitDataRequest *request;

@end


@implementation NIMKitDataProviderImpl

- (instancetype)init{
    self = [super init];
    if (self) {
        _request = [[NIMKitDataRequest alloc] init];
        _request.maxMergeCount = 20;
        [[NIMSDK sharedSDK].userManager addDelegate:self];
        [[NIMSDK sharedSDK].teamManager addDelegate:self];
        [[NIMSDK sharedSDK].loginManager addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].userManager removeDelegate:self];
    [[NIMSDK sharedSDK].teamManager removeDelegate:self];
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
}


#pragma mark - public api
- (NIMKitInfo *)infoByUser:(NSString *)userId
                    option:(NIMKitInfoFetchOption *)option
{
    //优先检测是否为机器人
    NIMKitInfo *info = [self infoByRobot:userId];
    if (info == nil)
    {
        info = option.message ? [self infoByUser:userId message:option.message option:option]
        : [self infoByUser:userId session:option.session option:option];
    }
    return info;
}

- (NIMKitInfo *)infoByTeam:(NSString *)teamId
                    option:(NIMKitInfoFetchOption *)option
{
    NIMTeam *team    = [[NIMSDK sharedSDK].teamManager teamById:teamId];
    NIMKitInfo *info = [[NIMKitInfo alloc] init];
    info.showName    = team.teamName;
    info.infoId      = teamId;
    info.avatarImage = self.defaultTeamAvatar;
    info.avatarUrlString = team.thumbAvatarUrl;
    return info;
}


#pragma mark - 用户信息拼装
//会话中用户信息
- (NIMKitInfo *)infoByUser:(NSString *)userId
                   session:(NIMSession *)session
                    option:(NIMKitInfoFetchOption *)option
{
    BOOL needFetchInfo = NO;
    NIMSessionType sessionType = session.sessionType;
    NIMKitInfo *info = [[NIMKitInfo alloc] init];
    info.infoId = userId;
    info.showName = userId; //默认值
    switch (sessionType) {
        case NIMSessionTypeP2P:
        case NIMSessionTypeTeam:
        {
            NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:userId];
            NIMUserInfo *userInfo = user.userInfo;
            NIMTeamMember *member = nil;
            if (sessionType == NIMSessionTypeTeam)
            {
                member = [[NIMSDK sharedSDK].teamManager teamMember:userId
                                                             inTeam:session.sessionId];
            }
            NSString *name = [self nickname:user
                                 memberInfo:member
                                     option:option];
            if (name)
            {
                info.showName = name;
            }
            info.avatarUrlString = userInfo.thumbAvatarUrl;
            info.avatarImage = self.defaultUserAvatar;
            
            if (userInfo == nil)
            {
                needFetchInfo = YES;
            }
        }
            break;
        case NIMSessionTypeChatroom:
            NSAssert(0, @"invalid type"); //聊天室的Info不会通过这个回调请求
            break;
        default:
            NSAssert(0, @"invalid type");
            break;
    }
    
    if (needFetchInfo)
    {
        [self.request requestUserIds:@[userId]];
    }
    return info;
}


//消息中用户信息
- (NIMKitInfo *)infoByUser:(NSString *)userId
                   message:(NIMMessage *)message
                    option:(NIMKitInfoFetchOption *)option
{
    if (message.session.sessionType == NIMSessionTypeChatroom)
    {
        NIMKitInfo *info = [[NIMKitInfo alloc] init];
        info.infoId = userId;
        if ([userId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount]) {
            NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:userId];
            info.showName        = user.userInfo.nickName;
            info.avatarUrlString = user.userInfo.thumbAvatarUrl;
        }else{
            NIMMessageChatroomExtension *ext = [message.messageExt isKindOfClass:[NIMMessageChatroomExtension class]] ?
            (NIMMessageChatroomExtension *)message.messageExt : nil;
            info.showName = ext.roomNickname;
            info.avatarUrlString = ext.roomAvatar;
        }
        info.avatarImage = self.defaultUserAvatar;
        return info;
    }
    else
    {
        return [self infoByUser:userId
                        session:message.session
                         option:option];
    }
}


//机器人
- (NIMKitInfo *)infoByRobot:(NSString *)userId
{
    NIMKitInfo *info = nil;
    if ([[NIMSDK sharedSDK].robotManager isValidRobot:userId])
    {
        NIMRobot *robot = [[NIMSDK sharedSDK].robotManager robotInfo:userId];
        if (robot)
        {
            info = [[NIMKitInfo alloc] init];
            info.infoId   = userId;
            info.showName = robot.nickname;
            info.avatarUrlString = robot.thumbAvatarUrl;
            info.avatarImage = self.defaultUserAvatar;
        }
    }
    return info;
}

//昵称优先级
- (NSString *)nickname:(NIMUser *)user
            memberInfo:(NIMTeamMember *)memberInfo
                option:(NIMKitInfoFetchOption *)option
{
    NSString *name = nil;
    do{
        if (!option.forbidaAlias && [user.alias length])
        {
            name = user.alias;
            break;
        }
        if (memberInfo && [memberInfo.nickname length])
        {
            name = memberInfo.nickname;
            break;
        }
        
        if ([user.userInfo.nickName length])
        {
            name = user.userInfo.nickName;
            break;
        }
    }while (0);
    return name;
}

#pragma mark - avatar
- (UIImage *)defaultTeamAvatar
{
    if (!_defaultTeamAvatar)
    {
        _defaultTeamAvatar = [UIImage nim_imageInKit:@"avatar_team"];
    }
    return _defaultTeamAvatar;
}

- (UIImage *)defaultUserAvatar
{
    if (!_defaultUserAvatar)
    {
        _defaultUserAvatar = [UIImage nim_imageInKit:@"avatar_user"];
    }
    return _defaultUserAvatar;
}




//将个人信息和群组信息变化通知给 NIMKit 。
//如果您的应用不托管个人信息给云信，则需要您自行在上层监听个人信息变动，并将变动通知给 NIMKit。

#pragma mark - NIMUserManagerDelegate

- (void)onFriendChanged:(NIMUser *)user
{
    [[NIMKit sharedKit] notfiyUserInfoChanged:@[user.userId]];
}

- (void)onUserInfoChanged:(NIMUser *)user
{
    [[NIMKit sharedKit] notfiyUserInfoChanged:@[user.userId]];
}


#pragma mark - NIMTeamManagerDelegate
- (void)onTeamAdded:(NIMTeam *)team
{
    [[NIMKit sharedKit] notifyTeamInfoChanged:@[team.teamId]];
}

- (void)onTeamUpdated:(NIMTeam *)team
{
    [[NIMKit sharedKit] notifyTeamInfoChanged:@[team.teamId]];
}

- (void)onTeamRemoved:(NIMTeam *)team
{
    [[NIMKit sharedKit] notifyTeamInfoChanged:@[team.teamId]];
}

- (void)onTeamMemberChanged:(NIMTeam *)team
{
    [[NIMKit sharedKit] notifyTeamMemebersChanged:@[team.teamId]];
}

#pragma mark - NIMLoginManagerDelegate
- (void)onLogin:(NIMLoginStep)step
{
    if (step == NIMLoginStepSyncOK) {
        [[NIMKit sharedKit] notifyTeamInfoChanged:nil];
        [[NIMKit sharedKit] notifyTeamMemebersChanged:nil];
    }
}



@end



