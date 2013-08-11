//
//  ViewController.m
//  TestDemo
//
//  Created by lfh on 13-4-1.
//  Copyright (c) 2013年 linfh. All rights reserved.
//

#import "ViewController.h"
#import <DianJinOfferPlatform/DianJinOfferPlatform.h>
#import <DianJinOfferPlatform/DianJinPlatformError.h>
#import <DianJinOfferPlatform/DianJinBannerSubViewProperty.h>
#import <DianJinOfferPlatform/DianJinTransitionParam.h>
#import <DianJinOfferPlatform/DianJinOfferPlatformProtocol.h>

@interface ViewController ()
- (void)messageBox:(NSString *)title message:(NSString *)message buttonName:(NSString *)buttonName;
@end

@implementation ViewController

- (void)showOfferWall {
    
	[[DianJinOfferPlatform defaultPlatform] showOfferWall:self delegate:self];
//    [[DianJinOfferPlatform defaultPlatform] presentOfferWall:self];
}

- (void)getBalance {
	int result = [[DianJinOfferPlatform defaultPlatform] getBalance:self];
	if (result != DIAN_JIN_NO_ERROR) {
		NSLog(@"consume result = %d", result);
	}
}

- (void)consume {
	if (_consumeAmount.text==nil) {
		[self messageBox:@"消费失败" message:[NSString stringWithFormat:@"消费金额不能为空,输入数据必须为数字!"] buttonName:@"确定"];
		return;
	}
	float amount = [_consumeAmount.text floatValue];
	if (amount<=0.0) {
		[self messageBox:@"消费失败" message:[NSString stringWithFormat:@"消费金额不能为空,输入数据必须为数字!"] buttonName:@"确定"];
		return;
	}
	
	int action = [_consumeAction.text intValue];
	if (action < 1000) {
		[self messageBox:@"消费失败" message:[NSString stringWithFormat:@"消费动作必须大于1000,且输入数据必须为数字!"] buttonName:@"确定"];
		return;
	}
	
	int result = [[DianJinOfferPlatform defaultPlatform] consume:amount delegate:self];
	if (result != DIAN_JIN_NO_ERROR) {
		NSLog(@"consume result = %d", result);
	}
}

- (void)getBalanceDidFinish:(NSDictionary *)dict {
	NSLog(@"%@", dict);
	NSString *boxMessage = nil;
	NSNumber *result = [dict objectForKey: @"result"];
	if ([result intValue] == DIAN_JIN_NO_ERROR) {
		NSNumber *balance = [dict objectForKey:@"balance"];
		if (balance != nil) {
			_balanceLabel.text = [NSString stringWithFormat:@"%.2f", [balance floatValue]];
		}
	}
	else if ([result intValue] == DIAN_JIN_ERROR_NETWORK_FAIL) {
		boxMessage = @"网络连接错误";
	}
	else if ([result intValue] == DIAN_JIN_ERROR_USER_NOT_AUTHORIZED) {
		boxMessage = @"未授权的appId和appKey";
	}
	else {
		boxMessage = [NSString stringWithFormat:@"错误码:%d", [result intValue]];
	}
	if (boxMessage != nil) {
		[self messageBox:@"查询余额失败" message:boxMessage buttonName:@"确定"];
	}
}

