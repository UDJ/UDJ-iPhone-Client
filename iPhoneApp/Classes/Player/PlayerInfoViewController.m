//
//  PlayerInfoViewController.m
//  UDJ
//
//  Created by Matthew Graf on 6/25/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "PlayerInfoViewController.h"
#import "JSONKit.h"
#import "UDJAppDelegate.h"
#import "UDJStoredPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UDJStoredLibraryEntry.h"
#import "PlayerListViewController.h"
#import <objc/runtime.h>
#import "UDJClient.h"

@interface PlayerInfoViewController ()

@end

@implementation PlayerInfoViewController

@synthesize mainScrollView;
@synthesize textFieldArray;
@synthesize playerNameLabel;
@synthesize playerNameField, playerPasswordField;
@synthesize cancelButton, closeButton, editButton, doneButton;
@synthesize useLocationSwitch, addressField, cityField, stateField, zipCodeField, locationFields;
@synthesize selectedFieldIndex;
@synthesize createPlayerButton;
@synthesize globalData, managedObjectContext, playerID, songSyncDictionary;
@synthesize activityView, activityLabel;
@synthesize playerManager, playerInfoManager;
@synthesize parentViewController;
@synthesize statePickerView, stateNameArray, stateAbbrArray;

#pragma mark - Text fields

-(void)forceKeyboardHide{
    for(int i=0; i < [textFieldArray count]; i++){
        UITextField* textField= [textFieldArray objectAtIndex: i];
        [textField resignFirstResponder];
    }
    [self.view endEditing: YES];
}

-(IBAction)cancelButtonClick:(id)sender{
    [self forceKeyboardHide];
    [self.mainScrollView scrollRectToVisible: CGRectMake(0, 0, 320, 367) animated:YES];
    self.mainScrollView.scrollEnabled = NO;
}

-(void)initTextFields{
    for(int i=0; i < [textFieldArray count]; i++){
        UITextField* textField= [textFieldArray objectAtIndex: i];
        textField.delegate = self;
        textField.tag = i;
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    }
}

