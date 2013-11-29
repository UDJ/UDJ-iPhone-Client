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
#import "LocationManager.h"
#import "UDJPlayer.h"
#import "UDJUserData.h"

@interface UDJPlayerData : NSObject{
    
    NSMutableArray* currentList; // holds the last event list we loaded
    NSString* lastSearchParam; // the last string we tried searching
    UDJPlayer* currentPlayer; // the event id the client is logged in/trying to connect to
    
    UDJUserData* globalData;
}

+ (UDJPlayerData*)sharedPlayerData;
- (void)getNearbyPlayers; // put the nearby events into templist, then set it to currentList
- (void)getPlayersByName:(NSString*)name; // search for events by name and put them in table
- (void)joinPlayer:(NSString*)password;
-(void)leavePlayer;
-(void)setState:(NSString*)state;
-(void)setVolume:(NSInteger)volume;

@property(nonatomic,strong) NSMutableArray* currentList;
@property(nonatomic,strong) NSString* lastSearchParam;
@property(nonatomic,strong) UDJPlayer* currentPlayer;
@property(nonatomic,strong) LocationManager* locationManager;
@property(nonatomic,strong) UDJUserData* globalData;
@property(nonatomic,strong) UIViewController<UDJRequestDelegate>* playerListDelegate;
@property(nonatomic,strong) UIViewController<UDJRequestDelegate>* leaveEventDelegate;

@end
