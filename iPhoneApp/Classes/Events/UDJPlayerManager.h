//
//  UDJPlayerManager.h
//  UDJ
//
//  Created by Matthew Graf on 7/28/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UDJData.h"

typedef enum {
    PlayerStateInactive,
    PlayerStatePlaying,
    PlayerStatePaused
} PlayerState;

@interface UDJPlayerManager : NSObject

@property(nonatomic,strong) NSString* playerName;
@property(nonatomic,strong) NSString* playerPassword;
@property(nonatomic,strong) NSString* address;
@property(nonatomic,strong) NSString* stateLocation;
@property(nonatomic,strong) NSString* city;
@property(nonatomic,strong) NSString* zipCode;
@property NSInteger playerID;

@property BOOL isInPlayerMode;

@property(nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property(nonatomic,strong) NSMutableDictionary* songSyncDictionary;
@property(nonatomic,strong) UDJData* globalData;

+(UDJPlayerManager*)sharedPlayerManager;
-(void)loadPlayerInfo;
-(void)savePlayerInfo;
-(void)updatePlayerMusic;
-(void)changePlayerState:(PlayerState)newState;

@end