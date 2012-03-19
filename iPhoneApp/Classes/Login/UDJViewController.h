//
//  UDJViewController.h
//  UDJ
//
//  Created by Matthew Graf on 9/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "UDJData.h"
#import <QuartzCore/QuartzCore.h>

@interface UDJViewController : UIViewController <RKRequestDelegate> {

	
	UIButton *loginButton;
	UITextField *usernameField;
	UITextField *passwordField;
    UIButton* registerButton;
    
    NSNumber* currentRequestNumber;
    
    UDJData* globalData;
    
    UIView* loggingInView;
}

@property (strong,nonatomic) IBOutlet UIButton *loginButton;
@property (strong,nonatomic) IBOutlet UITextField *usernameField;
@property (strong,nonatomic) IBOutlet UITextField *passwordField;
@property (strong,nonatomic) IBOutlet UIButton *registerButton;
@property(nonatomic,strong) NSNumber* currentRequestNumber;
@property(nonatomic,strong) UDJData* globalData;
@property(nonatomic,strong) IBOutlet UIView* loggingInView;
- (IBAction) OnButtonClick:(id) sender;

@end

