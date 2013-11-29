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

#import "UDJPlayerData.h"
#import "UDJClient.h"
#import "JSONKit.h"

@implementation UDJPlayerData

@synthesize currentList, lastSearchParam, currentPlayer, locationManager, globalData, leaveEventDelegate, playerListDelegate;

// getNearbyEvents: has the UDJConnection send a event search request
- (void) getNearbyPlayers{
    UDJClient* client = [UDJClient sharedClient];
    
    // use location manager to get long/latitude
    float latitude = [locationManager getLatitude];
    float longitude = [locationManager getLongitude];
    
    // create URL
    NSString* urlString = client.baseURLString;
    urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"/players?latitude=%f&longitude=%f", latitude, longitude, nil]];
    NSURL* url = [NSURL URLWithString:urlString];
    
    // create GET request
    UDJRequest* request = [[UDJRequest alloc] initWithURL:url];
    request.delegate = playerListDelegate;
    request.method = UDJRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    
    request.userData = [NSNumber numberWithInt: globalData.requestCount++]; 
    
    // send request 
    [request send];
    //[self handleEventResults:response isNearbySearch:NO];
}

// getEventsByName
- (void)getPlayersByName:(NSString *)name{
    UDJClient* client = [UDJClient sharedClient];
    
    name = [name stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    // create the URL
    NSString* urlString = client.baseURLString;
    urlString = [urlString stringByAppendingString:@"/players?name="];
    urlString = [urlString stringByAppendingString:name];
    NSURL* url = [NSURL URLWithString:urlString];
    NSLog(@"URL: %@", [url absoluteString]);
    
    //create GET request with correct parameters and headers
    UDJRequest* request = [[UDJRequest alloc] initWithURL:url];
    request.delegate = playerListDelegate;
    request.method = UDJRequestMethodGET;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    // send request and handle response
    [request send];
}

// joinPlayer: attempts to log in user to party, returns status code of response
- (void)joinPlayer:(NSString*)password{

    UDJClient* client = [UDJClient sharedClient];
    
    //create url
    NSString* urlString = client.baseURLString;
    urlString = [urlString stringByAppendingString:@"/players/"];
    urlString = [urlString stringByAppendingFormat:@"%@", self.currentPlayer.playerID];
    urlString = [urlString stringByAppendingString:@"/users/user"];
    
    //set up request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = playerListDelegate;
    request.method = UDJRequestMethodPUT;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    // add the password to the header if neccessary
    if(password != nil){ 
        NSDictionary* bodyDict = [NSDictionary dictionaryWithObject:password forKey:@"password"];
        request.HTTPBodyString = [bodyDict JSONString];
        
        //set content-type header to text/json
        NSMutableDictionary* headerDict = [NSMutableDictionary dictionaryWithDictionary: request.additionalHTTPHeaders];
        [headerDict setObject:@"text/json" forKey:@"content-type"];
        request.additionalHTTPHeaders = headerDict;
    }
    
    //send request
    [request send];
}

-(void)leavePlayer{
    UDJRequest* request = [UDJRequest requestWithMethod: UDJRequestMethodDELETE];
    
    NSString* urlString  = [NSString stringWithFormat: @"%@/players/%@/users/user", [UDJClient sharedClient].baseURLString, self.currentPlayer.playerID];
    request.URL = [NSURL URLWithString: urlString];
    request.delegate = playerListDelegate;
    request.additionalHTTPHeaders = [UDJUserData sharedUDJData].headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    [request send];
}

-(void)setState:(NSString*)state{
    UDJClient* client = [UDJClient sharedClient];
    //create url [POST] /udj/users/user_id/players/player_id/state
    NSString* urlString = client.baseURLString;
    urlString = [urlString stringByAppendingFormat: @"/players/%@/state", currentPlayer.playerID, nil];
    
    //set up request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSDictionary* stateParam = [NSDictionary dictionaryWithObjectsAndKeys: state, @"state", nil]; 
    request.params = stateParam;
    request.method = UDJRequestMethodPOST;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    //send request, handle results
    [request send];    
}

//[POST] /udj/users/user_id/players/player_id/volume
-(void)setVolume:(NSInteger)volume{
    UDJClient* client = [UDJClient sharedClient];
    //create url [POST] /udj/users/user_id/players/player_id/state
    NSString* urlString = client.baseURLString;
    urlString = [urlString stringByAppendingFormat: @"/players/%@/volume", currentPlayer.playerID, nil];
    
    //set up request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSDictionary* volumeParam = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt: volume], @"volume", nil]; 
    request.params = volumeParam;
    request.method = UDJRequestMethodPOST;
    request.additionalHTTPHeaders = globalData.headers;
    request.userData = [NSNumber numberWithInt: globalData.requestCount++];
    
    //send request, handle results
    [request send];    
}


// access the EventList anywhere using [EventList sharedEventList]
#pragma mark Singleton methods
static UDJPlayerData* _sharedEventList = nil;

+(UDJPlayerData*)sharedPlayerData{
    @synchronized([UDJPlayerData class]){
        if (!_sharedEventList)
                _sharedEventList = [[self alloc] init];        
        return _sharedEventList;
    }    
    return nil;
}

+(id)alloc{
    @synchronized([UDJPlayerData class]){
        NSAssert(_sharedEventList == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedEventList = [super alloc];
        return _sharedEventList;
    }
    return nil;
}

-(id)init {
    self = [super init];
    
    locationManager = [[LocationManager alloc] init];
    globalData = [UDJUserData sharedUDJData];
    
    return self;
}

@end
