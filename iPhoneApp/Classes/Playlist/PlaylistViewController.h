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
#import "UDJPlayer.h"
#import "UDJPlaylist.h"
#import "PullRefreshTableViewController.h"
#import "UDJPlaylistDelegate.h"
#import "UDJClient.h"

typedef enum{
    ExitReasonInactive,
    ExitReasonKicked
} ExitReason;

@interface PlaylistViewController : PullRefreshTableViewController <UIAlertViewDelegate, UDJRequestDelegate, UDJPlaylistDelegate>{

    UDJPlaylist *playlist;
    UDJPlayer* currentEvent;
    UITableView* tableView;
    UILabel* currentSongTitleLabel;
    UILabel* currentSongArtistLabel;
    UILabel* statusLabel;
    UDJSong* selectedSong;
    UDJUserData* globalData;
    
    UIView* leavingBackgroundView;
    UIView* leavingView;

}

-(void)sendRefreshRequest;
-(void)refreshTableList;
-(void)vote:(BOOL)up;
//-(void)login;
//-(void)post;

@property(nonatomic, strong) UDJSong* selectedSong;
@property (nonatomic, strong) UDJPlayer* currentEvent;
@property (nonatomic, strong) UDJPlaylist* playlist;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UILabel* currentSongTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel* currentSongArtistLabel;
@property(nonatomic,strong) IBOutlet UILabel* statusLabel;
@property(nonatomic,strong) NSNumber* currentRequestNumber;
@property(nonatomic,strong) UDJUserData* globalData;

@property(nonatomic,strong) IBOutlet UIButton* leaveButton;
@property(nonatomic,strong) IBOutlet UIButton* libraryButton;

@property(nonatomic,strong) IBOutlet UILabel* eventNameLabel;

@property(nonatomic,strong) IBOutlet UIView* voteNotificationView;
@property(nonatomic,strong) IBOutlet UILabel* voteNotificationLabel;
@property(nonatomic,strong) IBOutlet UIImageView* voteNotificationArrowView;

@property(nonatomic,strong) IBOutlet UILabel* playerNameLabel;

// host controls
@property(nonatomic,strong) IBOutlet UIView* hostControlView;
@property(nonatomic,strong) IBOutlet UIButton* playButton;
@property(nonatomic,strong) IBOutlet UISlider* volumeSlider;
@property(nonatomic,strong) IBOutlet UILabel* volumeLabel;
@property(nonatomic,strong) IBOutlet UIButton* controlButton;
@property BOOL playing;

-(void)resetToPlayerResultView:(ExitReason)reason;
-(void)request:(UDJRequest *)request didLoadResponse:(UDJResponse *)response;

@end
