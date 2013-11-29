//
//  PlayerViewController.h
//  UDJ
//
//  Created by Matthew Graf on 8/16/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UDJUserData.h"
#import "UDJPlayerManager.h"

@interface PlayerViewController : UIViewController <UIAlertViewDelegate>

@property(nonatomic,strong) IBOutlet UIButton* leaveButton;
@property(nonatomic,strong) IBOutlet UILabel* playerNameLabel;
@property(nonatomic,strong) IBOutlet UIButton* playerInfoButton;

@property(nonatomic,strong) IBOutlet UILabel* songTitleLabel;
@property(nonatomic,strong) IBOutlet UILabel* artistLabel;
@property(nonatomic,strong) IBOutlet UILabel* albumLabel;

@property(nonatomic,strong) IBOutlet UILabel* timePassedLabel;
@property(nonatomic,strong) IBOutlet UILabel* timeLeftLabel;
@property(nonatomic,strong) IBOutlet UISlider* playbackSlider;

@property(nonatomic,strong) IBOutlet UIButton* togglePlayButton;
@property(nonatomic,strong) IBOutlet UIButton* skipButton;

@property(nonatomic,strong) IBOutlet UISlider* volumeSlider;

@property(nonatomic,strong) UDJPlayerManager* playerManager;
@property(nonatomic,strong) UDJUserData* globalData;
@property(nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property NSInteger playerID;

@property(nonatomic,strong) NSTimer* playbackTimer;
@property BOOL isChangingPlaybackSlider;

-(void)updateDisplayWithItem:(MPMediaItem*)item;

@end
