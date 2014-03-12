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

#import "UDJUserData.h"
#import "UDJStoredData.h"
#import "UDJAppDelegate.h"
#import "JSONKit.h"
#import "SongListViewController.h"
#import "PlayerInfoViewController.h"
#import "UDJPlayerManager.h"
#import "UDJClient.h"

@implementation UDJUserData

@synthesize requestCount, ticket, headers, userID, username, password, loggedIn, managedObjectContext;
@synthesize songAddDelegate, playerCreateDelegate;
@synthesize firstName;
@synthesize lastName;


#pragma mark - Ticket validation

-(BOOL)ticketIsValid{
    
    UDJStoredData* storedData;
    NSError* error;
    
    //Set up a request to get the stored data
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredData" inManagedObjectContext:managedObjectContext]];
    storedData = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        // error in getting info
    }
    
    // if there we had previous data
    if (storedData) {
        NSDate* currentDate = [NSDate date];
        NSDate* lastDate = [storedData ticketDate];
        float secondsSince = [currentDate timeIntervalSinceDate: lastDate];
        float hoursSince = secondsSince/60/60;
        
        // if it has been more than 20 hours, we'll renew the ticket to be safe
        if(hoursSince >= 20){
            return NO;
        }
        
        // otherwise this ticket is valid (at least for the next 4 hours)
        else return YES;
    }
    
    // If there is no data that means we've never logged in,
    // meaning the user is about to log in and get a ticket.
    // So don't worry about it and consider it valid
    
    return YES;
}

-(void)renewTicket{
    
    if(self.username == nil) return;
    
    UDJClient* client = [UDJClient sharedClient];
    
    // make sure the right api version is being passed in
    NSDictionary* nameAndPass = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", password, @"password", nil]; 
    
    // put the API version in the header
    NSDictionary* apiHeader = [NSDictionary dictionaryWithObjectsAndKeys:@"0.5", @"X-Udj-Api-Version", @"renewTicket", @"requestType", nil];
    
    // create the URL
    NSMutableString* urlString = [NSMutableString stringWithString: client.baseURLString];
    [urlString appendString: @"/auth"];
    
    // set up request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self;
    request.params = nameAndPass;
    request.method = UDJRequestMethodPOST;
    request.additionalHTTPHeaders = apiHeader;

    [request send];    
}

-(void)handleRenewTicket:(UDJResponse*)response{
    if([response isOK]){
        // only handle if we are waiting for an auth response
        NSDictionary* responseDict = [[response bodyAsString] objectFromJSONString];
        ticket=[responseDict valueForKey:@"ticket_hash"];
        userID=[responseDict valueForKey:@"user_id"];
        
        headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:ticket, @"X-Udj-Ticket-Hash", nil];
        
        NSLog(@"renewed ticket");
    }
    else{
        NSLog(@"couldnt renew ticket, trying again");
        [self renewTicket];
    }
}


// Handle responses from the server
- (void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response {
    
    NSDictionary* responseHeaders = request.additionalHTTPHeaders;
    NSString* responseDelegate = [responseHeaders objectForKey: @"delegate"];
    
    NSLog(@"Global Data %d, URL %@", [response statusCode], [request.URL absoluteString]);
    
    /*if([responseDelegate isEqualToString: @"participantDelegate"] && participantDelegate != nil){
        [participantDelegate request:request didLoadResponse:response];
    }*/
    
    if([responseDelegate isEqualToString: @"songAddDelegate"]){
        if(songAddDelegate != nil){
            SongListViewController* songListViewController = (SongListViewController*)songAddDelegate;
            [songListViewController request: request didLoadResponse: response];
        }
        else NSLog(@"delegate was nil");
    }
    
    else if([responseDelegate isEqualToString: @"playerCreateDelegate"]){
        if(playerCreateDelegate != nil){
            PlayerInfoViewController* playerInfoViewController = (PlayerInfoViewController*)playerCreateDelegate;
            [playerInfoViewController request: request didLoadResponse: response];            
        }
    }
    
    else if([responseDelegate isEqualToString: @"playerMethodsDelegate"]){
        [[UDJPlayerManager sharedPlayerManager] request:request didLoadResponse:response];
    }
        //  && [[responseHeaders objectForKey: @"requestType"] isEqualToString:@"renewTicket"]
    else if([request isPOST]) {
        [self handleRenewTicket:response];
    }
}


#pragma mark Singleton methods
static UDJUserData* _sharedUDJData = nil;

+(UDJUserData*)sharedUDJData{
	@synchronized([UDJUserData class]){
		if (!_sharedUDJData){
			_sharedUDJData = [[self alloc] init]; 
    
        }
		return _sharedUDJData;
	}    
	return nil;
}

+(id)alloc{
	@synchronized([UDJUserData class]){
		NSAssert(_sharedUDJData == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedUDJData = [super alloc];
		return _sharedUDJData;
	}
	return nil;
}

-(id)init{
    if(self = [super init]){
        UDJAppDelegate* appDelegate = (UDJAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [appDelegate managedObjectContext];
    }
    return self;
}

@end