-(void)textFieldDidBeginEditing:(UITextField*)textField{
    float yCoord = textField.frame.origin.y;
    [self.mainScrollView setContentOffset:CGPointMake(0, yCoord - 5) animated:YES];
    self.cancelButton.hidden = NO;
    self.mainScrollView.scrollEnabled = YES;
    self.selectedFieldIndex = textField.tag;
    
    if(textField.tag == 4){
        [self forceKeyboardHide];
        [self toggleStatePicker: YES];
    }
    else{
        [self toggleStatePicker: NO];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField.tag == 4){
        [self.mainScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 5) animated:YES];
        [self forceKeyboardHide];
        [self toggleStatePicker: YES];
        return NO;
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    if(textField == self.playerNameField){
        [playerNameLabel setText: self.playerNameField.text];
    }
    self.cancelButton.hidden = YES;
    
    // hide keyboard if we are selecting state
    if(selectedFieldIndex == 4){
        [self forceKeyboardHide];
        [self.view endEditing:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    // find the next text field
    NSInteger index = textField.tag + 1;
    UITextField* nextField;
    if(index < [textFieldArray count]) nextField = [textFieldArray objectAtIndex: index]; 
    else nextField = nil;
    
    // if this is the last enabled field, hide the keyboard
    if(!nextField || !nextField.enabled){
        [self.mainScrollView scrollRectToVisible: CGRectMake(0, 0, 320, 367) animated:YES];
        self.mainScrollView.scrollEnabled = NO;
    }
    else if(index == 4){
        [self forceKeyboardHide];
        [self toggleStatePicker: YES];
    }
    // set focus to the next field
    else{
        [nextField becomeFirstResponder];        
    }
    
    return NO;
}

-(IBAction)useLocationValueChanged:(id)sender{
    UISwitch *locationSwitch = (UISwitch*)sender;
    for(UITextField *textField in self.locationFields){
        textField.alpha = [locationSwitch isOn] ? 1 : 0.5;
        textField.enabled = [locationSwitch isOn];
    }
}

#pragma mark - State (location) picker

-(void)toggleStatePicker:(BOOL)visible{
    [UIView animateWithDuration:0.4 animations:^(void){
        NSInteger yCoord = visible ? 200 : 480;
        [self.statePickerView setFrame: CGRectMake(0, yCoord, 320, 260)];
    }];   
}

-(IBAction)donePickingStateClick:(id)sender{
    [self toggleStatePicker: NO];
    [self.mainScrollView scrollRectToVisible: CGRectMake(0, 0, 320, 367) animated:YES];
    self.mainScrollView.scrollEnabled = NO;
}

-(void)initStateArrays{
    self.stateNameArray = [NSArray arrayWithObjects:@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Delaware", @"Florida", @"Georgia", @"Hawaii", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Kansas", @"Kentucky", @"Louisiana", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Mississippi", @"Missouri", @"Montana", @"Nebraska", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oklahoma", @"Oregon", @"Pennsylvania", @"Rhode Island", @"South Carolina", @"South Dakota", @"Tennessee", @"Texas", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming", nil];
    self.stateAbbrArray = [NSArray arrayWithObjects:@"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"ID", @"IL", @"IN", @"IA", @"KS", @"KY", @"LA", @"ME", @"MD", @"MA", @"MI", @"MN", @"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ", @"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY", nil];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [stateNameArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return (NSString*)[stateNameArray objectAtIndex: row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [stateField setText: [stateAbbrArray objectAtIndex: row]];
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
    
    self.playerID = nil;
    
    [self initStateArrays];
    [self.statePickerView setFrame: CGRectMake(0, 480, 320, 260)];
    [self.view addSubview: self.statePickerView];
    
    [self.mainScrollView setContentSize: CGSizeMake(320, 660)]; // 320, 367
    [self.mainScrollView scrollRectToVisible: CGRectMake(0, 8, 320, 367) animated:YES];
    self.mainScrollView.scrollEnabled = NO;
    
    [self.view addSubview: self.activityView];
    self.activityView.frame = CGRectMake(20, 470, 280, 32);
    
    [self initTextFields];
    
    self.globalData = [UDJUserData sharedUDJData];
    self.globalData.playerCreateDelegate = self;
    self.playerManager = [UDJPlayerManager sharedPlayerManager];
    self.playerInfoManager = [UDJPlayerInfoManager sharedPlayerInfoManager];
    
    UDJAppDelegate* appDelegate = (UDJAppDelegate*)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    [self updatePlayerInfo];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.globalData.playerCreateDelegate = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Saving & Loading player info

-(void)savePlayerInfo{
    // update the player info manager
    [playerInfoManager setPlayerName: self.playerNameField.text];
    [playerInfoManager setAddress: self.addressField.text];
    [playerInfoManager setCity: self.cityField.text];
    [playerInfoManager setStateLocation: self.stateField.text];
    [playerInfoManager setPlayerPassword: self.playerPasswordField.text];
    [playerInfoManager setZipCode: self.zipCodeField.text];
    [playerInfoManager setPlayerID: self.playerID];
    
    [playerInfoManager savePlayerInfo];
}

-(void)updatePlayerInfo{
    [playerInfoManager loadPlayerInfo];
    
    // if there was a stored player, fill in the fields
    if (playerInfoManager.playerID != nil) {
        [self.playerNameField setText: playerInfoManager.playerName];
        [self.playerPasswordField setText: playerInfoManager.playerPassword];
        [self.addressField setText: playerInfoManager.address];
        [self.cityField setText: playerInfoManager.city];
        [self.stateField setText: playerInfoManager.stateLocation];
        [self.zipCodeField setText: playerInfoManager.zipCode];
        self.playerID = playerInfoManager.playerID;
        [playerNameLabel setText: playerInfoManager.playerName];
        
        // disable fields that can't be changed after the player is first created
        self.createPlayerButton.hidden = YES;
        self.playerNameField.enabled = NO;
        self.playerNameField.alpha = 0.8;
    }
}

#pragma mark - Changing player info



#pragma mark - Navigation

-(IBAction)closeButtonClick:(id)sender{
    [self dismissModalViewControllerAnimated: YES];
    
    // If this player was created already, update the information
    if(self.playerID != nil){
        NSLog(@"Player id: %@", self.playerID);
        // save the information to the device
        [self savePlayerInfo];
        // let the server know about the changes
        [playerInfoManager updateInfoOnServer];
    }
}



#pragma mark - Player methods helpers

-(BOOL)completedLocationFields{
    BOOL complete = YES;
    for(int i=0; i < [locationFields count]; i++){
        UITextField* textField = [locationFields objectAtIndex: i];
        NSString* textWithoutSpaces = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if([textWithoutSpaces isEqualToString:@""]){
            complete = NO;
        }
    }
    
    return complete;
}

-(BOOL)completedNameField{
    BOOL complete = YES;
    
    NSString* textWithoutSpaces = [self.playerNameField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if([textWithoutSpaces isEqualToString:@""]) complete = NO;
    
    return complete;
}

-(NSString*)JSONStringWithPlayerInfo{    
    // create dictionary with name/pass
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [dict setValue: self.playerNameField.text forKey:@"name"];
    if(![self.playerPasswordField.text isEqualToString:@""])
        [dict setValue:self.playerPasswordField.text forKey:@"password"];
    
    // Location dictionary is optional
    if([self completedLocationFields])
    {
        NSMutableDictionary* locationDict = [[NSMutableDictionary alloc] initWithCapacity: 4];
        [locationDict setValue:self.addressField.text forKey:@"address"];
        [locationDict setValue:self.cityField.text forKey:@"locality"];
        [locationDict setValue:self.stateField.text forKey:@"region"];
        [locationDict setValue:self.zipCodeField.text forKey:@"postal_code"];
        [locationDict setValue: @"United States" forKey:@"country"];
        [dict setObject: locationDict forKey: @"location"];
    }
    
    return [dict JSONString];
}

-(void)toggleActivityView:(BOOL)visible{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.5];
    NSInteger yPos = visible ? 420 : 470;
    self.activityView.frame = CGRectMake(20, yPos, 280, 32);
    [UIView commitAnimations];
}


#pragma mark - Creating player


-(IBAction)createButtonClick:(id)sender{
    if([self completedNameField] && (![self.useLocationSwitch isOn] || ([self.useLocationSwitch isOn] && [self completedLocationFields]))){
        [self sendCreatePlayerRequest];
        self.createPlayerButton.hidden = YES;
        
        for(int i=0; i < [textFieldArray count]; i++){
            UITextField* textField= [textFieldArray objectAtIndex: i];
            [textField resignFirstResponder];
        }
        
        [self.mainScrollView scrollRectToVisible: CGRectMake(0, 0, 320, 367) animated:YES];
        self.mainScrollView.scrollEnabled = NO;
        
        [self.activityLabel setText: @"Creating player"];
        [self toggleActivityView: YES];
    }
    else if([self.useLocationSwitch isOn] && ![self completedLocationFields] && ![self completedNameField]){
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Missing Info" message:@"You must choose a name for your player and fill out all address fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    else if([self.useLocationSwitch isOn] && [self completedLocationFields] && ![self completedNameField]){
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Missing Player Name" message:@"You must choose a name for your player." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    else if(![self.useLocationSwitch isOn] && ![self completedNameField]){
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Missing Player Name" message:@"You must choose a name for your player." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    else if([self.useLocationSwitch isOn] && ![self completedLocationFields] && [self completedNameField]){
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Missing Address" message:@"You must fill out all address fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    NSLog(@"didnt trigger");
}

-(void)sendCreatePlayerRequest{
    UDJClient* client = [UDJClient sharedClient];
    
    //create url [POST] {prefix}/udj/users/user_id/players/player_id/name
    NSString* urlString = client.baseURLString;
    urlString = [urlString stringByAppendingString:@"/players/player"];

    // create request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self.globalData;
    request.method = UDJRequestMethodPUT;
    request.HTTPBodyString = [self JSONStringWithPlayerInfo];
    request.userData = @"createPlayer";
    
    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: [UDJUserData sharedUDJData].headers];
    [requestHeaders setValue:@"playerCreateDelegate" forKey:@"delegate"];
    [requestHeaders setValue:@"text/json" forKey:@"content-type"];
    request.additionalHTTPHeaders = requestHeaders;
    
    //send request
    [request send];
}

#pragma mark - Response handling

-(void)additionalPlayerSetup{
    
    [self savePlayerInfo];
    NSLog(@"saved player info");
    
    // start using the new player
    PlayerListViewController* playerListViewController = (PlayerListViewController*)self.parentViewController;
    playerListViewController.shouldShowMyPlayer = YES;
    [self dismissModalViewControllerAnimated: YES];
}

-(void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response {
    NSString* requestType = request.userData;
    //NSDictionary* headerDict = [response allHeaderFields];
    
    if([requestType isEqualToString: @"createPlayer"]){
        if([response statusCode] == 201){
            // Save player ID
            NSDictionary* responseDict = [response.bodyAsString objectFromJSONString];
            NSString* recievedID = [responseDict objectForKey: @"id"];
            self.playerID = recievedID;
            
            [self additionalPlayerSetup];            
        }
        else if([response statusCode] == 409){
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Player Name Taken" message:@"Sorry, but there is already a player with this name!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [self toggleActivityView: NO];
            self.createPlayerButton.hidden = NO;
        }
        else if([response statusCode] == 400){
            
        }
    }
    
}

@end
