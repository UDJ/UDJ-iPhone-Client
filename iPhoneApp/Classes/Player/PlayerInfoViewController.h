//
//  PlayerInfoViewController.h
//  UDJ
//
//  Created by Matthew Graf on 6/25/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJUserData.h"
#import "UDJPlayerManager.h"
#import "UDJPlayerInfoManager.h"

@interface PlayerInfoViewController : UIViewController <UITextFieldDelegate, UDJRequestDelegate, UIPickerViewDataSource>

@property(nonatomic,strong) IBOutlet UIScrollView* mainScrollView;

@property(nonatomic,strong) IBOutletCollection(UITextField) NSArray* textFieldArray;

@property(nonatomic,strong) IBOutlet UILabel* playerNameLabel;

@property(nonatomic,strong) IBOutlet UITextField* playerNameField;
@property(nonatomic,strong) IBOutlet UITextField* playerPasswordField;

@property(nonatomic,strong) IBOutlet UIButton* closeButton;
@property(nonatomic,strong) IBOutlet UIButton* cancelButton;
@property(nonatomic,strong) IBOutlet UIButton* editButton;
@property(nonatomic,strong) IBOutlet UIButton* doneButton;

@property(nonatomic,strong) IBOutlet UISwitch* useLocationSwitch;
@property(nonatomic,strong) IBOutletCollection(UITextField) NSArray* locationFields;
@property(nonatomic,strong) IBOutlet UITextField* addressField;
@property(nonatomic,strong) IBOutlet UITextField* cityField;
@property(nonatomic,strong) IBOutlet UITextField* stateField;
@property(nonatomic,strong) IBOutlet UITextField* zipCodeField;
@property NSInteger selectedFieldIndex;

@property(nonatomic,strong) NSArray* stateNameArray;
@property(nonatomic,strong) NSArray* stateAbbrArray;
@property(nonatomic,strong) IBOutlet UIView* statePickerView;

@property(nonatomic,strong) IBOutlet UIButton* createPlayerButton;

@property(nonatomic,strong) IBOutlet UIView* activityView;
@property(nonatomic,strong) IBOutlet UILabel* activityLabel;

@property(nonatomic,strong) UDJPlayerInfoManager* playerInfoManager;
@property(nonatomic,strong) UDJPlayerManager* playerManager;
@property(nonatomic,strong) UDJUserData* globalData;
@property(nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong) NSString* playerID;
@property(nonatomic,strong) NSMutableDictionary* songSyncDictionary;

@property(nonatomic,weak) UIViewController* parentViewController;

-(void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response;

@end
