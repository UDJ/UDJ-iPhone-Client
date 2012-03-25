//
//  PlaylistViewController.m
//  UDJ
//
//  Created by Matthew Graf on 12/6/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlaylistViewController.h"
#import "UDJEventData.h"
#import "UDJEvent.h"
#import "UDJPlaylist.h"
#import "UDJSong.h"
#import "LibrarySearchViewController.h"
#import "PlaylistEntryCell.h"
#import "LibraryEntryCell.h"
#import "EventGoerViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PlaylistViewController

@synthesize currentEvent, playlist, tableView, currentSongTitleLabel, currentSongArtistLabel, selectedSong, statusLabel, currentRequestNumber, globalData, leavingBackgroundView, leavingView, leaveButton, libraryButton, eventNameLabel;

static PlaylistViewController* _sharedPlaylistViewController;

+(PlaylistViewController*) sharedPlaylistViewController{
    return _sharedPlaylistViewController;
}

-(void)showEventGoers{
    EventGoerViewController* eventGoerViewController = [[EventGoerViewController alloc] initWithNibName:@"EventGoerViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:eventGoerViewController animated:YES];
}


-(void)removeSong{
    NSInteger eventIdParam = [UDJEventData sharedEventData].currentEvent.eventId;
    [[UDJConnection sharedConnection] sendSongRemoveRequest:selectedSong.songId eventId:eventIdParam];
    UIAlertView* notification = [[UIAlertView alloc] initWithTitle:@"Song Removed" message:@"Your song will be removed from the playlist." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [notification show];
}

// leaveEvent: log the client out of the event, return to event list
- (IBAction)leaveButtonClick:(id)sender{
    // show "Leaving" view
    [self toggleLeavingView: YES];
    
    // increment requestCount and send leave event request
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    [[UDJEventData sharedEventData] leaveEvent];
}

// handleLeaveEvent: go back to the event results page
-(void)handleLeaveEvent{
    // user is no longer in an event, reset currentEvent
    [UDJEventData sharedEventData].currentEvent=nil;
    
    // we have no need for this party's playlist
    [[UDJPlaylist sharedUDJPlaylist] clearPlaylist];
    
    // show the event results page
    [self.navigationController popViewControllerAnimated:YES]; 
}

// loadLibrary: push the library search view
- (IBAction)showLibrary:(id)sender{
    LibrarySearchViewController* librarySearchViewController = [[LibrarySearchViewController alloc] initWithNibName:@"LibrarySearchViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:librarySearchViewController animated:YES];
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
    self.currentSongTitleLabel.text = [UDJPlaylist sharedUDJPlaylist].currentSong.title;
    NSString* artistText = [NSString stringWithFormat:@"by %@",[UDJPlaylist sharedUDJPlaylist].currentSong.artist];
    if([UDJPlaylist sharedUDJPlaylist].currentSong == nil) artistText = @"";
    self.currentSongArtistLabel.text = artistText;
    
    // if the playlist is empty, let them know, and hide the tableview
    if([[UDJPlaylist sharedUDJPlaylist].playlist count] == 0){
        self.tableView.hidden = YES;
        self.statusLabel.text = @"There are no songs queued up to play next. Click the Library button to add some to the playlist!";
    }
    else{
        self.tableView.hidden = NO;
        self.statusLabel.text = @"";
    }
    
    [self.tableView reloadData];
}

// vote: voting helper function
-(void)vote:(BOOL)up{
    
    UIAlertView* notification;
    if(selectedSong==nil){
        notification = [[UIAlertView alloc] initWithTitle: @"Vote Error" message:@"You haven't selected a song to vote for!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [notification show];
    }
    else if(selectedSong == playlist.currentSong){
        notification = [[UIAlertView alloc] initWithTitle:@"Vote Error" message:@"You can't vote for a song that's already playing!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [notification show];
    }
    else{
        NSNumber* songIdAsNumber = [NSNumber numberWithInteger:selectedSong.songId];
        // haven't voted for this song yet
        if(![[playlist.voteRecordKeeper objectForKey:songIdAsNumber] boolValue]){
            [playlist.voteRecordKeeper setObject:[NSNumber numberWithBool:YES] forKey:songIdAsNumber];
            
            [[UDJConnection sharedConnection] sendVoteRequest:up songId:selectedSong.songId eventId:currentEvent.eventId];
            [self sendRefreshRequest];
            // let the client know it sent a vote
            NSString* msg = @"Your vote for ";
            msg = [msg stringByAppendingString:selectedSong.title];
            msg = [msg stringByAppendingString:@" has been sent!"];
            notification = [[UIAlertView alloc] initWithTitle:@"Vote Sent" message:msg delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
        // have already voted for the song
        else{
            NSString* msg = @"You have already voted for ";
            msg = [msg stringByAppendingString:selectedSong.title];
            msg = [msg stringByAppendingString:@"!"];
            notification = [[UIAlertView alloc] initWithTitle:@"Vote Denied" message:msg delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
        [notification show];
    }
}

// upVote: have UDJConnection send an upvote request
- (void)upVote{
    [self vote:YES];
}

// downVote: have UDJConnection send a downvote request
- (void)downVote{
    [self vote:NO];
}


// Show or hide the "Leaving event" view; active = YES will show the view
-(void) toggleLeavingView:(BOOL) active{
    leavingBackgroundView.hidden = !active;
    leavingView.hidden = !active;
    
    // TODO: disable toolbar?
}

// When user presses cancel, hide leaving view and let controller know
// we aren't waiting on any requests
-(IBAction)cancelButtonClick:(id)sender{
    self.currentRequestNumber = nil;
    [self toggleLeavingView: NO];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.globalData = [UDJData sharedUDJData];
    
    _sharedPlaylistViewController = self;
    
    // set event, event label text
    self.currentEvent = [UDJEventData sharedEventData].currentEvent;
	self.eventNameLabel.text = currentEvent.name;
    
    // set delegate
    [UDJEventData sharedEventData].leaveEventDelegate = self;
    
    // init playlist
    self.playlist = [UDJPlaylist sharedUDJPlaylist];
    self.playlist.eventId = currentEvent.eventId;
    self.playlist.delegate = self;
    [self sendRefreshRequest];
    
    // initialize leaving view
    leavingView.layer.cornerRadius = 8;
    leavingView.layer.borderColor = [[UIColor whiteColor] CGColor];
    leavingView.layer.borderWidth = 3;
    
    [self toggleLeavingView: NO];
    
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self sendRefreshRequest];
}

- (void)viewWillDisappear:(BOOL)animated
{
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
    return [playlist count];
}

// this is used for setting up each cell in the table
- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    PlaylistEntryCell* cell = [TableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PlaylistEntryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
    // combine song number and name into one string
    UDJSong* song;
    NSInteger rowNumber = indexPath.row;
	song = [playlist songAtIndex:rowNumber];
    
    // if there's no current song, show "nothing" and "nobody" as title/artist
    if(song==nil){
        song = [[UDJSong alloc] init];
        song.title = @"nothing";
        song.artist = @"nobody";
        song.adderName = @"nobody";
    }
    
    NSString* songText = @"";
    if(song!=nil) songText = [songText stringByAppendingString: song.title];
	cell.songLabel.text = songText;
    cell.artistLabel.text = [NSString stringWithFormat: @"%@%@", @"By ", song.artist, nil];
    
    NSString* adderName;
    UDJConnection* connection = [UDJConnection sharedConnection];
    NSInteger userId = [connection.userID intValue];
    if(song.adderId == userId) adderName = @"You";
    else adderName = song.adderName;
    cell.addedByLabel.text = [NSString stringWithFormat:@"%@%@", @"Added by ", adderName];
    
    cell.upVoteLabel.text = [NSString stringWithFormat:@"%d", song.upVotes];
    cell.downVoteLabel.text = [NSString stringWithFormat:@"%d", song.downVotes];
    
    cell.downVoteButton.tag = rowNumber;
    cell.upVoteButton.tag = rowNumber;
    
    BOOL extrasHidden = (song != selectedSong);
    cell.addedByLabel.hidden=extrasHidden;
    cell.upVoteLabel.hidden=extrasHidden;
    cell.downVoteLabel.hidden=extrasHidden;
    cell.upVoteButton.hidden = extrasHidden;
    cell.downVoteButton.hidden = extrasHidden;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if([playlist songAtIndex:row]==selectedSong) return 64;
    return 48.0;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowNumber = indexPath.row;
    selectedSong = [playlist songAtIndex:rowNumber];
    /*
    UIAlertView* songOptionBox = [[UIAlertView alloc] initWithTitle: selectedSong.title message: selectedSong.artist delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    // include vote buttons if its not the song playing
    //[songOptionBox addButtonWithTitle:@"Share"];
    [songOptionBox addButtonWithTitle:@"Vote Up"];
    [songOptionBox addButtonWithTitle:@"Vote Down"];
    // include remove button if this user added the song
    //UDJConnection* connection = [UDJConnection sharedConnection];
    //if([connection.userID intValue]== selectedSong.adderId) [songOptionBox addButtonWithTitle:@"Remove Song"];
    [songOptionBox show];
    [songOptionBox release];*/
    
    [self.tableView reloadData];
    [self.tableView cellForRowAtIndexPath:indexPath].selected = YES;
    PlaylistEntryCell* cell = (PlaylistEntryCell*) [self.tableView cellForRowAtIndexPath:indexPath];
    cell.downVoteButton.highlighted = NO;
    cell.upVoteButton.highlighted = NO;
    
}


#pragma mark Response handling

// handlePlaylistResponse: this is done asynchronously from the send method so the client can do other things meanwhile
// NOTE: this calls [playlistView refreshTableList] for you!
- (void)handlePlaylistResponse:(RKResponse*)response{
    
    NSMutableArray* tempList = [NSMutableArray new];
    
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    // response dict: holds current song and array of songs
    NSDictionary* responseDict = [parser objectFromString:[response bodyAsString] error:nil];
    UDJSong* currentSong = [UDJSong songFromDictionary:[responseDict objectForKey:@"current_song"] isLibraryEntry:NO];
    
    // the array holding the songs on the playlist
    NSArray* songArray = [responseDict objectForKey:@"active_playlist"];
    for(int i=0; i<[songArray count]; i++){
        NSDictionary* songDict = [songArray objectAtIndex:i];
        UDJSong* song = [UDJSong songFromDictionary:songDict isLibraryEntry:NO];
        [tempList addObject:song];
        
        NSNumber* songIdAsNumber = [NSNumber numberWithInteger:song.songId];
        // if this song hasnt been added to the playlist before i.e. isnt in the voteRecordKeeper
        if([[UDJPlaylist sharedUDJPlaylist].voteRecordKeeper objectForKey:songIdAsNumber]==nil){
            // set its songId to NO, meaning the user hasn't voted for it yet
            NSNumber* no =[NSNumber numberWithBool:NO];
            [[UDJPlaylist sharedUDJPlaylist].voteRecordKeeper setObject:no forKey:songIdAsNumber];
        }
    }
    
    [[UDJPlaylist sharedUDJPlaylist] setPlaylist: tempList];
    [[UDJPlaylist sharedUDJPlaylist] setCurrentSong: currentSong];
    
    [self refreshTableList];
    
}


// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
    
    NSLog(@"Got response in playlist view");
    
    NSNumber* requestNumber = request.userData;
    
    //NSLog([NSString stringWithFormat: @"response number %d, waiting on %d", [requestNumber intValue], [currentRequestNumber intValue]]);

    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if the event has ended
    if(response.statusCode == 410){
        //[self resetToEventView];
    }
    else if ([request isGET]) {
        [self handlePlaylistResponse:response];        
    }
    else if([request isDELETE]){
        if([response isOK]) [self handleLeaveEvent];
    }
    
    self.currentRequestNumber = nil;
}


@end
