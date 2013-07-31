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

#import "PlayerListViewController.h"
#import "JSONKit.h"
#import "PlayerCell.h"
#import "MainTabBarController.h"
#import "PlayerInfoViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "PlayerInfoViewController.h"
#import "UDJPlayerManager.h"
#import "UDJClient.h"

@interface PlayerListViewController ()

@end

@implementation PlayerListViewController

@synthesize playerData, tableList, tableView;
@synthesize statusLabel, globalData, currentRequestNumber;
@synthesize playerSearchBar, findNearbyButton, cancelSearchButton, searchIndicatorView;
@synthesize lastSearchType, lastSearchQuery;
@synthesize joiningBackgroundView, joiningView;
@synthesize shouldShowMyPlayer;

#pragma mark - Alert view delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if([alertView.title isEqualToString:@"Password Required"]){
        if(buttonIndex == 1){
            // send an event join request with the password specified
            [self toggleJoiningView: YES];
            self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
            [[UDJPlayerData sharedPlayerData] joinPlayer: [alertView textFieldAtIndex:0].text];
        }
        else{
            [self.tableView reloadData];
        }
    }
}


#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self toggleJoiningView: NO];
    
    self.tableList = [[NSMutableArray alloc] init];
    
    self.globalData = [UDJUserData sharedUDJData];
    
    // initialize login view
    joiningView.layer.cornerRadius = 8;
    joiningView.layer.borderColor = [[UIColor whiteColor] CGColor];
    joiningView.layer.borderWidth = 3;
    
    // set up eventData and get nearby events
    self.playerData = [UDJPlayerData sharedPlayerData];
    self.playerData.playerListDelegate = self;
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    
    // initialize search bar
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:(35.0/255.0) green:(59.0/255.0) blue:(79.0/255.0) alpha:1];
    self.navigationController.toolbarHidden = NO;
    
    UIBarButtonItem* createPlayerButton = [[UIBarButtonItem alloc] initWithTitle:@"My Player" style:UIBarButtonItemStyleBordered target:self action:@selector(createPlayerClick)];
    UIBarButtonItem* flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = [NSArray arrayWithObjects: flexible, createPlayerButton, nil];
    
    self.shouldShowMyPlayer = NO;
    
    [self initNavBar];
    
    [self findNearbyPlayers];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    [self toggleJoiningView: NO];
    [self.navigationController setToolbarHidden: NO animated:YES];
    [self.navigationItem setTitle:@""];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden: YES animated:YES];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];

    [UDJPlayerManager sharedPlayerManager].isInPlayerMode = NO;
    
    // if we've just created a player, go to the player view
    if(shouldShowMyPlayer){
        shouldShowMyPlayer = NO;
        MainTabBarController* tabBarController = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle: [NSBundle mainBundle]];
        [tabBarController initForPlayerMode: YES];
        [self.navigationController pushViewController: tabBarController animated:YES];          
    }
}

-(void)initNavBar{
    UIColor* blueTintColor = [UIColor colorWithRed:(35.0/255.0) green:(59.0/255.0) blue:(79.0/255.0) alpha:1];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTintColor: blueTintColor];
    
    // set up search bar
    self.playerSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 240, 44)];
    [playerSearchBar setPlaceholder:@"Search for players"];
    [playerSearchBar setTintColor: blueTintColor];
    [playerSearchBar setAutocorrectionType: UITextAutocorrectionTypeNo];
    [playerSearchBar setDelegate:self];
    
    // put search bar on left side
    UIBarButtonItem* searchBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: playerSearchBar];
    [self.navigationItem setLeftBarButtonItem:searchBarButtonItem];
    
    // set up buttons
    UIBarButtonItem* nearbyButton = [[UIBarButtonItem alloc] initWithTitle:@"Nearby" style:UIBarButtonItemStyleBordered target:self action:@selector(nearbyButtonClick:)];
    [self.navigationItem setRightBarButtonItem:nearbyButton];
}



#pragma mark - Player creation methods

-(void)createPlayerClick{
    UDJPlayerInfoManager* playerInfoManager = [UDJPlayerInfoManager sharedPlayerInfoManager];
    if(playerInfoManager.playerID == nil){
        PlayerInfoViewController* viewController = [[PlayerInfoViewController alloc] initWithNibName:@"PlayerInfoViewController" bundle:[NSBundle mainBundle]];
        [self presentModalViewController:viewController animated:YES];
        viewController.parentViewController = self;
    }
    else{
        MainTabBarController* tabBarController = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle: [NSBundle mainBundle]];
        [tabBarController initForPlayerMode: YES];
        [self.navigationController pushViewController: tabBarController animated:YES];        
    }
}



