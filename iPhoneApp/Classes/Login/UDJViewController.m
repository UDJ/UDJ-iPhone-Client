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

#import "UDJViewController.h"
#import "PlaylistViewController.h"
#import "UDJUserData.h"
#import "KeychainItemWrapper.h"
#import "UDJAppDelegate.h"
#import "PlayerListViewController.h"
#import "JSONKit.h"
#import "RegisterViewController.h"
#import "UDJFBViewController.h"

const int LOGIN_VIEW_ID = 100;


@implementation UDJViewController

@synthesize loginButton, usernameField, passwordField, registerButton, currentRequestNumber, globalData, loginView;

@synthesize managedObjectContext;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // bring the user to the UDJ app store page to update
    if([alertView.title isEqualToString:@"Needs Update"] && buttonIndex == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.com/apps/udj"]];
    }
}

- (IBAction)performLogin:(id)sender
{    
    UDJAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate openSession];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.navigationController setNavigationBarHidden:YES];
    globalData = [UDJUserData sharedUDJData];
    
    // add facebook button
    FBLoginView *fbLoginView = [[FBLoginView alloc] init];
    fbLoginView.delegate = self;
    fbLoginView.readPermissions = @[@"basic_info", @"email"];
    fbLoginView.frame = CGRectMake(20, 200, 280, 46);
    [self.view addSubview:fbLoginView];
    
    // initialize login view
    loginBackgroundView.hidden = YES;
    loginView.layer.cornerRadius = 8;
    loginView.layer.borderColor = [[UIColor whiteColor] CGColor];
    loginView.layer.borderWidth = 3;
    
    // initialize text fields
    usernameField.placeholder = @"Username";
    passwordField.placeholder = @"Password";
    usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    
    UDJAppDelegate* appDelegate = (UDJAppDelegate*)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
  
    [self checkForUsername];
}

#pragma mark - Facebook login

-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"FB Logged in");
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    NSLog(@"FB Logged fetched user info");
    NSString *facebookID = [user id];
    NSString *accessToken = [[FBSession.activeSession accessTokenData] accessToken];
    [self sendFBAuthRequest:facebookID token: accessToken];
}

-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSLog(@"FB Error");
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)loginFailed{
    // TODO: what is supposed to be here?
}

// Show or hide the "logging in.." view; active = YES will show the view
-(void) toggleLoginView:(BOOL) active
{
    if(active && self.loginView == nil){
        self.loginView = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
        [self.view addSubview: self.loginView];
        [loginView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.75]];
        
        
        UILabel *loginLabel = [[UILabel alloc] init];
        [loginLabel setTextColor:[UIColor whiteColor]];
        [loginLabel setTextAlignment:NSTextAlignmentCenter];
        [loginLabel setText:@"Logging in"];
        [loginLabel setFrame:CGRectMake(0, 0, 150, 30)];
        [loginLabel setCenter:CGPointMake(loginView.frame.size.width / 2, loginView.frame.size.height / 2)];
        [loginView addSubview:loginLabel];
        
        // fade in
        loginView.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^(void){
            loginView.alpha = 1;
        }];
    }
    else if(!active && self.loginView != nil){
        [UIView animateWithDuration:0.5 animations:^(void){
            loginView.alpha = 0;
        }completion:^(BOOL finished){
            if(finished){
                [loginView removeFromSuperview];
                loginView = nil;
            }
        }];
    }
}
- (void)showLoginView
{
    UIViewController *topViewController = [self.navigationController topViewController];
    UIViewController *modalViewController = [topViewController modalViewController];
    
    // If the login screen is not already displayed, display it. If the login screen is
    // displayed, then getting back here means the login in progress did not successfully
    // complete. In that case, notify the login view so it can update its UI appropriately.
    if (![modalViewController isKindOfClass:[UDJViewController class]]) {
        UDJViewController* loginViewController = [[UDJViewController alloc]
                                                      initWithNibName:@"UDJViewController"
                                                      bundle:nil];
        [topViewController presentModalViewController:loginViewController animated:NO];
    } else {
        UDJViewController* loginViewController =
        (UDJViewController*)modalViewController;
        [loginViewController loginFailed];
    }
}


#pragma mark Keychain methods

-(void)savePasswordToKeychain{
    KeychainItemWrapper* keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"UDJLoginData" accessGroup:nil];
    [keychain setObject: passwordField.text forKey: (__bridge id)kSecValueData];
}

-(void)saveUsernameAndDate{
    UDJStoredData* storedData;
    NSError* error;
    
    //Set up a request to get the last stored data
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredData" inManagedObjectContext:managedObjectContext]];
    storedData = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        // error in getting info
    }
    
    // if there was no stored data before, create it
    if (!storedData) {
        storedData = (UDJStoredData*)[NSEntityDescription insertNewObjectForEntityForName:@"UDJStoredData" inManagedObjectContext:managedObjectContext];  
    }
    
    // update the username, save the date the ticket was assigned
    [storedData setUsername: usernameField.text]; 
    NSDate* currentDate = [NSDate date];
    [storedData setTicketDate: currentDate];
    
    //Save the data
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
    
    // save password in keychain
    [self savePasswordToKeychain];
    
}

-(void)getPasswordFromKeychain:(NSString*)username{
    KeychainItemWrapper* keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"UDJLoginData" accessGroup:nil];
    
    NSString* password = [keychain objectForKey: (__bridge id)kSecValueData];

    usernameField.text = username;
    passwordField.text = password;
    
    [self sendAuthRequest:username password:password];
}

