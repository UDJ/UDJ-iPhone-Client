//
//  UDJPlayerInfoManager.h
//  UDJ
//
//  Created by Matthew Graf on 8/31/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDJUserData.h"

@interface UDJPlayerInfoManager : NSObject <UDJRequestDelegate>

@property NSString* playerID;
@property(nonatomic,strong) NSString* playerName;
@property(nonatomic,strong) NSString* playerPassword;
@property(nonatomic,strong) NSString* address;
@property(nonatomic,strong) NSString* stateLocation;
@property(nonatomic,strong) NSString* city;
@property(nonatomic,strong) NSString* zipCode;

@property(nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property(nonatomic,strong) UDJUserData* globalData;

+(UDJPlayerInfoManager*)sharedPlayerInfoManager;
-(void)updateCurrentPlayer;
-(void)loadPlayerInfo;
-(void)savePlayerInfo;
-(void)updateInfoOnServer;

@end
