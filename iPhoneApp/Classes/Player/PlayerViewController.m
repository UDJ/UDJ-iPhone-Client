//
//  PlayerViewController.m
//  UDJ
//
//  Created by Matthew Graf on 8/16/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlayerViewController.h"
#import "PlayerInfoViewController.h"
#import "UDJPlayerInfoManager.h"
#import "UDJPlaylist.h"
#import <AVFoundation/AVAudioSession.h>

@interface PlayerViewController ()

@end

@implementation PlayerViewController

@synthesize playerNameLabel, playerInfoButton;
@synthesize songTitleLabel, artistLabel, albumLabel;
@synthesize timePassedLabel, timeLeftLabel;
@synthesize playbackSlider, togglePlayButton, skipButton;
@synthesize volumeSlider;
@synthesize playerManager, globalData, managedObjectContext, playerID;
@synthesize leaveButton;
@synthesize playbackTimer, isChangingPlaybackSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initNavBar
{
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.playerManager = [UDJPlayerManager sharedPlayerManager];
    self.playerManager.UIDelegate = self;
    
    [[UDJPlayerInfoManager sharedPlayerInfoManager] updateCurrentPlayer];
    self.playerManager.playerID = [UDJPlayerInfoManager sharedPlayerInfoManager].playerID;
    [[UDJPlaylist sharedUDJPlaylist] setPlayerID: playerManager.playerID];
    
    [playerManager changePlayerState: PlayerStatePaused];
    [playerManager updatePlayerMusic];
    
    [self setPlaybackTimer: [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackSlider) userInfo:nil repeats:YES]];
    [playerManager beginPlaylistUpdates];
    
    // set up AVAudioSession
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    [self initNavBar];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UDJPlaylist sharedUDJPlaylist] sendPlaylistRequest];
}

#pragma mark - Play and pause

-(void)updateDisplayWithItem:(MPMediaItem*)item;{
    // update the UI for current song
    NSTimeInterval duration = [[item valueForProperty: MPMediaItemPropertyPlaybackDuration] doubleValue];
    float maxValue = duration;
    [playbackSlider setMaximumValue: maxValue];
    
    NSInteger minutes = duration/60;
    NSInteger seconds = (NSInteger)duration%60;
    [self.timeLeftLabel setText: [NSString stringWithFormat: @"%d:%02d", minutes, seconds]];
    
    // update song title labels
    [songTitleLabel setText: [item valueForProperty: MPMediaItemPropertyTitle]];
    [albumLabel setText: [item valueForProperty: MPMediaItemPropertyAlbumTitle]];
    [artistLabel setText: [item valueForProperty: MPMediaItemPropertyArtist]];
}

-(IBAction)playToggleClick:(id)sender{
    if([playerManager playerState] == PlayerStatePaused){
        if([playerManager play]){
            [togglePlayButton setImage:[UIImage imageNamed: @"pausetoggle.png"] forState:UIControlStateNormal];
        }
    }
    else{
        [togglePlayButton setImage:[UIImage imageNamed: @"playtoggle.png"] forState:UIControlStateNormal];
        [playerManager pause];        
    }
}

-(IBAction)skipButtonClick:(id)sender{
    [playerManager playNextSong];
}

#pragma mark - Changing song position

-(void)updatePlaybackSlider{
    if(!isChangingPlaybackSlider){
        float time = [playerManager currentPlaybackTime];
        [playbackSlider setValue: time];
        [self updatePlaybackLabels];        
    }
}

-(void)updatePlaybackLabels{
    NSInteger minutes = self.playbackSlider.value/60;
    NSInteger seconds = ((NSInteger)self.playbackSlider.value)%60;
    [self.timePassedLabel setText: [NSString stringWithFormat: @"%d:%02d", minutes, seconds]];
    
    NSInteger timeLeft = self.playbackSlider.maximumValue - self.playbackSlider.value;
    minutes = timeLeft/60;
    seconds = timeLeft%60;
    [self.timeLeftLabel setText: [NSString stringWithFormat: @"-%d:%02d", minutes, seconds]];    
}

-(IBAction)playbackSliderTouchDown:(id)sender{
    self.isChangingPlaybackSlider = YES;
}

-(IBAction)positionSliderValueChanged:(id)sender{
    [self updatePlaybackLabels];
}

-(IBAction)doneChangingPositionSlider:(id)sender{
    [playerManager updateSongPosition: self.playbackSlider.value];
    self.isChangingPlaybackSlider = NO;
}

#pragma mark - Closing out of player

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self.navigationController popViewControllerAnimated: YES];
        [playerManager endPlaylistUpdates];
        [playerManager resetAudioPlayer];
        [playerManager changePlayerState: PlayerStateInactive];
    }
}

-(IBAction)leaveButtonClick:(id)sender{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Player" message:@"Your player will become inactive if you leave this screen. Are you sure you want to leave?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave", nil];
    [alertView show];
}


#pragma mark - Player info

-(IBAction)playerInfoButtonClick:(id)sender{
    PlayerInfoViewController* viewController = [[PlayerInfoViewController alloc] initWithNibName: @"PlayerInfoViewController" bundle:[NSBundle mainBundle]];
    [self presentModalViewController: viewController animated: YES];
    viewController.playerManager = self.playerManager;
}

@end
