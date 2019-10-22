//
//  NTESSettingViewController.m
//  NIM
//
//  Created by chris on 15/6/25.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NTESSettingViewController.h"
#import "NIMCommonTableData.h"
#import "NIMCommonTableDelegate.h"
#import "SVProgressHUD.h"
#import "UIView+Toast.h"
#import "UIView+NTES.h"
#import "NTESBundleSetting.h"
#import "UIActionSheet+NTESBlock.h"
#import "UIAlertView+NTESBlock.h"
#import "NTESNotificationCenter.h"
#import "NTESCustomNotificationDB.h"
#import "NTESCustomSysNotificationViewController.h"
#import "NTESNoDisturbSettingViewController.h"
#import "NTESLogManager.h"
#import "NTESColorButtonCell.h"
#import "NTESAboutViewController.h"
#import "NTESUserInfoSettingViewController.h"
#import "NTESBlackListViewController.h"
#import "NTESUserUtil.h"
#import "NTESLogUploader.h"
#import "NTESNetDetectViewController.h"
#import "NTESSessionUtil.h"
#import "JRMFHeader.h"
#import "NTESMigrateMessageViewController.h"

@interface NTESSettingViewController ()<NIMUserManagerDelegate>

@property (nonatomic,strong) NSArray *data;
@property (nonatomic,strong) NTESLogUploader *logUploader;
@property (nonatomic,strong) NIMCommonTableDelegate *delegator;

@end

@implementation NTESSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    if (@available(iOS 11.0, *)) {
        CGFloat height = self.view.safeAreaInsets.bottom;
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - height);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildData];
    __weak typeof(self) wself = self;
    self.delegator = [[NIMCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
    
    extern NSString *NTESCustomNotificationCountChanged;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCustomNotifyChanged:) name:NTESCustomNotificationCountChanged object:nil];
    [[NIMSDK sharedSDK].userManager addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].userManager removeDelegate:self];
}

- (void)buildData{
    BOOL disableRemoteNotification = [UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone;
    
    NIMPushNotificationSetting *setting = [[NIMSDK sharedSDK].apnsManager currentSetting];
    BOOL enableNoDisturbing     = setting.noDisturbing;
    NSString *noDisturbingStart = [NSString stringWithFormat:@"%02zd:%02zd",setting.noDisturbingStartH,setting.noDisturbingStartM];
    NSString *noDisturbingEnd   = [NSString stringWithFormat:@"%02zd:%02zd",setting.noDisturbingEndH,setting.noDisturbingEndM];
    
    NSInteger customNotifyCount = [[NTESCustomNotificationDB sharedInstance] unreadCount];
    NSString *customNotifyText  = [NSString stringWithFormat:@"自定义系统通知 (%zd)",customNotifyCount];

    NSString *uid = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSArray *data = @[
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                        @{
                                            ExtraInfo     : uid.length ? uid : [NSNull null],
                                            CellClass     : @"NTESSettingPortraitCell",
                                            RowHeight     : @(100),
                                            CellAction    : @"onActionTouchPortrait:",
                                            ShowAccessory : @(YES)
                                         },
                                       ],
                          FooterTitle:@""
                       },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                  @{
                                      Title         : @"我的钱包",
                                      CellAction    : @"onTouchMyWallet:",
                                      ShowAccessory : @(YES),
                                      },
                                  ],
                          },
                       @{
                          HeaderTitle:@"",
                          RowContent :@[
                                           @{
                                              Title      :@"消息提醒",
                                              DetailTitle:disableRemoteNotification ? @"未开启" : @"已开启",
                                            },
                                        ],
                          FooterTitle:@"在iPhone的“设置- 通知中心”功能，找到应用程序“云信”，可以更改云信新消息提醒设置"
                        },
                        @{
                          HeaderTitle:@"",
                          RowContent :@[
                                          @{
                                              Title        : @"通知显示详情",
                                              CellClass    : @"NTESSettingSwitcherCell",
                                              ExtraInfo    : @(setting.type == NIMPushNotificationDisplayTypeDetail? YES : NO),
                                              CellAction   : @"onActionShowPushDetailSetting:",
                                              ForbidSelect : @(YES)
                                           },
                                      ],
                          FooterTitle:@""
                          },
                       @{
                          HeaderTitle:@"",
                          RowContent :@[
                                       @{
                                          Title      :@"免打扰",
                                          DetailTitle:enableNoDisturbing ? [NSString stringWithFormat:@"%@到%@",noDisturbingStart,noDisturbingEnd] : @"未开启",
                                          CellAction :@"onActionNoDisturbingSetting:",
                                          ShowAccessory : @(YES)
                                        },
                                  ],
                          FooterTitle:@""
                        },
                       @{
                          HeaderTitle:@"",
                          RowContent :@[
                                        @{
                                          Title      :@"查看日志",
                                          CellAction :@"onTouchShowLog:",
                                          },
                                        @{
                                            Title      :@"上传日志",
                                            CellAction :@"onTouchUploadLog:",
                                            },
                                        @{
                                            Title      :@"清理缓存",
                                            CellAction :@"onTouchCleanCache:",
                                            },
                                        @{
                                            Title      :customNotifyText,
                                            CellAction :@"onTouchCustomNotify:",
                                          },
                                        @{
                                            Title      :@"音视频网络探测",
                                            CellAction :@"onTouchNetDetect:",
                                            },
                                        @{
                                            Title      :@"本地消息迁移",
                                            CellAction :@"onTouchMigrateMessages:",
                                            ShowAccessory : @(YES),
                                            
                                            },
                                        @{
                                            Title      :@"关于",
                                            CellAction :@"onTouchAbout:",
                                          },
                                      ],
                          FooterTitle:@""
                        },
                      @{
                          HeaderTitle:@"",
                          RowContent :@[
                                          @{
                                              Title        : @"注销",
                                              CellClass    : @"NTESColorButtonCell",
                                              CellAction   : @"logoutCurrentAccount:",
                                              ExtraInfo    : @(ColorButtonCellStyleRed),
                                              ForbidSelect : @(YES)
                                            },
                                       ],
                          FooterTitle:@"",
                          },
                    ];
    self.data = [NIMCommonTableSection sectionsWithData:data];
}

