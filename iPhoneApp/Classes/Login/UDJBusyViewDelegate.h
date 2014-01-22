//
//  UDJBusyViewDelegate.h
//  UDJ
//
//  Created by Matthew Graf on 1/17/14.
//
//

#import <Foundation/Foundation.h>

@protocol UDJBusyViewDelegate <NSObject>

@required
-(void)actionCanceled;

@end
