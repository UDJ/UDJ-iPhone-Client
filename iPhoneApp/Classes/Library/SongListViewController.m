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

#import "SongListViewController.h"
#import "JSONKit.h"
#import "UDJPlayerData.h"
#import "LibraryEntryCell.h"
#import "UDJPlaylist.h"
#import "UDJClient.h"

static const NSInteger MAX_RESULTS = 100;

typedef enum{
    ExitReasonInactive,
    ExitReasonKicked
} ExitReason;

@implementation SongListViewController

@synthesize statusLabel, searchIndicatorView, currentRequestNumber, songTableView, resultList, globalData, lastQuery, lastQueryType;
@synthesize addNotificationView, addNotificationLabel, searchBar;
@synthesize artistViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    globalData = [UDJUserData sharedUDJData];
    
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // tell UDJData that this is the songAddDelegate
    [UDJUserData sharedUDJData].songAddDelegate = self;
    
    // hide extra table view cells
    self.songTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    [UDJUserData sharedUDJData].songAddDelegate = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Song adding


-(void)hideAddNotification:(id)arg{
    [NSThread sleepForTimeInterval:2];
    [UIView animateWithDuration:1.0 animations:^{
        addNotificationView.alpha = 0;
    }];
}

// briefly show the vote notification view
-(void)showAddNotification:(NSString*)title{
    addNotificationLabel.text = title;
    
    [self.view addSubview: addNotificationView];
    addNotificationView.alpha = 0;
    addNotificationView.frame = CGRectMake(20, 370, 280, 32);
    [UIView animateWithDuration:0.5 animations:^{
        addNotificationView.alpha = 1;
    } completion:^(BOOL finished){
        if(finished){
            [NSThread detachNewThreadSelector:@selector(hideAddNotification:) toTarget:self withObject:nil];
        }
    }];
}

-(void)sendAddRequestForSong:(UDJSong*)song playerID:(NSString*)playerID{
    UDJClient* client = [UDJClient sharedClient];
    
    //create url [PUT] /udj/events/event_id/active_playlist/songs
    NSString* urlString = [NSString stringWithFormat: @"%@/players/%@/active_playlist/songs/%@/%@", client.baseURLString, playerID, song.libraryID, song.songID, nil];
    
    // create request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = artistViewController;
    request.method = UDJRequestMethodPUT;
    request.additionalHTTPHeaders = globalData.headers;
    
    [request send];
}

-(IBAction)addButtonClick:(id)sender{
    UIButton* button = (UIButton*)sender;
    LibraryEntryCell* parentCell = (LibraryEntryCell*)button.superview.superview;
    [self sendAddRequestForSong:parentCell.song playerID: [UDJPlayerData sharedPlayerData].currentPlayer.playerID];
    [self showAddNotification: button.titleLabel.text];
}

#pragma mark - Tableview data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [resultList count];
}

- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    LibraryEntryCell* cell = [TableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[LibraryEntryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UDJSong* song = [resultList songAtIndex:indexPath.row];
    cell.songLabel.text = song.title;
    cell.artistLabel.text = song.artist;
    cell.addButton.titleLabel.text = song.title;
    cell.song = song;
    
    [cell.addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - UI, SearchBar Events

-(IBAction)artistButtonClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar{
     
    [searchBar sizeToFit];    
    [searchBar setShowsCancelButton:NO animated:YES]; 
    [searchBar setFrame: CGRectMake(65, 0, 252, 44)];
    
    [self getSongsByQuery: theSearchBar.text];
    [theSearchBar resignFirstResponder];
    searchBar.showsScopeBar = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar{  
    [searchBar sizeToFit];    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar setFrame: CGRectMake(65, 0, 252, 44)];
    [searchBar resignFirstResponder];
    searchBar.showsScopeBar = NO;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar*)theSearchBar{
    searchBar.showsScopeBar = YES;  
    [searchBar sizeToFit];    
    [searchBar setShowsCancelButton:YES animated:YES]; 
    [searchBar setFrame: CGRectMake(65, 0, 252, 44)];
}




#pragma mark - Search request methods

-(void)getSongsByArtist:(NSString *)artist{
    // /udj/players/player_id/available_music/artists/artist_name
    
    // update the status label
    statusLabel.text = [NSString stringWithFormat: @"Getting songs by %@", artist, nil];
    songTableView.hidden = YES;
    lastQueryType = UDJQueryTypeArtist;
    lastQuery = artist;
    
    UDJClient* client = [UDJClient sharedClient];
    
    // create URL
    
    NSString* urlString = client.baseURLString;
    artist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString* playerID = [UDJPlayerData sharedPlayerData].currentPlayer.playerID;
    urlString = [urlString stringByAppendingFormat:@"/players/%@/available_music/artists/%@", playerID, artist, nil];
    
    // create request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = [UDJUserData sharedUDJData];
    request.method = UDJRequestMethodGET;
    
    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: [UDJUserData sharedUDJData].headers];
    [requestHeaders setValue:@"songAddDelegate" forKey:@"delegate"];
    request.additionalHTTPHeaders = requestHeaders;
    
    // track current request number
    currentRequestNumber = [NSNumber numberWithInt: [UDJUserData sharedUDJData].requestCount];
    request.userData = [NSNumber numberWithInt: [UDJUserData sharedUDJData].requestCount++];
    
    //send request
    [request send]; 
    
}

-(void)getSongsByQuery:(NSString *)query{
    // /udj/players/player_id/available_music?query=query{&max_results=maximum_number_of_results}
    
    // update the status label
    statusLabel.text = [NSString stringWithFormat: @"Searching for '%@'", query, nil];
    searchIndicatorView.hidden = NO;
    songTableView.hidden = YES;
    lastQueryType = UDJQueryTypeGeneric;
    lastQuery = query;
    
    UDJClient* client = [UDJClient sharedClient];
    
    // create URL
    
    NSString* urlString = client.baseURLString;
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString* playerID = [UDJPlayerData sharedPlayerData].currentPlayer.playerID;
    urlString = [urlString stringByAppendingFormat:@"%@%@%@%@%@%d",@"/players/",playerID,@"/available_music?query=",query, @"&max_results=", MAX_RESULTS, nil];
    
    // create request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = [UDJUserData sharedUDJData];
    request.method = UDJRequestMethodGET;

    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: [UDJUserData sharedUDJData].headers];
    [requestHeaders setValue:@"songAddDelegate" forKey:@"delegate"];
    request.additionalHTTPHeaders = requestHeaders;
    
    // track current request number
    currentRequestNumber = [NSNumber numberWithInt: [UDJUserData sharedUDJData].requestCount];
    request.userData = [NSNumber numberWithInt: [UDJUserData sharedUDJData].requestCount++];
    
    //send request
    [request send]; 
}

#pragma mark - Response handling

-(void)resetToPlayerResultView:(ExitReason)reason{
    
     [self.navigationController.navigationController popViewControllerAnimated:YES];
    
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

-(void)refreshStatusLabel{
    if(lastQueryType == UDJQueryTypeArtist){
        statusLabel.text = [NSString stringWithFormat: @"Songs by %@", lastQuery];
    }
    else{
        statusLabel.text = [NSString stringWithFormat: @"Songs matching '%@'", lastQuery];
    }
    
    if([resultList count] == 0){
        statusLabel.text = [NSString stringWithFormat: @"No songs matching '%@'", lastQuery];
    }
}

-(void)handleSearchResults:(UDJResponse *)response{
    UDJSongList* tempList = [UDJSongList new];
    NSArray* songArray = [[response bodyAsString] objectFromJSONString];
    for(int i=0; i<[songArray count]; i++){
        NSDictionary* songDict = [songArray objectAtIndex:i];
        UDJSong* song = [UDJSong songFromDictionary:songDict isLibraryEntry:YES];
        [tempList addSong:song];
    }
    
    self.resultList = tempList;
    
    // refresh table view, hide activity indicator
    [songTableView reloadData];
    songTableView.hidden = NO;
    searchIndicatorView.hidden = YES;
    
    [self refreshStatusLabel];
}

// Handle responses from the server
- (void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response { 
    
    NSLog(@"status code %d", [response statusCode]);
    
    NSDictionary* headerDict = [response allHeaderFields];
    
    // NOTE: removed for now because there's no cancel option anywhere
    //if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if player has ended
    if(response.statusCode == 404){
        NSLog(@"missing resource: %@", [headerDict objectForKey: @"X-Udj-Missing-Resource"]);
        if([[headerDict objectForKey: @"X-Udj-Missing-Resource"] isEqualToString:@"player"])
            [self resetToPlayerResultView:ExitReasonInactive];
    }
    else if ([request isGET] && [response isOK]) {
        [self handleSearchResults: response];
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
}

@end
