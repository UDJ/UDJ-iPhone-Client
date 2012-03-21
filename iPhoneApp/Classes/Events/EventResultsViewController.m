//
//  EventResultsViewController.m
//  UDJ
//
//  Created by Matthew Graf on 3/20/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "EventResultsViewController.h"
#import "UDJEvent.h"
#import "PartyLoginViewController.h"

@implementation EventResultsViewController

@synthesize tableList, tableView, eventData, currentRequestNumber, globalData;

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
    
    self.globalData = [UDJData sharedUDJData];

    // initialize eventData
    self.eventData = [UDJEventData sharedEventData];
    self.eventData.enterEventDelegate = self;
    
    self.tableList = eventData.currentList;
    [self.tableView reloadData];
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




#pragma mark Button click methods

-(IBAction)newEventSearchButtonClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
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
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)TableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [TableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    UDJEvent* event = [tableList objectAtIndex: row];
    
    cell.textLabel.text = event.name;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:22];
	cell.textLabel.textColor=[UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


#pragma mark - Table view delegate

// user selects a cell: attempt to enter that party
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // get the party and remember the event we are trying to join
    NSInteger index = [indexPath indexAtPosition:1];

    // get the event corresponding to that index
    [UDJEventData sharedEventData].currentEvent = [[UDJEventData sharedEventData].currentList objectAtIndex:index];
    
    // there's a password: go the password screen
	if([UDJEventData sharedEventData].currentEvent.hasPassword)
        [self showPasswordScreen];
    
    // no password: attempt login
    else{
        // send event request
        self.currentRequestNumber = [NSNumber numberWithInt: globalData.requestCount];
        [eventData enterEvent];
    }
}



#pragma mark Navigation methods

-(void) showPasswordScreen{
    PartyLoginViewController* partyLoginViewController = [[PartyLoginViewController alloc] initWithNibName:@"PartyLoginViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:partyLoginViewController animated:YES];   
}

// joinEvent: login was successful, show playlist view
-(void) joinEvent{
    PlaylistViewController* playlistViewController = [[PlaylistViewController alloc] initWithNibName:@"NewPlaylistViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:playlistViewController animated:YES];    
}




#pragma mark Error methods
-(void) showEventNotFoundError{
    UIAlertView* nonExistantEvent = [[UIAlertView alloc] initWithTitle:@"Join Failed" message:@"The event you are trying to join does not exist. Sorry!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [nonExistantEvent show];    
}

-(void) showAlreadyInEventError{
    NSString* msg = [NSString stringWithFormat:@"%@%@%@", @"You are already logged into another event, \"", [UDJEventData sharedEventData].currentEvent.name, @"\". Would you like to log out of that event or rejoin it?", nil];
    UIAlertView* alreadyInEvent = [[UIAlertView alloc] initWithTitle:@"Event Conflict" message: msg delegate: self cancelButtonTitle:@"Log Out" otherButtonTitles:@"Rejoin",nil];
    [alreadyInEvent show];
}




#pragma mark Response handling

// Handle responses from the server
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSNumber* requestNumber = request.userData;
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if the event has ended
    if(response.statusCode == 410){
        //[self resetToEventView];
    }
    else if([request isPUT]){
        
        if(response.statusCode == 201)
            [self joinEvent];
        
        else if(response.statusCode == 404)
            [self showEventNotFoundError];
        
        else if(response.statusCode == 409)
            [self showAlreadyInEventError];
        
    } 
    
    self.currentRequestNumber = nil;
}

@end