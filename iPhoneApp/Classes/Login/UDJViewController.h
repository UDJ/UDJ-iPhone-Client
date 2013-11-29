/**
 * Copyright 2011 Matthew M. Graf
 *
 * This file is part of UDJ.
 *
 * UDJ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * UDJ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with UDJ.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <UIKit/UIKit.h>
#import "UDJUserData.h"
#import "UDJStoredData.h"
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
@interface UDJViewController : UIViewController <UDJRequestDelegate, UIAlertViewDelegate, FBLoginViewDelegate> {

	
    UIButton *loginButton;
    UITextField *usernameField;
    UITextField *passwordField;
    UIButton* registerButton;
    
    NSNumber* currentRequestNumber;
    
    UDJUserData* globalData;
    
    UIView* loginBackgroundView;
    UIView* loginView;
    UIButton* cancelButton;
}

@property(strong,nonatomic) IBOutlet UIButton *loginButton;
@property(strong,nonatomic) IBOutlet UITextField *usernameField;
@property(strong,nonatomic) IBOutlet UITextField *passwordField;
@property(strong,nonatomic) IBOutlet UIButton *registerButton;
@property(nonatomic,strong) NSNumber* currentRequestNumber;
@property(nonatomic,strong) UDJUserData* globalData;

@property(nonatomic,strong) IBOutlet UIView* loginView;
@property(nonatomic,strong) IBOutlet UIView* loginBackgroundView;
@property(nonatomic,strong) IBOutlet UIButton* cancelButton;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;  

- (IBAction) OnButtonClick:(id) sender;
- (IBAction) cancelButtonClick:(id)sender;

@end

