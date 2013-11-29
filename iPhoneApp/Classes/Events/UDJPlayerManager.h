//
//  UDJPlayerManager.h
//  UDJ
//
//  Created by Matthew Graf on 7/28/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UDJUserData.h"
#import <AVFoundation/AVFoundation.h>
#import "UDJPlaylist.h"

typedef enum {
    PlayerStateInactive,
    PlayerStatePlaying,
    PlayerStatePaused
} PlayerState;

@interface UDJPlayerManager : NSObject <UDJRequestDelegate>

@property NSString* playerID;

@property BOOL isInPlayerMode;
@property PlayerState playerState;
@property BOOL isInBackground;

@property(nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property(nonatomic,strong) NSMutableDictionary* songSyncDictionary;
@property(nonatomic,strong) UDJUserData* globalData;

@property(nonatomic,strong) AVQueuePlayer* audioPlayer;
@property(nonatomic,strong) MPMediaItem* currentMediaItem;
@property BOOL nextSongAdded;

@property double songLength;
@property double songPosition;

@property(nonatomic,strong) NSTimer* playlistTimer;

@property(nonatomic,weak) UIViewController* UIDelegate;
@property(nonatomic,weak) UDJPlaylist* playlist;

+(UDJPlayerManager*)sharedPlayerManager;
-(void)updatePlayerMusic;
-(void)changePlayerState:(PlayerState)newState;

-(float)currentPlaybackTime;

-(void)enterBackgroundMode;
-(void)exitBackgroundMode;

-(BOOL)play;
-(void)pause;
-(void)updateSongPosition:(NSInteger)seconds;
-(void)playNextSong;

-(void)resetAudioPlayer;

-(void)beginPlaylistUpdates;
-(void)endPlaylistUpdates;

- (void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response;

@end
