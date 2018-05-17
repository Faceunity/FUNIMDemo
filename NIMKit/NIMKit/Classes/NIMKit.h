//
//  NIMKit.h
//  NIMKit
//
//  Created by amao on 8/14/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>


//! Project version number for NIMKit.
FOUNDATION_EXPORT double NIMKitVersionNumber;

//! Project version string for NIMKit.
FOUNDATION_EXPORT const unsigned char NIMKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NIMKit/PublicHeader.h>

#import <NIMSDK/NIMSDK.h>

/**
 *  基础Model
 */
#import "NIMKitInfo.h"
#import "NIMMediaItem.h"            //多媒体面板对象
#import "NIMMessageModel.h"         //message Wrapper


/**
 *  协议
 */
#import "NIMKitMessageProvider.h"
#import "NIMCellConfig.h"           //message cell配置协议
#import "NIMInputProtocol.h"        //输入框回调
#import "NIMKitDataProvider.h"      //APP内容提供器
#import "NIMMessageCellProtocol.h"  //message cell事件回调
#import "NIMSessionConfig.h"        //会话页面配置
#import "NIMKitEvent.h"             //点击事件封装类

#import "NIMCellLayoutConfig.h"

/**
 *  消息cell的视觉模板
 */
#import "NIMSessionMessageContentView.h"

/**
 *  UI 配置器
 */
#import "NIMKitConfig.h"

/**
 *  会话页
 */
#import "NIMSessionViewController.h"

/**
 *  会话列表页
 */
#import "NIMSessionListViewController.h"

/*
 *  机器人消息模板解析器
 */
#import "NIMKitRobotDefaultTemplateParser.h"

/*
 *  独立聊天室模式下需注入的信息
 */
#import "NIMKitIndependentModeExtraInfo.h"

@interface NIMKit : NSObject

+ (instancetype)sharedKit;

/**
 *  注册自定义的排版配置，通过注册自定义排版配置来实现自定义消息的定制化排版
 */
- (void)registerLayoutConfig:(NIMCellLayoutConfig *)layoutConfig;

/**
 *  返回当前的排版配置
 */
- (id<NIMCellLayoutConfig>)layoutConfig;

/**
 *  UI 配置器
 */
@property (nonatomic,strong) NIMKitConfig *config;

/**
 *  内容提供者，由上层开发者注入。如果没有则使用默认 provider
 */
@property (nonatomic,strong)    id<NIMKitDataProvider> provider;

/**
 *  由于在独立聊天室模式下, IM 部分服务不可用，需要上层注入一些额外信息供组件显示使用。 默认为 nil，上层在独立聊天室模式下注入，注入时需要创建此对象并注入对象相关字段信息。
 *
 *  此字段需要配合默认的 NIMKitDataProvider ( NIMKitDataProviderImpl ) 使用，如果上层自己定义了 provider ， 则忽略此字段。
 */
@property (nonatomic,strong)  NIMKitIndependentModeExtraInfo *independentModeExtraInfo;


/**
 *  NIMKit图片资源所在的 bundle 名称。
 */
@property (nonatomic,copy)      NSString *resourceBundleName;

/**
 *  NIMKit表情资源所在的 bundle 名称。
 */
@property (nonatomic,copy)      NSString *emoticonBundleName;


/**
 *  机器人消息模板解析器
 */
@property (nonatomic,strong)    NIMKitRobotDefaultTemplateParser *robotTemplateParser;




/**
 *  用户信息变更通知接口
 *
 *  @param userIds 用户 id 集合
 */
- (void)notfiyUserInfoChanged:(NSArray *)userIds;

/**
 *  群信息变更通知接口
 *
 *  @param teamIds 群 id 集合
 */
- (void)notifyTeamInfoChanged:(NSArray *)teamIds;


/**
 *  群成员变更通知接口
 *
 *  @param teamIds 群id
 */
- (void)notifyTeamMemebersChanged:(NSArray *)teamIds;

/**
 *  返回用户信息
 */
- (NIMKitInfo *)infoByUser:(NSString *)userId
                    option:(NIMKitInfoFetchOption *)option;

/**
 *  返回群信息
 */
- (NIMKitInfo *)infoByTeam:(NSString *)teamId
                    option:(NIMKitInfoFetchOption *)option;

@end



