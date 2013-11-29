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

#define CTRLVIEW_HIDDEN_Y           -55
#define CTRLVIEW_SHOWING_Y          0

#import "PlaylistViewController.h"
#import "UDJPlayerData.h"
#import "UDJPlayer.h"
#import "UDJPlaylist.h"
#import "UDJSong.h"
#import "PlaylistEntryCell.h"
#import "LibraryEntryCell.h"
#import "PlaylistEntryCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UDJPlayerManager.h"
#import "UDJClient.h"

@implementation PlaylistViewController

@synthesize currentEvent, playlist, tableView, currentSongTitleLabel, currentSongArtistLabel, selectedSong, statusLabel, currentRequestNumber, globalData, leaveButton, libraryButton, eventNameLabel, voteNotificationView, voteNotificationLabel, voteNotificationArrowView;
@synthesize playerNameLabel;
@synthesize hostControlView, playButton, volumeSlider, volumeLabel, controlButton, playing;

static PlaylistViewController* _sharedPlaylistViewController;



#pragma mark - udj button methods

// handleLeaveEvent: go back to the event results page
-(void)handleLeaveEvent{
    // log out on the server
    [[UDJPlayerData sharedPlayerData] leavePlayer];
    
    // user is no longer in an event, reset currentEvent
    [UDJPlayerData sharedPlayerData].currentPlayer=nil;
    
    // we have no need for this party's playlist
    [[UDJPlaylist sharedUDJPlaylist] clearPlaylist];
    
    // show the event results page
    [self.navigationController popViewControllerAnimated: YES]; 
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

-(IBAction)backButtonClick:(id)sender{
    [self handleLeaveEvent];
}

-(void)resetToPlayerResultView:(ExitReason)reason{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    // let user know why they exited the player
    UIAlertView* alertView;
    if(reason == ExitReasonInactive){
        alertView = [[UIAlertView alloc] initWithTitle:@"Player Inactive" message: @"The player you are trying to access is now inactive." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]; 
    }
    else if(reason == ExitReasonKicked){
        alertView = [[UIAlertView alloc] initWithTitle:@"Kicked" message: @"You have been kicked out of this player." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];  
    }
    [alertView show];
}

#pragma mark - Refresh methods

// refresh method (overidden from superclass)
-(void) refresh{
    [self sendRefreshRequest];
}

// sendRefreshRequest: ask the playlist for a refresh
-(void)sendRefreshRequest{
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    [self.playlist sendPlaylistRequest];
}

-(IBAction)refreshButtonClick:(id)sender{
    [self sendRefreshRequest];
}


// refreshes our list
// NOTE: this is automatically called by UDJConnection when it gets a response
- (void)refreshTableList{
    
    // if the playlist is empty, let them know, and hide the tableview
    if([[UDJPlaylist sharedUDJPlaylist].playlist count] == 0 && playlist.currentSong == nil){
        self.tableView.hidden = YES;
        self.statusLabel.text = @"There are no songs queued up to play.\nGo find some songs to add to the playlist!";
    }
    else{
        self.tableView.hidden = NO;
        self.statusLabel.text = @"";
    }
    
    [self.tableView reloadData];
}


#pragma mark Voting methods

-(void)hideVoteNotification:(id)arg{
    [NSThread sleepForTimeInterval:2];
    [UIView animateWithDuration:1.0 animations:^{
        voteNotificationView.alpha = 0;
    }];
}

// briefly show the vote notification view
-(void)showVoteNotification:(BOOL)up{
    voteNotificationLabel.text = selectedSong.title;
    if(up) voteNotificationArrowView.image = [UIImage imageNamed:@"smalluparrow"];
    else voteNotificationArrowView.image = [UIImage imageNamed:@"smalldownarrow"];
    
    [self.view addSubview: voteNotificationView];
    voteNotificationView.alpha = 0;
    voteNotificationView.frame = CGRectMake(20, 370, 280, 32); // y coord used to be 370
    [UIView animateWithDuration:0.5 animations:^{
        voteNotificationView.alpha = 1;
    } completion:^(BOOL finished){
        if(finished){
            [NSThread detachNewThreadSelector:@selector(hideVoteNotification:) toTarget:self withObject:nil];
        }
    }];
}

// vote: voting helper function
-(void)vote:(BOOL)up{
    
    UIAlertView* notification;
    
    // If user hasn't selected a song, let them know
    if(selectedSong==nil){
        notification = [[UIAlertView alloc] initWithTitle: @"Vote Error" message:@"You haven't selected a song to vote for!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [notification show];
    }
    
    // User can't vote for a song that's already playing
    else if(selectedSong == playlist.currentSong){
        notification = [[UIAlertView alloc] initWithTitle:@"Vote Error" message:@"You can't vote for a song that's already playing!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [notification show];
    }
    
    // If everything is OK, send the vote
    else{
        
        // send the vote request
        self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
        [playlist sendVoteRequest:up forSong:selectedSong];
        
        [self showVoteNotification:up];
    }
}

// upVote: send an upvote request
- (IBAction)voteButtonClick:(id)sender{
    UIButton* button = sender;
    
    // figure out the correct index to vote on
    NSInteger songIndex;
    if([playlist currentSong] != nil) songIndex = button.tag - 1;
    else songIndex = button.tag;  
    selectedSong = [[UDJPlaylist sharedUDJPlaylist] songAtIndex: songIndex];
    
    if([button.imageView.image isEqual: [UIImage imageNamed: @"voteup.png"]]) [self vote:YES];
    else [self vote:NO];
}



#pragma mark - View lifecycle

-(void)initNavBar{
    [self.tabBarController.navigationItem setTitle:[currentEvent name]];
    
    // override  back button
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageButton.frame = CGRectMake(0,0,24,24);
    [imageButton setImage:[UIImage imageNamed:@"white_back_arrow.png"] forState:UIControlStateNormal];
    [imageButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *playersButton = [[UIBarButtonItem alloc] initWithCustomView:imageButton];
    [self.tabBarController.navigationItem setLeftBarButtonItem:playersButton];
    
    // Add control button if we're the host
    [self checkIfHost];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.globalData = [UDJUserData sharedUDJData];
    
    _sharedPlaylistViewController = self;
    
    // set event, event label text
    self.currentEvent = [UDJPlayerData sharedPlayerData].currentPlayer;
    self.eventNameLabel.text = currentEvent.name;
    
    // set delegate
    [UDJPlayerData sharedPlayerData].leaveEventDelegate = self;
    
    // init playlist
    self.playlist = [UDJPlaylist sharedUDJPlaylist];
    self.playlist.playerID = currentEvent.playerID;
    self.playlist.delegate = self;
    self.playlist.playlistDelegate = self;
    
    // set up tab bar stuff
    self.title = NSLocalizedString(@"Playlist", @"Playlist");
    
    [playerNameLabel setText: currentEvent.name];
    self.leaveButton.hidden = [UDJPlayerManager sharedPlayerManager].isInPlayerMode;
    
    self.hostControlView.hidden = YES;
    
    [self initNavBar];
    
    // hide extra cells in table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self sendRefreshRequest];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(playlist.currentSong == nil) return [playlist count];
    return [playlist count]+1;
}

-(NSInteger)voteStatusForSong:(UDJSong*)song{
    NSInteger voteStatus = 0;
    
    // check up voters
    for(int i=0; i < [song.upVoters count]; i++){
        UDJUser* user = [song.upVoters objectAtIndex: i];
        if([user.userID isEqualToString: globalData.userID]) voteStatus = 1;
    }
    // check down voters
    for(int i=0; i < [song.downVoters count]; i++){
        UDJUser* user = [song.downVoters objectAtIndex: i];
        if([user.userID isEqualToString: globalData.userID]) voteStatus = -1;
    }
    
    return voteStatus;
}

// this is used for setting up each cell in the table
- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    PlaylistEntryCell* cell = [TableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PlaylistEntryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger rowNumber = indexPath.row;
	
    // combine song number and name into one string
    UDJSong* song;
    
    // case where a song is playing
    if([playlist songPlaying] != nil){
        if(indexPath.row == 0) song = [playlist songPlaying];
        else song = [playlist songAtIndex: rowNumber - 1];
    }
    // case where NO song is playing
    else{
        song = [playlist songAtIndex: rowNumber];
    }
    
    
    // if there's no current song
    if(song==nil){
        song = [[UDJSong alloc] init];
        song.title = @"";
        song.artist = @"";
        song.adder = nil;
    }
    
    NSString* songText = @"";
    if(song!=nil) songText = [songText stringByAppendingString: song.title];
	cell.songLabel.text = songText;
    cell.artistLabel.text = song.artist;
    
    // figure out who added the song: either "You" or another user
    NSString* adderName;
    NSString* userID = globalData.userID;
    
    // initialize labels
    if(song.adder == nil) adderName = @"";
    else if([song.adder.userID isEqualToString: userID]) adderName = @"You";
    else adderName = song.adder.username;
    cell.addedByLabel.text = [NSString stringWithFormat:@"%@%@", @"Added by ", adderName];
    
    // show vote counts
    cell.upVoteLabel.text = [NSString stringWithFormat:@"%d", [song.upVoters count]];
    cell.downVoteLabel.text = [NSString stringWithFormat:@"%d", [song.downVoters count]];
    
    // initialize up/down vote buttons
    cell.downVoteButton.tag = rowNumber;
    cell.upVoteButton.tag = rowNumber;
    [cell.downVoteButton addTarget:self action:@selector(voteButtonClick:)   
             forControlEvents:UIControlEventTouchUpInside];
    [cell.upVoteButton addTarget:self action:@selector(voteButtonClick:)   
                  forControlEvents:UIControlEventTouchUpInside];
    
    // show/hide buttons if its the song currently playing
    BOOL hidden = (rowNumber == 0 && [playlist songPlaying] != nil);
    cell.upVoteLabel.hidden = hidden;
    cell.downVoteLabel.hidden = hidden;
    cell.upVoteButton.hidden = hidden;
    cell.downVoteButton.hidden = hidden;
    cell.playingImageView.hidden = !hidden;
    cell.playingLabel.hidden = !hidden;
    
    // check vote status, show/hide buttons accordingly
    NSInteger voteStatus = [self voteStatusForSong: song];
    cell.upVoteButton.alpha = 1;
    cell.upVoteButton.enabled = YES;
    cell.downVoteButton.alpha = 1;
    cell.downVoteButton.enabled = YES;
    if(voteStatus == 1){
        cell.upVoteButton.alpha = 0.5;
        cell.upVoteButton.enabled = NO;
    }
    else if(voteStatus == -1){
        cell.downVoteButton.alpha = 0.5;
        cell.downVoteButton.enabled = NO;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}



#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)TableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistEntryCell* cell = (PlaylistEntryCell*)[TableView cellForRowAtIndexPath: indexPath];
    cell.upVoteButton.highlighted = NO;
    cell.downVoteButton.highlighted = NO;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNumber = indexPath.row;
    
    //UDJSong* previouslySelectedSong = self.selectedSong;
    
    // correctly set the selected song
    if([playlist songPlaying] != nil){
        if(indexPath.row == 0) self.selectedSong = [playlist songPlaying];
        else self.selectedSong = [playlist songAtIndex: rowNumber - 1];
    }
    else self.selectedSong = [playlist songAtIndex: rowNumber];
}


#pragma mark - Host methods

-(IBAction)controlsButtonClick:(id)sender{
    // animate to hide/show view
    if(hostControlView.frame.origin.y == CTRLVIEW_HIDDEN_Y){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.3];
        hostControlView.frame =  CGRectMake(0, CTRLVIEW_SHOWING_Y, 320, 50);
        [UIView commitAnimations];        
    }
    else if(hostControlView.frame.origin.y == CTRLVIEW_SHOWING_Y){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.3];
        hostControlView.frame =  CGRectMake(0, CTRLVIEW_HIDDEN_Y, 320, 50);
        [UIView commitAnimations];        
    }
}

-(void)updateVolumeAndState:(NSDictionary*)responseDict{
    // get volume of player
    NSNumber* volume = [responseDict objectForKey: @"volume"];
    volumeLabel.text = [NSString stringWithFormat: @"%d", [volume intValue]];
    volumeSlider.value = [volume intValue];
    
    // get state of player
    NSString* state = [responseDict objectForKey: @"state"];
    if([state isEqualToString: @"playing"]){
        [playButton setImage: [UIImage imageNamed:@"pausetoggle.png"] forState: UIControlStateNormal];
        playing = YES;
    }
    else{
        [playButton setImage: [UIImage imageNamed:@"playtoggle.png"] forState: UIControlStateNormal];
        playing = NO;
    }
}

-(void)checkIfHost{
    if([globalData.userID isEqualToString: currentEvent.owner.userID]){
        UIBarButtonItem* controlsButton = [[UIBarButtonItem alloc] initWithTitle:@"Controls" style:UIBarButtonItemStyleBordered target:self action:@selector(controlsButtonClick:)];
        [self.tabBarController.navigationItem setRightBarButtonItem:controlsButton];
        hostControlView.hidden = NO;
        hostControlView.frame =  CGRectMake(0, CTRLVIEW_HIDDEN_Y, 320, 50);
    }
}

-(IBAction)playButtonClick:(id)sender{
    UIButton* button = sender;
    
    playing = !playing;
    
    NSString* state;
    if(!playing) {
        [button setImage: [UIImage imageNamed:@"playtoggle.png"] forState:UIControlStateNormal];
        state = @"paused";
    }
    else {
        [button setImage: [UIImage imageNamed:@"pausetoggle.png"] forState: UIControlStateNormal];
        state = @"playing";
    }
    
    //[POST] /udj/users/user_id/players/player_id/state
    [[UDJPlayerData sharedPlayerData] setState: state];
}

-(IBAction)volumeSliderChanged:(id)sender{
    UISlider* slider = sender;
    NSInteger value = slider.value;
    [volumeLabel setText: [NSString stringWithFormat: @"%d", value]];
}

-(IBAction)volumeSliderDoneChanging:(id)sender{
    UISlider* slider = sender;
    NSInteger value = slider.value;
    [[UDJPlayerData sharedPlayerData] setVolume: value];
}

//-(void)setVolume:(NSInteger)volume


#pragma mark - Response handling

-(void)playlistDidUpdate:responseDictionary{
    [self refreshTableList];
    [self updateVolumeAndState: responseDictionary];
    
    // hide the pulldown refresh
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0];
}



// Handle responses from the server
- (void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response { 
    
    NSLog(@"Playlist: status code %d", [response statusCode]);
    NSLog(@"%@",[response bodyAsString]);
    
    NSNumber* requestNumber = request.userData;
    NSDictionary* headerDict = [response allHeaderFields];
    
    NSLog(@"response %d, waiting on %d", [requestNumber intValue], [currentRequestNumber intValue]);

    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    //NSLog([NSString stringWithFormat:@"code %d", response.statusCode]);
    
    // check if player is inactive
    if(response.statusCode == 404){
        if([[headerDict objectForKey: @"X-Udj-Missing-Resource"] isEqualToString:@"player"])
            [self resetToPlayerResultView:ExitReasonInactive];
    }
    else if([request isDELETE]){
        if([response isOK]) [self handleLeaveEvent];
    }
    else if([request isPUT]){
        if([response isOK]) [self sendRefreshRequest];
    }
    else if([request isPOST]){
        if([response isOK]) [self sendRefreshRequest];
    }
    
    // Check if the ticket expired or if the user was kicked from the player
    if(response.statusCode == 401){
        NSString* authenticate = [headerDict objectForKey: @"WWW-Authenticate"];
        if([authenticate isEqualToString: @"ticket-hash"]){
            [globalData renewTicket];
        }
        else if([authenticate isEqualToString: @"kicked"]){
            [self resetToPlayerResultView: ExitReasonKicked];
        }
    }
    
    //self.currentRequestNumber = [NSNumber numberWithInt: -1];
}


@end
