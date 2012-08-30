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
#import "RestKit/RestKit.h"
#import "RestKit/RKJSONParserJSONKit.h"
#import "UDJPlayerData.h"
#import "LibraryEntryCell.h"
#import "UDJPlaylist.h"


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
    
    globalData = [UDJData sharedUDJData];
    MAX_RESULTS = 100;
    
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // tell UDJData that this is the songAddDelegate
    [UDJData sharedUDJData].songAddDelegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    [UDJData sharedUDJData].songAddDelegate = nil;
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

-(void)sendAddSongRequest:(unsigned long long)librarySongId playerID:(NSInteger)playerID{
    RKClient* client = [RKClient sharedClient];
    
    //create url [PUT] /udj/events/event_id/active_playlist/songs
    NSString* urlString = [NSString stringWithFormat:@"%@%@%d%@%llu",client.baseURL,@"/players/",playerID,@"/active_playlist/songs/",librarySongId, nil];

    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = artistViewController;
    request.queue = client.requestQueue;
    request.method = RKRequestMethodPUT;
    request.additionalHTTPHeaders = globalData.headers;
    
    // remember the song we are adding
    request.userData = [NSNumber numberWithInt: librarySongId];
    
    //TODO: find a way to keep track of the requests
    //[currentRequests setObject:@"songAdd" forKey:request];
    [request send]; 
}

-(IBAction)addButtonClick:(id)sender{
    UIButton* button = (UIButton*)sender;
    LibraryEntryCell* parentCell = (LibraryEntryCell*)button.superview.superview;
    [self sendAddSongRequest: parentCell.librarySongId playerID: [UDJPlayerData sharedPlayerData].currentPlayer.playerID];
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
    cell.addButton.tag = song.librarySongId;
    cell.addButton.titleLabel.text = song.title;
    cell.librarySongId = song.librarySongId;
    
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
    
    RKClient* client = [RKClient sharedClient];
    
    // create URL
    
    NSString* urlString = [client.baseURL absoluteString];
    artist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSInteger playerID = [UDJPlayerData sharedPlayerData].currentPlayer.playerID;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%@",@"/players/",playerID,@"/available_music/artists/",artist,nil];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = [UDJData sharedUDJData];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;
    
    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: [UDJData sharedUDJData].headers];
    [requestHeaders setValue:@"songAddDelegate" forKey:@"delegate"];
    request.additionalHTTPHeaders = requestHeaders;
    
    // track current request number
    currentRequestNumber = [NSNumber numberWithInt: [UDJData sharedUDJData].requestCount];
    request.userData = [NSNumber numberWithInt: [UDJData sharedUDJData].requestCount++];
    
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
    
    RKClient* client = [RKClient sharedClient];
    
    // create URL
    
    NSString* urlString = [client.baseURL absoluteString];
    query = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSInteger playerID = [UDJPlayerData sharedPlayerData].currentPlayer.playerID;
    urlString = [urlString stringByAppendingFormat:@"%@%d%@%@%@%d",@"/players/",playerID,@"/available_music?query=",query, @"&max_results=", MAX_RESULTS, nil];
    
    // create request
    RKRequest* request = [RKRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = [UDJData sharedUDJData];
    request.queue = client.requestQueue;
    request.method = RKRequestMethodGET;

    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: [UDJData sharedUDJData].headers];
    [requestHeaders setValue:@"songAddDelegate" forKey:@"delegate"];
    request.additionalHTTPHeaders = requestHeaders;
    
    // track current request number
    currentRequestNumber = [NSNumber numberWithInt: [UDJData sharedUDJData].requestCount];
    request.userData = [NSNumber numberWithInt: [UDJData sharedUDJData].requestCount++];
    
    //send request
    [request send]; 
}

#pragma mark - Response handling

-(void)resetToPlayerResultView{
    
     [self.navigationController.navigationController popViewControllerAnimated:YES];
    
    // alert user that player is inactive
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Player Inactive" message: @"The player you are trying to access is now inactive." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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

-(void)handleSearchResults:(RKResponse *)response{
    UDJSongList* tempList = [UDJSongList new];
    RKJSONParserJSONKit* parser = [RKJSONParserJSONKit new];
    NSArray* songArray = [parser objectFromString:[response bodyAsString] error:nil];
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
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response { 
    
    NSLog(@"status code %d", [response statusCode]);
    
    NSDictionary* headerDict = [response allHeaderFields];
    
    // NOTE: removed for now because there's no cancel option anywhere
    //if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if player has ended
    if(response.statusCode == 404){
        NSLog(@"missing resource: %@", [headerDict objectForKey: @"X-Udj-Missing-Resource"]);
        if([[headerDict objectForKey: @"X-Udj-Missing-Resource"] isEqualToString:@"player"])
            [self resetToPlayerResultView];
    }
    else if ([request isGET] && [response isOK]) {
        [self handleSearchResults: response];
    }
    
    // Song conflicts i.e. song we tried to add is already on the playlist
    else if(response.statusCode == 409){
        // get the song number, vote up
        NSNumber* songNumber = request.userData;
        [[UDJPlaylist sharedUDJPlaylist] sendVoteRequest:YES songId: [songNumber intValue]];
    }
    
    // check if our ticket was invalid
    if(response.statusCode == 401 && [[headerDict objectForKey: @"WWW-Authenticate"] isEqualToString: @"ticket-hash"])
        [globalData renewTicket];
}

@end
