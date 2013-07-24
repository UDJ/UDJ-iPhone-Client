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

#import "ArtistsViewController.h"
#import "UDJPlayerData.h"
#import "SongListViewController.h"
#import "UDJClient.h"
#import "UDJPlaylist.h"
#import "JSONKit.h"

typedef enum{
    ExitReasonInactive,
    ExitReasonKicked
} ExitReason;

@implementation ArtistsViewController

@synthesize searchBar, artistsArray, globalData;
@synthesize statusLabel, searchIndicatorView, currentRequestNumber;

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
    
    // get global data
    globalData = [UDJUserData sharedUDJData];
    
    // intialize artists array
    artistsArray = [[NSMutableArray alloc] initWithCapacity:50];
    
    // get artists
    [self sendArtistsRequest];
    
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [self initNavBar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showNavBar];
    [self.navigationItem setTitle:@""];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Navigation bar setup

-(void)showNavBar{
    // hide tab bar nav controller, set up our own nav bar
    [self.tabBarController.navigationController setNavigationBarHidden:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)initNavBar{
    UIColor* blueTintColor = [UIColor colorWithRed:(35.0/255.0) green:(59.0/255.0) blue:(79.0/255.0) alpha:1];
    
    [self.navigationItem setTitle:@""];
    [self.navigationController.navigationBar setTintColor:blueTintColor];
    
    
    // set up search bar
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [searchBar setTintColor:blueTintColor];
    [searchBar setPlaceholder:@"Search for songs"];
    [searchBar setDelegate:self];
    UIBarButtonItem* searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    [self.navigationItem setLeftBarButtonItem: searchBarItem];
    [searchBar sizeToFit];
}


#pragma mark Search bar methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar{
    [theSearchBar resignFirstResponder];
    [self.navigationItem setTitle:@"Artists"];
    SongListViewController* songListViewController = [[SongListViewController alloc] initWithNibName:@"SongListViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController: songListViewController animated:YES];
    [songListViewController getSongsByQuery: theSearchBar.text];
     
    [searchBar sizeToFit];    
    [searchBar setShowsCancelButton:NO animated:YES]; 
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar{  
    [searchBar sizeToFit];    
    [searchBar setShowsCancelButton:NO animated:YES];    
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar*)theSearchBar{
    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:YES animated:YES];
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [artistsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // show artists name
    cell.textLabel.text = [artistsArray objectAtIndex: indexPath.row];
    
    // cosmetics
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* artistName = [artistsArray objectAtIndex: indexPath.row];
    
    [self.navigationItem setTitle:@"Artists"];
    
    // transition to SongListViewController
    SongListViewController* songListViewController = [[SongListViewController alloc] initWithNibName:@"SongListViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:songListViewController animated:YES];
    songListViewController.artistViewController = self;
    [songListViewController getSongsByArtist: artistName];
    
    NSLog(@"setting title to artsits");
}


#pragma mark - Request methods

-(void)refresh{
    [self sendArtistsRequest];
}

-(void)sendArtistsRequest{
    
    // update status label
    //[statusLabel setText: @"Getting artists from library"];
    
    
    // gets JSON array of artists
    UDJClient* client = [UDJClient sharedClient];
    
    // create url /players/player_id/available_music/artists
    NSString* urlString = client.baseURLString;
    urlString = [urlString stringByAppendingFormat:@"/players/%@/available_music/artists",[UDJPlayerData sharedPlayerData].currentPlayer.playerID,nil];
    
    // create request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self;
    request.method = UDJRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    
    // track current request number
    currentRequestNumber = [NSNumber numberWithInt: [UDJUserData sharedUDJData].requestCount];
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
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

-(void)handleArtistResponse:(UDJResponse*)response{
    
    // clear the current artists array
    [artistsArray removeAllObjects];
    
    // create a JSON parser and parse the artist names
    NSArray* responseArray = [[response bodyAsString] objectFromJSONString];
    for(int i=0; i<[responseArray count]; i++)
        [artistsArray addObject: [responseArray objectAtIndex: i]];
    
    // sort array and reload table data
    [artistsArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.tableView reloadData];
    
    // update status label
    [statusLabel setText: @"Artists"];
    searchIndicatorView.hidden = YES;

}

// Handle responses from the server
- (void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response { 
    
    //NSNumber* requestNumber = request.userData;
    NSDictionary* headerDict = [response allHeaderFields];
    
    NSLog(@"status code %d", [response statusCode]);
    
    //if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if player has ended
    
    if(response.statusCode == 404){
        if([[headerDict objectForKey: @"X-Udj-Missing-Resource"] isEqualToString:@"player"])
            [self resetToPlayerResultView:ExitReasonInactive];
    }
    else if ([request isGET] && [response isOK]) {
        [self handleArtistResponse: response];        
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
    // hide the pulldown refresh
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0];
}

@end
