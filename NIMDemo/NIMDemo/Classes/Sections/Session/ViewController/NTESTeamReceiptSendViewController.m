//
//  NTESTeamReceiptSendViewController.m
//  NIM
//
//  Created by chris on 2018/3/14.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "NTESTeamReceiptSendViewController.h"
#import "NTESSessionMsgConverter.h"
#import "UIView+Toast.h"
#import "UITextView+NTES.h"
#import "UIView+NTES.h"

@interface NTESTeamReceiptSendViewController ()<UITextViewDelegate>

@property (nonatomic,strong) NIMSession *session;

@end

@implementation NTESTeamReceiptSendViewController

- (instancetype)initWithSession:(NIMSession *)session
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _session = session;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"发送已读回执消息";

    self.sendTextView.placeholder   = @"请输入内容";
    self.sendTextView.returnKeyType = UIReturnKeyDone;
    self.sendTextView.delegate = self;
    
    [self.sendButton setBackgroundImage:[[UIImage imageNamed:@"icon_cell_blue_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[[UIImage imageNamed:@"icon_cell_blue_pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateHighlighted];
}

- (void)viewDidLayoutSubviews
{
    if (@available(iOS 11.0, *))
    {
        self.sendTextView.top += 20;
    }
}

- (IBAction)hideKeyboard:(id)sender
{
    [self.sendTextView resignFirstResponder];
}

- (IBAction)send:(id)sender
{
    NSString *text = self.sendTextView.text;
    if (text.length)
    {
        NIMMessage *message = [NTESSessionMsgConverter msgWithText:text];
        NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
        setting.teamReceiptEnabled = YES;
        message.setting = setting;
        [self.navigationController popViewControllerAnimated:YES];
        
        [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:self.session error:nil];
        [self.navigationController.topViewController.view makeToast:@"已发送" duration:2.0 position:CSToastPositionCenter];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self.sendTextView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
