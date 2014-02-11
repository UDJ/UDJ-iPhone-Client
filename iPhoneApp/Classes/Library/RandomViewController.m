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

#import "RandomViewController.h"
#import "JSONKit.h"
#import "UDJPlayerData.h"
#import "LibraryEntryCell.h"
#import "UDJPlaylist.h"
#import "UDJClient.h"

typedef unsigned long long UDJLibraryID;
typedef enum{
    ExitReasonInactive,
    ExitReasonKicked
} ExitReason;

@implementation RandomViewController

@synthesize resultList, globalData, currentRequestNumber;
@synthesize addNotificationView, addNotificationLabel;

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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    globalData = [UDJUserData sharedUDJData];
    MAX_RESULTS = 50;
    
    [self sendRandomSongRequest];
    
    // hide extra cells in table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    request.delegate = self;
    request.method = UDJRequestMethodPUT;
    request.additionalHTTPHeaders = globalData.headers;
       
    [request send]; 
}

-(IBAction)addButtonClick:(id)sender{
    UIButton* button = (UIButton*)sender;
    // TODO: admittedly, storing the song index in the button tag is pretty janky,
    // should implement a cleaner solution "later"
    UDJSong *song = [self.resultList songAtIndex:button.tag];
    [self sendAddRequestForSong:song playerID: [UDJPlayerData sharedPlayerData].currentPlayer.playerID];
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
    cell.song = song;
    cell.addButton.titleLabel.text = song.title;
    cell.addButton.tag = [indexPath row];
    
    [cell.addButton addTarget:self action:@selector(addButtonClick:)   
             forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


#pragma mark - Random song request methods

-(void)refresh{
    [self sendRandomSongRequest];
}

-(void)sendRandomSongRequest{
    
    UDJClient* client = [UDJClient sharedClient];
    
    //create url [GET] /udj/events/event_id/available_music/random_songs{?max_randoms=number_desired}
    NSString* urlString = client.baseURLString;
    urlString = [urlString stringByAppendingFormat:@"/players/%@/available_music/random_songs?max_randoms=%d", [UDJPlayerData sharedPlayerData].currentPlayer.playerID, MAX_RESULTS, nil];
    
    // create request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self;
    request.method = UDJRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    
    //send request
    [request send]; 
}

-(IBAction)refreshButtonClick:(id)sender{
    [self sendRandomSongRequest];
}



#pragma mark - Response handling

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
    [self.tableView reloadData];
}

// Handle responses from the server
- (void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response { 
    
    NSLog(@"status code %d", [response statusCode]);
    
    NSDictionary* headerDict = [response allHeaderFields];
    
    // check if player has ended
    if(response.statusCode == 404){
        if([[headerDict objectForKey: @"X-Udj-Missing-Resource"] isEqualToString:@"player"])
            [self resetToPlayerResultView:ExitReasonInactive];
    }
    else if ([request isGET] && [response isOK]) {
        [self handleSearchResults: response];
    }
    
    // Check if the ticket expired or if the user was kicked from the player
    if(response.statusCode == 401){
        NSString* authenticate = [headerDict objectForKey: @"WWW-Authenticate"];
        NSLog(@"reason: %@", authenticate);
        if([authenticate isEqualToString: @"ticket-hash"]){
            [globalData renewTicket];
        }
        else if([authenticate isEqualToString: @"kicked"]){
            [self resetToPlayerResultView: ExitReasonKicked];
        }
    }
    
    // hide the pulldown refresh
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0];

}

@end