- (void)refreshData{
    [self buildData];
    [self.tableView reloadData];
}


#pragma mark - Action

- (void)onActionTouchPortrait:(id)sender{
    NTESUserInfoSettingViewController *vc = [[NTESUserInfoSettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onActionNoDisturbingSetting:(id)sender {
    NTESNoDisturbSettingViewController *vc = [[NTESNoDisturbSettingViewController alloc] initWithNibName:nil bundle:nil];
    __weak typeof(self) wself = self;
    vc.handler = ^(){
        [wself refreshData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onActionShowPushDetailSetting:(UISwitch *)switcher
{
    NIMPushNotificationSetting *setting = [NIMSDK sharedSDK].apnsManager.currentSetting;
    setting.type = switcher.on? NIMPushNotificationDisplayTypeDetail : NIMPushNotificationDisplayTypeNoDetail;
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].apnsManager updateApnsSetting:setting completion:^(NSError * _Nullable error) {
        if (error)
        {
            [wself.view makeToast:@"更新失败" duration:2.0 position:CSToastPositionCenter];
            switcher.on = !switcher.on;
        }
    }];
}


- (void)onTouchShowLog:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"查看日志" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看 DEMO 配置",@"查看 SDK 日志",@"查看网络通话日志",@"查看网络探测日志",@"查看 Demo 日志", nil];
    [actionSheet showInView:self.view completionHandler:^(NSInteger index) {
        switch (index) {
            case 0:
                [self showDemoConfig];
                break;
            case 1:
                [self showSDKLog];
                break;
            case 2:
                [self showSDKNetCallLog];
                break;
            case 3:
                [self showSDKNetDetectLog];
                break;
            case 4:
                [self showDemoLog];
                break;
            default:
                break;
        }
    }];
}

- (void)onTouchUploadLog:(id)sender{
    if (_logUploader == nil) {
        _logUploader = [[NTESLogUploader alloc] init];
    }
    
    [SVProgressHUD show];
    
    __weak typeof(self) weakSelf = self;
    [_logUploader upload:^(NSString *urlString,NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (error || !urlString)
        {
            [strongSelf.view makeToast:@"上传日志失败" duration:3.0 position:CSToastPositionCenter];
            [SVProgressHUD dismiss];
            return;
        }
        
        [[NIMSDK sharedSDK].resourceManager fetchNOSURLWithURL:urlString completion:^(NSError * _Nullable error, NSString * _Nullable urlString)
        {
            [SVProgressHUD dismiss];
            if (error || !urlString)
            {
                [strongSelf.view makeToast:@"上传日志失败" duration:3.0 position:CSToastPositionCenter];
                return;
            }
            [UIPasteboard generalPasteboard].string = urlString;
            [strongSelf.view makeToast:@"上传日志成功,URL已复制到剪切板中" duration:3.0 position:CSToastPositionCenter];
        }];
    }];
}


- (void)onTouchCleanCache:(id)sender
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:@"清除后，图片、视频等多媒体消息需要重新下载查看。确定清除？" preferredStyle:UIAlertControllerStyleActionSheet];
    [[vc addAction:@"清除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NIMResourceQueryOption *option = [[NIMResourceQueryOption alloc] init];
        option.timeInterval = 0;
        [SVProgressHUD show];
        [[NIMSDK sharedSDK].resourceManager removeResourceFiles:option completion:^(NSError * _Nullable error, long long freeBytes) {
            [SVProgressHUD dismiss];
            if (error)
            {
                UIAlertController *result = [UIAlertController alertControllerWithTitle:@"" message:@"清除失败！" preferredStyle:UIAlertControllerStyleAlert];
                [result addAction:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [result show];
            }
            else
            {
                CGFloat freeMB = (CGFloat)freeBytes / 1000 / 1000;
                UIAlertController *result = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"成功清理了%.2fMB磁盘空间",freeMB] preferredStyle:UIAlertControllerStyleAlert];
                [result addAction:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [result show];
            }
        }];
    }]
     addAction:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [vc show];
}

- (void)onTouchMyWallet:(id)sender
{
    JrmfWalletSDK * jrmf = [[JrmfWalletSDK alloc] init];
    NSString *userId = [[NIMSDK sharedSDK].loginManager currentAccount];
    NIMKitInfo *userInfo = [[NIMKit sharedKit] infoByUser:userId option:nil];
    [jrmf doPresentJrmfWalletPageWithBaseViewController:self userId:userId userName:userInfo.showName userHeadLink:userInfo.avatarUrlString thirdToken:[JRMFSington GetPacketSington].JrmfThirdToken];
}

- (void)onTouchCustomNotify:(id)sender{
    NTESCustomSysNotificationViewController *vc = [[NTESCustomSysNotificationViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTouchAbout:(id)sender{
    NTESAboutViewController *about = [[NTESAboutViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:about animated:YES];
}

- (void)onTouchNetDetect:(id)sender {
    NTESNetDetectViewController *vc = [[NTESNetDetectViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)logoutCurrentAccount:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"退出当前帐号？" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert showAlertWithCompletionHandler:^(NSInteger alertIndex) {
        switch (alertIndex) {
            case 1:
                [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error)
                 {
                     extern NSString *NTESNotificationLogout;
                     [[NSNotificationCenter defaultCenter] postNotificationName:NTESNotificationLogout object:nil];
                 }];
                break;
            default:
                break;
        }
    }];
}

- (void)onTouchMigrateMessages:(id)sender {
    NTESMigrateMessageViewController *migrateMessageController = [[NTESMigrateMessageViewController alloc] init];
    [self.navigationController pushViewController:migrateMessageController animated:YES];
}

#pragma mark - Notification
- (void)onCustomNotifyChanged:(NSNotification *)notification
{
    [self buildData];
    [self.tableView reloadData];
}


#pragma mark - NIMUserManagerDelegate
- (void)onUserInfoChanged:(NIMUser *)user
{
    if ([user.userId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]]) {
        [self buildData];
        [self.tableView reloadData];
    }
}


#pragma mark - Private

- (void)showSDKLog{
    UIViewController *vc = [[NTESLogManager sharedManager] sdkLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)showSDKNetCallLog{
    UIViewController *vc = [[NTESLogManager sharedManager] sdkNetCallLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)showSDKNetDetectLog{
    UIViewController *vc = [[NTESLogManager sharedManager] sdkNetDetectLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}


- (void)showDemoLog{
    UIViewController *logViewController = [[NTESLogManager sharedManager] demoLogViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logViewController];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

- (void)showDemoConfig {
    UIViewController *logViewController = [[NTESLogManager sharedManager] demoConfigViewController];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logViewController];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}

#pragma mark - 旋转处理 (iOS7)
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}


@end