- (void)consumeDidFinish:(NSDictionary *)dict {
	NSLog(@"%@", dict);
	NSNumber *result = [dict objectForKey: @"result"];
	NSString *boxMessage = nil;
	NSString *boxTitle = @"消费失败";
	switch ([result intValue]) {
		case DIAN_JIN_NO_ERROR:
			boxTitle = @"消费成功";
			boxMessage = [NSString stringWithFormat:@"消费动作为:%@", [dict objectForKey:@"action"]];
			break;
		case DIAN_JIN_ERROR_NETWORK_FAIL:
			boxMessage = @"网络连接错误";
			break;
		case DIAN_JIN_ERROR_REQUES_CONSUNE:
			boxMessage = @"支付请求失败";
			break;
		case DIAN_JIN_ERROR_BALANCE_NO_ENOUGH:
			boxMessage = @"余额不足";
			break;
		case DIAN_JIN_ERROR_ACCOUNT_NO_EXIST:
			boxMessage = @"帐号不存在";
			break;
		case DIAN_JIN_ERROR_ORDER_SERIAL_REPEAT:
			boxMessage = @"订单号重复";
			break;
		case DIAN_JIN_ERROR_BEYOND_LARGEST_AMOUNT:
			boxMessage = @"一次性交易超出最大限定金额";
			break;
		case DIAN_JIN_ERROR_CONSUME_ID_NO_EXIST:
			boxMessage = @"不存在该类型的消费动作ID";
			break;
		case DIAN_JIN_ERROR_USER_NOT_AUTHORIZED:
			boxMessage = @"未授权的appId和appKey";
			break;
            
		default:
			boxMessage = [NSString stringWithFormat:@"未知错误 错误码为:%d", [result intValue]];
			break;
	}
	[self messageBox:boxTitle message:boxMessage buttonName:@"确定"];
}

- (void)offerViewDidClose {
	NSLog(@"offerviewdidclose");
}

- (void)appActivatedDidFinish:(NSNotification *)notice {
    NSDictionary *dict = [notice object];
    NSLog(@"dict = %@", dict);
	NSNumber *result = [dict objectForKey:@"result"];
	if ([result boolValue]) {
		NSNumber *awardAmount = [dict objectForKey:@"awardAmount"];
		_awardAmountLabel.text = [NSString stringWithFormat:@"%.2f", [awardAmount floatValue]];
		NSString *identifier = [dict objectForKey:@"identifier"];
		NSLog(@"app identifier = %@", identifier);
	}
	else {
		_awardAmountLabel.text = @"0.00";
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActivatedDidFinish:) name:kDJAppActivateDidFinish object:nil];
	[[DianJinOfferPlatform defaultPlatform] setOfferViewAutoRotate:YES];
	_consumeAmount.text = [NSString stringWithFormat:@"%.2f", 0.01f];
	_consumeAction.text = @"2000";
    //    [[DianJinOfferPlatform defaultPlatform] setOfferViewOrientation:UIInterfaceOrientationLandscapeLeft];
	_banner.isAutoRotate = YES;
    //	DianJinBannerSubViewProperty *colorProperty = [[DianJinBannerSubViewProperty alloc] init];
    //	colorProperty.viewNormalBackgroundColor = [UIColor clearColor];		//正常时banner视图背景颜色
    //	colorProperty.viewTouchBackgroundColor = [UIColor yellowColor];		//点击时banner时视图背景颜色
    //
    //	colorProperty.appNameLabelTextNormalColor = [UIColor greenColor];	//正常时应用名称字体颜色
    //	colorProperty.appNameLabelTextTouchColor = [UIColor redColor];		//点击时应用名称字体颜色
    //
    //	colorProperty.appDescLabelTextNormalColor = [UIColor whiteColor];	//正常时应用简介字体颜色
    //	colorProperty.appDescLabelTextTouchColor = [UIColor blackColor];	//点击时应用简介字体颜色
    //
    //	colorProperty.appRewardLabelTextColor = [UIColor yellowColor];		//奖励描述字体颜色
    //
    //	colorProperty.overlayBackgroundColor = [UIColor whiteColor];		//点击完成时覆盖层背景颜色
    //
    //	colorProperty.downloadButtonBackgroundColor = [UIColor darkGrayColor];	//下载奖励按钮背景颜色
    //
    //	[_banner setupSubViewProperty:colorProperty];
	_banner.backgroundColor = [UIColor clearColor];
    //	[colorProperty release];
	DianJinTransitionParam *transitionParam = [[DianJinTransitionParam alloc] init];
	transitionParam.animationType = kDJTransitionRippleEffect;
	transitionParam.animationSubType = kDJTransitionFromLeft;
	transitionParam.duration = 1.0;
	[_banner setupTransition:transitionParam];
	[transitionParam release];
	[_banner startWithTimeInterval:10 delegate:self];
    
    DianJinAdBanner *adBanner = [[[DianJinAdBanner alloc] initAdBannerWithOrigin:CGPointMake(0, 50) size:kDJCPCBannerStyle320_50] autorelease];
    [adBanner setBrowserAutoRotate:YES];
    adBanner.delegate = self;
    [adBanner setBrowserNavigationBarColor:[UIColor redColor]];
    [self.view addSubview:adBanner];
    [[DianJinOfferPlatform defaultPlatform] floatLogoEnable:YES];
    [[DianJinOfferPlatform defaultPlatform] setDefaultAppType:kDJGame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[_banner release];
	[_balanceLabel release];
	[_consumeAmount release];
	[_consumeAction release];
	[_awardAmountLabel release];
    [super dealloc];
}

