//
//  UDJResponse.m
//  UDJ
//
//  Created by Matthew Graf on 1/7/13.
//
//

#import "UDJResponse.h"

@implementation UDJResponse

-(BOOL)isOK{
    return self.statusCode == 200;
}

-(id)initWithNSHTTPURLResponse:(NSHTTPURLResponse*)response andData:(NSData*)data{
    if(self = [super init]){
        self.statusCode = response.statusCode;
        self.bodyAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.allHeaderFields = response.allHeaderFields;
    }
    return self;
}

@end
