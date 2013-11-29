//
//  UDJClient.m
//  UDJ
//
//  Created by Matthew Graf on 12/27/12.
//
//

#import "UDJClient.h"

@implementation UDJClient

static UDJClient* sharedUDJClient = nil;

+(UDJClient*)sharedClient{
    @synchronized([UDJClient class]){
        if (!sharedUDJClient)
            sharedUDJClient = [[self alloc] init];
        return sharedUDJClient;
    }
    return nil;
}

+(id)alloc{
    @synchronized([UDJClient class]){
        NSAssert(sharedUDJClient == nil, @"Attempted to allocate a second instance of a singleton.");
        sharedUDJClient = [super alloc];
        return sharedUDJClient;
    }
    return nil;
}

-(id)init {
    if(self = [super init]){
        
    }

    return self;
}

@end