#pragma mark - UI Events

// Show or hide the "joining event..." view; active = YES will show the view
-(void) toggleJoiningView:(BOOL) active{
    joiningBackgroundView.hidden = !active;
}

// When user presses cancel, hide login view and let controller know
// we aren't waiting on any requests
-(IBAction)cancelButtonClick:(id)sender{
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
    [self.tableView reloadData];
    [self toggleJoiningView:NO];
}

-(IBAction)nearbyButtonClick:(id)sender{
    [playerSearchBar resignFirstResponder];
    [self findNearbyPlayers];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar*)theSearchBar{
    UIBarButtonItem* rightButton = [self.navigationItem rightBarButtonItem];
    [rightButton setTitle:@"Cancel"];
    [rightButton setAction:@selector(cancelSearchButtonClick:)];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar{
    [theSearchBar resignFirstResponder];
    
    NSString* searchParam = theSearchBar.text;
    
    // if the search query is invalid, alert the user
    if(![self isValidSearchQuery:searchParam]){
        UIAlertView* invalidSearchParam = [[UIAlertView alloc] initWithTitle:@"Invalid Query" message:@"Your search query can only contain alphanumeric characters. This includes A-Z, 0-9." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [invalidSearchParam show];
    }
    
    else if(![searchParam isEqualToString:@""]){
        [self findPlayersByName: searchParam];
    }
    
    UIBarButtonItem* rightButton = [self.navigationItem rightBarButtonItem];
    [rightButton setTitle:@"Nearby"];
    [rightButton setAction:@selector(nearbyButtonClick:)];
}

// Hides the keyboard and brings back the Nearby button
-(IBAction)cancelSearchButtonClick:(id)sender{
    UIBarButtonItem* rightBarButton = [self.navigationItem rightBarButtonItem];
    [rightBarButton setTitle:@"Nearby"];
    [rightBarButton setAction:@selector(nearbyButtonClick:)];
    [playerSearchBar resignFirstResponder];
}


// Hide the keyboard when user hits return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


#pragma mark - Animation methods

-(void)hideCancelButton{
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58.0;
}

- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    PlayerCell *cell = [TableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    UDJPlayer* player = [tableList objectAtIndex: row];
    
    cell.playerNameLabel.text = player.name;
    cell.backgroundColor = [UIColor clearColor];
    
    float alpha = [player.state isEqualToString:@"inactive"] ? 0.3 : 1;
    cell.containerView.alpha = alpha;
    cell.playerNameLabel.alpha = alpha;
    
    return cell;
}


#pragma mark - Table view delegate

// user selects a cell: attempt to enter that party
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // get the party and remember the event we are trying to join
    NSInteger index = [indexPath indexAtPosition:1];
    
    // get the event corresponding to that index
    [UDJPlayerData sharedPlayerData].currentPlayer = [[UDJPlayerData sharedPlayerData].currentList objectAtIndex:index];
    UDJPlayer* player = [UDJPlayerData sharedPlayerData].currentPlayer;
    
    // if we are the owner, we can go right into the player
    NSString* ownerID = player.owner.userID;
    if([player.state isEqualToString:@"inactive"]){
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Player Inactive"
                                                            message:@"You cannot join this player because it is currently inactive."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
    else if([ownerID isEqualToString: globalData.userID]){
        [self joinEvent];
    }
    // there's a password: go the password screen
    else if(player.hasPassword){
        UIAlertView* passwordAlertView = [[UIAlertView alloc] initWithTitle:@"Password Required" message:@"This player requires a password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
        passwordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [passwordAlertView textFieldAtIndex:0].placeholder = @"Password";
        [passwordAlertView show];
    }
    
    // no password: attempt login
    else{
        // send event request
        [self toggleJoiningView: YES];
        self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
        [playerData joinPlayer:nil];
    }
}



#pragma mark - Event search methods

// check if this is a valid query
-(BOOL) isValidSearchQuery:(NSString*)string{
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    NSString* testString = [NSString stringWithString: string];
    testString = [testString stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL valid = [[testString stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
    return valid;
}

-(void)findNearbyPlayers{
    // update status label
    [statusLabel setText: @"Searching for nearby players"];
    searchIndicatorView.hidden = NO;
    
    self.lastSearchType = SearchTypeNearby;
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    [playerData getNearbyPlayers];
}

-(void)findPlayersByName:(NSString*)name{
    
    // update status label
    [statusLabel setText: [NSString stringWithFormat: @"Searching for '%@'", name]];
    searchIndicatorView.hidden = NO;
    
    // remember last search type/query
    self.lastSearchType = SearchTypeName;
    self.lastSearchQuery = name;
    
    self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
    [playerData getPlayersByName: name];
}


#pragma mark - Response handling

-(void)showMessage:(NSString*)message withTile:(NSString*)title{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [self toggleJoiningView: NO];
    [self.tableView reloadData];
}

-(void)showResultsMessage:(BOOL)found{
    
    searchIndicatorView.hidden = YES;
    
    // if we didn't find any players, let user know
    if(!found){
        if(lastSearchType == SearchTypeName){
            [statusLabel setText: [NSString stringWithFormat: @"No players found matching '%@'", lastSearchQuery]];
        }
        else if(lastSearchType == SearchTypeNearby){
            [statusLabel setText: @"No nearby players found"];
        }        
    }
    
    // otherwise show appropriate description
    else{
        if(lastSearchType == SearchTypeName)
            [statusLabel setText: [NSString stringWithFormat: @"Players matching '%@'", lastSearchQuery, nil]];
        else if(lastSearchType == SearchTypeNearby)
            [statusLabel setText: @"Nearby players"];        
    }
    
    lastSearchType = SearchTypeNull;
}


// joinEvent: login was successful, show playlist view
-(void) joinEvent{
    MainTabBarController* viewController = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle:[NSBundle mainBundle]];
    [viewController initForPlayerMode: NO];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)refreshTableList{
    [tableList removeAllObjects];

    self.tableList = playerData.currentList;
    [self.tableView reloadData];
}

// handleEventResults: get the list of returned events from either the name or location search
- (void)parsePlayerResults:(UDJResponse*)response{
    
    // hide the activity indicator
    searchIndicatorView.hidden = YES;
    
    // Parse the response into an array of UDJEvents
    NSMutableArray* cList = [NSMutableArray new];
    NSArray* eventArray = [[response bodyAsString] objectFromJSONString];
    for(int i=0; i<[eventArray count]; i++){
        NSDictionary* eventDict = [eventArray objectAtIndex:i];
        UDJPlayer* event = [UDJPlayer playerFromDictionary:eventDict];
        [cList addObject:event];
    }
    
    // Update the global event list
    [UDJPlayerData sharedPlayerData].currentList = cList;
    
    // update status label accordingly
    if([cList count] == 0) [self showResultsMessage:NO];
    else [self showResultsMessage: YES];
    
    // refresh table
    [self refreshTableList];
}

// Handle responses from the server
- (void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response {
    NSLog(@"status code %d", [response statusCode]);
    
    NSNumber* requestNumber = request.userData;
    NSDictionary* headerDict = [response allHeaderFields];
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    if ([request isGET]) {
        [self parsePlayerResults:response];        
    }
    
    else if([request isPUT]){
        
        if(response.statusCode == 201){
            [self joinEvent];
        }
        else if(response.statusCode == 404){
            [self showMessage:@"The player you are trying to access is inactive." withTile:@"Player Inactive"];
        }
        
        // let user know they entered the wrong password
        else if(response.statusCode == 401 && [[headerDict objectForKey: @"WWW-Authenticate"] isEqualToString: @"player-password"])
            [self showMessage:@"You have entered an incorrect password for the player." withTile:@"Incorrect Password"];
        
        // check if the player is full, or if the user is banned
        else if(response.statusCode == 403){
            if([[headerDict objectForKey: @"X-Udj-Forbidden-Reason"] isEqualToString:@"player-full"]){
                [self showMessage:@"This player is currently at capacity. Please contact the owner." withTile:@"Player Full"];
            }
            else if([[headerDict objectForKey: @"X-Udj-Forbidden-Reason"] isEqualToString: @"banned"]){
                [self showMessage:@"You have been banned from this player." withTile:@"Banned"];
            }
        }
    } 
    
    // check if our ticket was invalid
    if(response.statusCode == 401 && [[headerDict objectForKey: @"WWW-Authenticate"] isEqualToString: @"ticket-hash"])
        [globalData renewTicket];
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
}

@end