-(void)checkForUsername{
    UDJStoredData* storedData;
    NSError* error;
    
    //Set up a request to get the last info
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredData" inManagedObjectContext:managedObjectContext]];
    
    // find last info
    storedData = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        // error in getting info
    }
    
    // if there was a username,
    if (storedData) {
        [self getPasswordFromKeychain: storedData.username];
    }
}


#pragma mark Authenticate methods

-(void)sendFBAuthRequest:(NSString*)facebookID token:(NSString*)token{
    UDJClient* client = [UDJClient sharedClient];
    NSDictionary* nameAndToken = [NSDictionary dictionaryWithObjectsAndKeys:facebookID, @"user_id", token, @"access_token", nil];
    NSString* jsonString = [nameAndToken JSONString];
    
    // put the API version in the header
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"0.7", @"X-Udj-Api-Version", @"text/json", @"content-type", nil];
    
    // create the URL
    NSMutableString* urlString = [NSMutableString stringWithString:client.baseURLString];
    [urlString appendString: @"/fb_auth"];
    
    // set up request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self;
    request.HTTPBodyString = jsonString;
    request.method = UDJRequestMethodPOST;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    request.additionalHTTPHeaders = headers;
    
    // remember the request we are waiting on
    self.currentRequestNumber = request.userData;
    
    [self toggleLoginView:YES];
    [request send];
}

// authenticate: sends a POST with the username and password
- (void) sendAuthRequest:(NSString*)username password:(NSString*)pass{
    UDJClient* client = [UDJClient sharedClient];
    
    // make sure the right api version is being passed in
    NSDictionary* nameAndPass = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", pass, @"password", nil];
    NSString* jsonString = [nameAndPass JSONString];
    
    // put the API version in the header
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"0.7", @"X-Udj-Api-Version", @"text/json", @"content-type", nil];

    // create the URL
    NSMutableString* urlString = [NSMutableString stringWithString:client.baseURLString];
    [urlString appendString: @"/auth"];
    
    // set up request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self;
    request.HTTPBodyString = jsonString;
    request.method = UDJRequestMethodPOST;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++]; 
    request.additionalHTTPHeaders = headers;
    
    // remember the request we are waiting on
    self.currentRequestNumber = request.userData;
    
    [self toggleLoginView:YES];
    [request send];
    
}

// handleAuth: handle authorization response if credentials are valid
- (void)handleAuth:(UDJResponse*)response{
    
    // save the username, password, and ticket assign date information to Core Data
    [self saveUsernameAndDate];
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
    
    // save our username and password
    globalData.username = usernameField.text;
    globalData.password = passwordField.text;
    
    // only handle if we are waiting for an auth response
    NSDictionary* responseDict = [[response bodyAsString] objectFromJSONString];
    globalData.ticket=[responseDict valueForKey:@"ticket_hash"];
    globalData.userID=[responseDict valueForKey:@"user_id"];
        
    //TODO: may need to change userID to [userID intValue]
    globalData.headers = [NSDictionary dictionaryWithObjectsAndKeys:globalData.ticket, @"X-Udj-Ticket-Hash", nil];
        
    // load the player list view
    PlayerListViewController* viewController = [[PlayerListViewController alloc] initWithNibName:@"PlayerListViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)denyAuth:(UDJResponse*)response{
    // hide the login view
    [self toggleLoginView:NO];
    
    if([response statusCode] == 401 || [response statusCode] == 404){
        //let user know their credentials were invalid
        UIAlertView* authNotification = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"The username or password you entered is invalid." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [authNotification show];        
    }
    
    else if([response statusCode] == 501){
        //let user know they have to update
        UIAlertView* authNotification = [[UIAlertView alloc] initWithTitle:@"Needs Update" message:@"Your UDJ client is outdated. Please download the latest version." delegate: self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
        [authNotification show];        
    }
    else{
        UIAlertView* authNotification = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Something went wrong on our end. Please try again later." delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [authNotification show];
    }
}

// When user presses cancel, hide login view and let controller know
// we aren't waiting on any requests
-(IBAction)cancelButtonClick:(id)sender{
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
    [self toggleLoginView:NO];
}

// Send a login attempt if the user entered a name/pass
- (IBAction) loginClick:(id) sender {
	// handle user's login attempt
    NSString* username = usernameField.text;
    NSString* password = passwordField.text;
    
    if(![username isEqualToString: @""] && ![password isEqualToString: @""]){
        [self sendAuthRequest:username password:password];
    }
}

// Send user to the register page
-(IBAction)registerButtonClick:(id)sender{
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.udjplayer.com/registration/register/"]];
    RegisterViewController* registerViewController = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:registerViewController animated:YES];
}

// Hide the keyboard when user hits return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == usernameField || textField == passwordField) {
		[textField resignFirstResponder];
	}
	return NO;
}

// Handle responses from the server
- (void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response {
    NSLog(@"status code %d", [response statusCode]);
    
    NSNumber* requestNumber = request.userData;
    
    if(![requestNumber isEqualToNumber: currentRequestNumber]) return;
    
    // check if the event has ended
    if(response.statusCode == 410){
        //[self resetToEventView];
    }
    else if([request isPOST]) {
        // If we got a response back from our authenticate request
        if([response isOK])
            [self handleAuth:response];
        else
            [self denyAuth:response];
    }
    
    self.currentRequestNumber = [NSNumber numberWithInt: -1];
}


@end
