/**
 * Copyright 2011 Matthew M. Graf
 *
 * This file is part of UDJ.
 *
 * UDJ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * UDJ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with UDJ.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Foundation/Foundation.h>
#import "UDJSong.h"
#import "UDJUserData.h"
#import "UDJPlaylistDelegate.h"

enum VoteStatus {
    VoteStatusNull = 0,
    VoteStatusDown = 1,
    VoteStatusUp = 2
};

@interface UDJPlaylist : NSObject<UDJRequestDelegate>{
    
    NSMutableArray* playlist;
    UDJSong* currentSong;
    
    NSMutableDictionary* voteRecordKeeper;
    
    
    UDJUserData* globalData;
}

+ (UDJPlaylist*)sharedUDJPlaylist;
- (UDJSong*)songPlaying;
- (UDJSong*)songAtIndex:(NSInteger)i;
- (void)sendPlaylistRequest;
- (NSInteger)count;
- (void)clearPlaylist;
- (void)sendVoteRequest:(BOOL)up forSong:(UDJSong*)song;

@property(nonatomic,strong) NSMutableArray* playlist;
@property(nonatomic,strong) NSString* playerID;
@property(nonatomic,strong) UDJSong* currentSong;
@property(nonatomic, strong) id<UDJRequestDelegate> delegate;
@property(nonatomic,strong) UDJUserData* globalData;

@property(nonatomic,weak) id<UDJPlaylistDelegate> playlistDelegate;


@end
