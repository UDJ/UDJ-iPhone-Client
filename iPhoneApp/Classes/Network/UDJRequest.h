//
//  UDJRequest.h
//  UDJ
//
//  Created by Matthew Graf on 1/7/13.
//
//

#import <Foundation/Foundation.h>
#import "UDJRequestDelegate.h"

typedef enum UDJRequestMethod{
    UDJRequestMethodGET,
    UDJRequestMethodPUT,
    UDJRequestMethodPOST,
    UDJRequestMethodDELETE
}UDJRequestMethod;

typedef enum UDJRequestBackgroundPolicy{
    UDJRequestBackgroundPolicyCancel,
    UDJRequestBackgroundPolicyContinue
}UDJRequestBackgroundPolicy;



@interface UDJRequest : NSObject

@property(nonatomic,strong) id<UDJRequestDelegate> delegate;
@property(nonatomic,strong) NSDictionary* additionalHTTPHeaders;
@property(nonatomic,strong) NSDictionary* params;
@property UDJRequestMethod method;
@property(nonatomic,strong) NSURL* URL;
@property(nonatomic,strong) id userData;
@property UDJRequestBackgroundPolicy backgroundPolicy;
@property(nonatomic,strong) NSData* HTTPBody;
@property(nonatomic,strong) NSString* HTTPBodyString;
@property NSInteger timeoutInterval;

+(UDJRequest*)requestWithMethod:(UDJRequestMethod)method;
+(UDJRequest*)requestWithURL:(NSURL*)url;
-(id)initWithURL:(NSURL*)url;
-(void)send;
-(UDJResponse*)sendSynchronously;

-(BOOL)isGET;
-(BOOL)isPUT;
-(BOOL)isPOST;
-(BOOL)isDELETE;

@end
