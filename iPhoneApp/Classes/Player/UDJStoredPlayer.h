//
//  UDJStoredPlayer.h
//  UDJ
//
//  Created by Matthew Graf on 7/24/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UDJStoredPlayer : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * zipcode;
@property (nonatomic, retain) NSString * playerID;

@end
