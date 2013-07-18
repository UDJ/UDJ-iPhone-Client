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

#import "UDJPlayer.h"

@implementation UDJPlayer

@synthesize playerID, name, latitude, longitude, hasPassword;
@synthesize locationDict;
@synthesize owner;

+ (UDJPlayer*) playerFromDictionary:(NSDictionary *)playerDict{
    UDJPlayer* player = [[UDJPlayer alloc] init];
    player.name = [playerDict objectForKey:@"name"];
    player.playerID = [playerDict objectForKey:@"id"];
    // !!!: since we're not currently making use of the other values of location (address, locality, etc.),
    // I'm leaving this dictionary here instead of making new properties
    player.locationDict = [playerDict objectForKey:@"location"];
    player.latitude = [[player.locationDict objectForKey: @"latitude"] doubleValue];
    player.longitude = [[player.locationDict objectForKey: @"longitude"] doubleValue];
    player.hasPassword = [[playerDict objectForKey:@"has_password"] boolValue];
    player.sortingAlgo = [playerDict objectForKey:@"sorting_algo"];
    player.numActiveUsers = [[playerDict objectForKey:@"num_active_users"] intValue];
    player.sizeLimit = [[playerDict objectForKey:@"size_limit"] intValue];
    player.state = [playerDict objectForKey:@"state"];
    player.volume = [[playerDict objectForKey:@"volume"] intValue];
    
    NSDictionary* ownerDict = [playerDict objectForKey:@"owner"];
    player.owner = [UDJUser userFromDict: ownerDict];
    return player;
}

// memory managed
@end