#pragma mark - DianJinAdBannerDelegate

- (void)adLoadSuccess {
    NSLog(@"adLoadSuccess");
}

- (void)adLoadFail {
    NSLog(@"adLoadFail");
}

- (void)adBrowserDidShow {
    NSLog(@"adBrowserDidShow");
}

- (void)adBrowserDidHide {
    NSLog(@"adBrowserDidHide");
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGSize size = [UIScreen mainScreen].bounds.size;
	switch ([UIApplication sharedApplication].statusBarOrientation) {
		case UIInterfaceOrientationPortrait:
			self.view.frame = CGRectMake(0, -196, size.width, size.height);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			self.view.frame = CGRectMake(0, 196, size.width, size.height);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			self.view.frame = CGRectMake(-160, 0, size.width, size.height);
			break;
		case UIInterfaceOrientationLandscapeRight:
			self.view.frame = CGRectMake(160, 0, size.width, size.height);
			break;
		default:
			break;
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGSize size = [UIScreen mainScreen].bounds.size;
	switch ([UIApplication sharedApplication].statusBarOrientation) {
		case UIInterfaceOrientationPortrait:
			self.view.frame = CGRectMake(0, 20, size.width, size.height);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			self.view.frame = CGRectMake(0, -20, size.width, size.height);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			self.view.frame = CGRectMake(20, 0, size.width, size.height);
			break;
		case UIInterfaceOrientationLandscapeRight:
			self.view.frame = CGRectMake(-20, 0, size.width, size.height);
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark UITouch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[_consumeAmount resignFirstResponder];
	[_consumeAction resignFirstResponder];
}

- (IBAction)choiceSkin:(id)sender {
    [[DianJinOfferPlatform defaultPlatform] setCustomOfferViewColor:nil];
    switch (_skinSegment.selectedSegmentIndex) {
        case 0:
            [[DianJinOfferPlatform defaultPlatform] setOfferViewColor:kDJBrownColor];
            break;
        case 1:
            [[DianJinOfferPlatform defaultPlatform] setOfferViewColor:kDJPinkColor];
            break;
        case 2:
            [[DianJinOfferPlatform defaultPlatform] setOfferViewColor:kDJBlueColor];
            break;
        case 3:
            [[DianJinOfferPlatform defaultPlatform] setOfferViewColor:kDJOrangeColor];
            break;
        default:
            break;
    }
    
}

- (IBAction)customColor:(id)sender {
    UIColor *customColor = [UIColor colorWithRed:_redSlider.value / 255.0 green:_greenSlider.value / 255.0 blue:_blueSlider.value / 255.0 alpha:1.0];
    _customColorLabel.backgroundColor = customColor;
    [[DianJinOfferPlatform defaultPlatform] setCustomOfferViewColor:customColor];
}

- (IBAction)clearCustomColer:(id)sender {
    _redSlider.value = 0;
    _greenSlider.value = 0;
    _blueSlider.value = 0;
    _customColorLabel.backgroundColor = [UIColor blackColor];
    [[DianJinOfferPlatform defaultPlatform] setCustomOfferViewColor:nil];
}

#pragma mark -
#pragma mark private func

- (void)messageBox:(NSString *)title message:(NSString *)message buttonName:(NSString *)buttonName {
	UIAlertView *alert = [[UIAlertView alloc] init];
	alert.title = title;
	alert.message = message;
	[alert addButtonWithTitle:buttonName];
	[alert show];
	[alert release];
}

@end
