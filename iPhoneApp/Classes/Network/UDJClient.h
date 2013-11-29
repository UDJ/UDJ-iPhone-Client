//
//  UDJClient.h
//  UDJ
//
//  Created by Matthew Graf on 12/27/12.
//
//

#import "UDJRequestDelegate.h"
#import "UDJRequest.h"
#import "UDJResponse.h"
#import "AFHTTPClient.h"

@interface UDJClient : AFHTTPClient

@property(nonatomic,strong) NSURL* baseURL;
@property(nonatomic,strong) NSString* baseURLString;

+(UDJClient*)sharedClient;

@end
    