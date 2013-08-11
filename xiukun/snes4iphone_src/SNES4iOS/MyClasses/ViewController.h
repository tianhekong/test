//
//  ViewController.h
//  TestDemo
//
//  Created by lfh on 13-4-1.
//  Copyright (c) 2013年 linfh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DianJinOfferPlatform/DianJinOfferBanner.h>
#import <DianJinOfferPlatform/DianJinAdBanner.h>

@interface ViewController : UIViewController <UITextFieldDelegate, DianJinAdBannerDelegate>{
	IBOutlet DianJinOfferBanner *_banner;
	IBOutlet UILabel *_balanceLabel;
	IBOutlet UILabel *_customColorLabel;
    IBOutlet UITextField *_consumeAmount;
	IBOutlet UITextField *_consumeAction;
	IBOutlet UILabel *_awardAmountLabel;
    IBOutlet UISegmentedControl *_skinSegment;
    IBOutlet UISlider *_redSlider;
    IBOutlet UISlider *_greenSlider;
    IBOutlet UISlider *_blueSlider;
}

- (IBAction)showOfferWall;
- (IBAction)getBalance;
- (IBAction)consume;
- (IBAction)choiceSkin:(id)sender;
- (IBAction)customColor:(id)sender;
- (IBAction)clearCustomColer:(id)sender;

@end
