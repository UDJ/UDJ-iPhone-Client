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

#import "UDJAppDelegate.h"
#import "UDJViewController.h"
#import "UDJFBViewController.h"
#import "UDJPlayer.h"
#import "UDJPlayerData.h"
#import "UDJPlaylist.h"
#import "UDJSongList.h"
#import "UDJUserData.h"
#import "UDJClient.h"
#import <FacebookSDK/FacebookSDK.h>

@interface UDJAppDelegate ()

@property (strong, nonatomic) UINavigationController* navController;

@end

@implementation UDJAppDelegate

@synthesize window;
@synthesize viewController, navigationController;
@synthesize baseUrl;
@synthesize managedObjectModel, managedObjectContext, persistentStoreCoordinator;
@synthesize playerManager;
@synthesize navController = _navController;
@synthesize mainViewController = _mainViewController;

// accessor methods for "data" property

- (void) setModelData:(NSString *) newData {
	modelData = newData;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"dataChangeEvent" object:self];
}

- (NSString *) getModelData {
	if ( modelData == nil ) {
		modelData = @"Hello World";
	}
	return modelData;
    
    
}

#pragma mark - Core Data methods

- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"udj.sqlite"]];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}



#pragma mark -
#pragma mark Appelication lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Override point for customization after application launch.
    
    //init UDJData
    UDJUserData* udjData = [[UDJUserData alloc] init];
    udjData.requestCount = 0;
    
    [UDJPlayerData new]; // eventData singleton
    self.playerManager = [[UDJPlayerManager alloc] init]; // player manager singleton
    
    
    // initialize  UDClient
    baseUrl = @"https://udjplayer.com:4898/udj/0_7";
    UDJClient* client = [UDJClient alloc];
    client = [client initWithBaseURL: [NSURL URLWithString: baseUrl]];
    client.baseURLString = @"https://udjplayer.com:4898/udj/0_7";;
    
    [UDJPlaylist sharedUDJPlaylist].globalData = [UDJUserData sharedUDJData];
    
    //create a UDJViewController (the login screen), and make it the root view
    viewController    = [[UDJViewController alloc] initWithNibName:@"UDJViewController" bundle:[NSBundle mainBundle]];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.navigationController setNavigationBarHidden:YES];
	//[self.navigationController setDelegate:self];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    
}
- (BOOL)applicationDidFinishLaunchingWithOptions:(UIApplication *)application {
    // Override point for customization after application launch.
    
    //init UDJData
    UDJUserData* udjData = [[UDJUserData alloc] init];
    udjData.requestCount = 0;
    
    [UDJPlayerData new]; // eventData singleton
    self.playerManager = [[UDJPlayerManager alloc] init]; // player manager singleton
    
    
    // initialize  UDClient
    baseUrl = @"https://udjplayer.com:4898/udj/0_7";
    UDJClient* client = [UDJClient alloc];
    client = [client initWithBaseURL: [NSURL URLWithString: baseUrl]];
    client.baseURLString = @"https://udjplayer.com:4898/udj/0_7";;
    
    [UDJPlaylist sharedUDJPlaylist].globalData = [UDJUserData sharedUDJData];
    
    //create a UDJViewController (the login screen), and make it the root view
    viewController    = [[UDJViewController alloc] initWithNibName:@"UDJViewController" bundle:[NSBundle mainBundle]];
    self.mainViewController = [[UDJViewController alloc]
                               initWithNibName:@"UDJFBViewController" bundle:nil];
    self.navController = [[UINavigationController alloc]
                          initWithRootViewController:self.mainViewController];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    // See if the app has a valid token for the current state.
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // To-do, show logged in view
    } else {
        // No, display the login page.
        [self showLoginView];
    }
    return YES;
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            UIViewController *topViewController =
            [self.navController topViewController];
            if ([[topViewController modalViewController]
                 isKindOfClass:[UDJViewController class]]) {
                [topViewController dismissModalViewControllerAnimated:YES];
            }
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)openSession
{
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (void)showLoginView
{
    UIViewController *topViewController = [self.navController topViewController];
    
    UDJViewController* loginViewController =
    [[UDJViewController alloc]initWithNibName:@"UDJViewController" bundle:nil];
    [topViewController presentModalViewController:loginViewController animated:NO];
}




- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"App entered background");
    if([[UDJPlayerManager sharedPlayerManager] isInPlayerMode])
        [[UDJPlayerManager sharedPlayerManager] enterBackgroundMode];
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    if([[UDJPlayerManager sharedPlayerManager] isInPlayerMode])
        [[UDJPlayerManager sharedPlayerManager] exitBackgroundMode];
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // TODO: check if our ticket is still valid
    if([UDJUserData sharedUDJData].username != nil && ![[UDJUserData sharedUDJData] ticketIsValid]){
        NSLog(@"Renewing the ticket");
        [[UDJUserData sharedUDJData] renewTicket];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // leave any event we may be in
    NSLog(@"terminated");
}

//Facebook
- (BOOL)handleOpenURL:(NSURL*)url
{
    //FIXME
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
{
    return [self handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    return [self handleOpenURL:url];  
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}





@end
