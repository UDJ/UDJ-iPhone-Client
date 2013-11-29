//
//  UDJResponseDelegate.h
//  UDJ
//
//  Created by Matthew Graf on 1/7/13.
//
//

#import <Foundation/Foundation.h>
#import "UDJResponse.h"

@class UDJRequest;

@protocol UDJRequestDelegate <NSObject>

@required

-(void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response;

@end
