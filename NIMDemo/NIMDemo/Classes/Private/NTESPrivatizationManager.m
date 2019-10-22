//
//  NTESPrivatizationManager.m
//  NIM
//
//  Created by He on 2018/12/28.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "NTESPrivatizationManager.h"
#import <NIMSDK/NIMSDK.h>
#import "NTESDemoConfig.h"

@interface NTESPrivatizationManager ()
@property(nonatomic, strong) NSString *requestURLStr;
@property(nonatomic, strong) NSURL *requestURL;
@property(nonatomic, copy) NSString *configFilePath;
@property(nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation NTESPrivatizationManager
@synthesize requestURL = URL;
@synthesize configFilePath = configFilePath;

+ (void)initialize {
    NSDictionary *dict = @{
                           @"privatization_enabled" : @(NO),
                           @"privatization_password_md5_enabled" : @(NO)
                           };
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NTESPrivatizationManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[NTESPrivatizationManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if(self = [super init]) {
        configFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingString:@"/private_config.cache"];
    }
    return self;
}

- (void)setupPrivatization {
    BOOL privatizationEnabled = NO;
    id setting = nil;
    setting = [[NSUserDefaults standardUserDefaults] objectForKey:@"privatization_enabled"];
    
    if(setting) {
        privatizationEnabled = [setting boolValue];
    }else {
        return;
    }
    
    if(!privatizationEnabled) {
        return;
    }
    
    setting = [[NSUserDefaults standardUserDefaults] valueForKey:@"privatization_url"];
    if(setting && ![self.requestURLStr isEqualToString:setting]) {
        URL = [NSURL URLWithString:setting];
        self.requestURLStr = setting;
    }else {
        return;
    }
    
    // 网络请求私有化文件
    self.semaphore = dispatch_semaphore_create(0);
    [self requestRemoteConfig];
    dispatch_semaphore_wait(self.semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 3));
 
}

- (void)requestRemoteConfig {
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:configFilePath]) {
            [fileManager removeItemAtPath:configFilePath error:nil];
        }
        
        if(error || !data) {
            NSLog(@"私有化配置地址获取失败");
        }else{
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            [self setupPrivatizationWithDict:dict];
        }
        dispatch_semaphore_signal(self.semaphore);
    }] resume];
}

- (void)setupPrivatizationWithDict:(NSDictionary *)config
{

    // NIM 私有化配置
    {
        id setting = [config objectForKey:@"appkey"];
        if(setting) {
            [NTESDemoConfig sharedConfig].appKey = setting;
        }
        
        NIMServerSetting *nimServerSetting = [NIMSDK sharedSDK].serverSetting;
        setting = [config objectForKey:@"https_enabled"];
        if(setting) {
            nimServerSetting.httpsEnabled = [setting boolValue];
        }else {
            nimServerSetting.httpsEnabled = NO;
        }
        
        setting = [config objectForKey:@"lbs"];
        if(setting && [setting length]) {
            nimServerSetting.lbsAddress = setting;
        }
        
        setting = [config objectForKey:@"link"];
        if(setting && [setting length]) {
            nimServerSetting.linkAddress = setting;
        }
        
        setting = [config objectForKey:@"module"];
        if(setting && [setting length]) {
            nimServerSetting.module = setting;
        }
        
        setting = [config objectForKey:@"nosAccess"];
        if(setting && [setting length]) {
//            nimServerSetting.nosAccelerateAddress = setting;
        }
        
        setting = [config objectForKey:@"nosReplacement"];
        if(setting && [setting length]) {
//            nimServerSetting = setting;
        }
        
        setting = [config objectForKey:@"nos_accelerate_host"];
        if(setting && [setting length]) {
            nimServerSetting.nosAccelerateHost = setting;
        }
        
        setting = [config objectForKey:@"nos_accelerate"];
        if(setting && [setting length]) {
            nimServerSetting.nosAccelerateAddress = setting;
        }
        
        setting = [config objectForKey:@"nos_downloader"];
        if(setting && [setting length]) {
            nimServerSetting.nosDownloadAddress = setting;
        }
        
        setting = [config objectForKey:@"nos_lbs"];
        if(setting && [setting length]) {
            nimServerSetting.nosLbsAddress = setting;
        }
        
        setting = [config objectForKey:@"nos_uploader"];
        if(setting && [setting length]) {
            nimServerSetting.nosUploadAddress = setting;
        }
        
        setting = [config objectForKey:@"nos_uploader_host"];
        if(setting && [setting length]) {
            nimServerSetting.nosUploadHost = setting;
        }
        
        setting = [config objectForKey:@"nt_server"];
        if(setting && [setting length]) {
            nimServerSetting.ntServerAddress = setting;
        }
        
        setting = [config objectForKey:@"pubkeyVersion"];
        if(setting) {
            
        }
        
        setting = [config objectForKey:@"version"];
        if(setting) {
            nimServerSetting.version = [setting integerValue];;
        }
        
        setting = [config objectForKey:@"webchatroomAddr"];
        if(setting) {
            
        }
        
        setting = [config objectForKey:@"pubkeyVersion"];
        if(setting) {
            
        }
        
        setting = [config objectForKey:@"chatroomDemoListUrl"];
        if(setting) {
            [NTESDemoConfig sharedConfig].chatroomListURL = setting;
        }
    }
    
    // AVChat 私有化配置
    {
        NIMAVChatServerSetting *avChatServerSetting = [NIMAVChatSDK sharedSDK].serverSetting;
        id setting = [config objectForKey:@"nrtc_server"];
        if(setting) {
            avChatServerSetting.nrtcServerAddress = setting;
        }
        
        setting = [config objectForKey:@"nrtc_roomserver"];
        if(setting) {
            avChatServerSetting.roomServerAddress = setting;
        }
        
        setting = [config objectForKey:@"kibana_server"];
        if(setting) {
            avChatServerSetting.statisticsAddress = setting;
        }
        
        setting = [config objectForKey:@"statistic_server"];
        if(setting) {
            avChatServerSetting.eventTrackAddress = setting;
        }
        
        setting = [config objectForKey:@"netdetect_server"];
        if(setting) {
            avChatServerSetting.nrtcServerAddress = setting;
        }
        
        setting = [config objectForKey:@"compat_server"];
        if(setting) {
            avChatServerSetting.compatConfigAddress = setting;
        }
        
    }

}



@end
