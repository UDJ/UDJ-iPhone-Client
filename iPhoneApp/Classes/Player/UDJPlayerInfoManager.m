//
//  UDJPlayerInfoManager.m
//  UDJ
//
//  Created by Matthew Graf on 8/31/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJPlayerInfoManager.h"
#import "UDJStoredPlayer.h"
#import "UDJAppDelegate.h"
#import "UDJPlayer.h"
#import "UDJPlayerData.h"
#import "UDJClient.h"

@implementation UDJPlayerInfoManager

@synthesize playerID;
@synthesize playerName;
@synthesize playerPassword;
@synthesize stateLocation;
@synthesize city;
@synthesize zipCode;
@synthesize address;
@synthesize managedObjectContext;
@synthesize globalData;

#pragma mark - Initialization

static UDJPlayerInfoManager* _sharedPlayerInfoManager = nil;

+(UDJPlayerInfoManager*)sharedPlayerInfoManager{
    @synchronized([UDJPlayerInfoManager class]){
        if (!_sharedPlayerInfoManager)
            _sharedPlayerInfoManager = [[self alloc] init];        
        return _sharedPlayerInfoManager;
    }    
    return nil;
}

+(id)alloc{
    @synchronized([UDJPlayerInfoManager class]){
        NSAssert(_sharedPlayerInfoManager == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedPlayerInfoManager = [super alloc];
        return _sharedPlayerInfoManager;
    }
    return nil;
}

-(id)init{
    if(self = [super init]){
        UDJAppDelegate* appDelegate = (UDJAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = appDelegate.managedObjectContext;
        self.playerID = nil;
        
        [self loadPlayerInfo];
    }
    return self;
}


#pragma mark - Saving player to persistent store

// Saves the player information to the device
-(void)savePlayerInfo{
    
    UDJStoredPlayer* storedPlayer;
    NSError* error;
    
    //Set up a request to get the last stored playlist
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredPlayer" inManagedObjectContext:managedObjectContext]];
    storedPlayer = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        // error in getting info
    }
    
    // if there was no stored player before, create it
    if (!storedPlayer) {
        storedPlayer = (UDJStoredPlayer*)[NSEntityDescription insertNewObjectForEntityForName:@"UDJStoredPlayer" inManagedObjectContext: managedObjectContext]; ;
    }
    
    // update the username, save the date the ticket was assigned
    [storedPlayer setName: self.playerName];
    [storedPlayer setAddress: self.address];
    [storedPlayer setCity: self.city];
    [storedPlayer setState: self.stateLocation];
    [storedPlayer setPassword: self.playerPassword];
    [storedPlayer setZipcode: self.zipCode];
    [storedPlayer setPlayerID: self.playerID];
    
    //Save the data
    error = nil;
    if (![managedObjectContext save:&error]) {
        //Handle any error with the saving of the context
    }
    
}

// Loads the player informatin from the device
-(void)loadPlayerInfo{
    
    UDJStoredPlayer* storedPlayer;
    NSError* error;
    
    //Set up a request to get the last stored player
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredPlayer" inManagedObjectContext:managedObjectContext]];
    storedPlayer = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        // error in getting info
    }
    
    // if there was a stored player, fill in the fields
    if (storedPlayer) {
        self.playerName = storedPlayer.name;
        self.playerPassword = storedPlayer.password;
        self.address = storedPlayer.address;
        self.city = storedPlayer.city;
        self.stateLocation = storedPlayer.state;
        self.zipCode = storedPlayer.zipcode;
        self.playerID = storedPlayer.playerID;
        
        [UDJPlayerManager sharedPlayerManager].playerID = self.playerID;
    }
}

#pragma mark - General player info

// Updates the global current player, so the rest of the app can make use of it
-(void)updateCurrentPlayer{
    UDJPlayer* player = [[UDJPlayer alloc] init];
    player.playerID = self.playerID;
    player.name = self.playerName;
    player.owner.userID = globalData.userID;
    player.owner.username = globalData.username;
    [UDJPlayerData sharedPlayerData].currentPlayer = player;
}

-(void)updateInfoOnServer{
    // update password
    if([playerPassword isEqualToString:@""]) [self removePassword];
    else [self updatePassword];
    [self updateLocation];
}

#pragma mark - Password modification

// Deletes password on server
-(void)removePassword{
    UDJRequest* request = [UDJRequest requestWithMethod: UDJRequestMethodDELETE];
    request.delegate = self;
    NSString* urlString = [NSString stringWithFormat: @"%@/players/%@/password", [UDJClient sharedClient].baseURLString, self.playerID];
    request.URL = [NSURL URLWithString: urlString];
    request.userData = @"updatePassword";
    [request send];
}

// Changes password on server
-(void)updatePassword{
    UDJRequest* request = [UDJRequest requestWithMethod: UDJRequestMethodPOST];
    request.delegate = self;

    NSString* urlString = [NSString stringWithFormat: @"%@/players/%@/password", [UDJClient sharedClient].baseURLString, self.playerID];
    request.URL = [NSURL URLWithString: urlString];
    request.userData = @"updatePassword";
    request.params = [NSDictionary dictionaryWithObject:self.playerPassword forKey:@"password"];
    [request send];
}

// Changes location on server
-(void)updateLocation{
    UDJRequest* request = [UDJRequest requestWithMethod: UDJRequestMethodPOST];
    request.delegate = self;
    // url 0_6/players/player_id/password
    NSString* urlString = [NSString stringWithFormat: @"%@/players/%@/location", [UDJClient sharedClient].baseURLString, self.playerID];
    request.URL = [NSURL URLWithString: urlString];
    request.userData = @"updateLocation";
    request.params = [NSDictionary dictionaryWithObjectsAndKeys: self.address, @"address", self.city, @"locality", self.stateLocation, @"region", self.zipCode, @"postal_code", @"United States", @"country", nil];
    [request send];
}


#pragma mark - Response handling

-(void)request:(UDJRequest *)request didLoadResponse:(UDJResponse *)response{
    NSString* requestType = [request userData];
    if([requestType isEqualToString: @"updatePassword"]){
        if([response statusCode] == 400){
            NSLog(@"Bad password");
        }
        else NSLog(@"Password response %d", [response statusCode]);
    }
    else{
        NSLog(@"Player info status code %d", [response statusCode]);
    }
}

@end
