//
//  NIMKitInfoFetchOption.h
//  NIMKit
//
//  Created by chris on 2016/12/26.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMSession;
@class NIMMessage;

@interface NIMKitInfoFetchOption : NSObject

/**
 *  所属会话
 */
@property (nonatomic,strong)  NIMSession *session;

/**
 *  所属消息
 */
@property (nonatomic,strong)  NIMMessage *message;

/**
 *  屏蔽备注名
 */
@property (nonatomic,assign) BOOL forbidaAlias;

@end
