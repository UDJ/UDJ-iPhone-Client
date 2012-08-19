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

@synthesize playerID, name, hostId, latitude, longitude, hostUsername, hasPassword;

+ (UDJPlayer*) eventFromDictionary:(NSDictionary *)eventDict{
    UDJPlayer* event = [UDJPlayer new];
    event.name = [eventDict objectForKey:@"name"];
    event.playerID = [[eventDict objectForKey:@"id"] integerValue];
    event.hostId = [[eventDict objectForKey:@"owner_id"] integerValue];
    event.latitude = [[eventDict objectForKey:@"latitude"] doubleValue];
    event.longitude = [[eventDict objectForKey:@"longitude"] doubleValue];
    event.hostUsername = [eventDict objectForKey:@"owner_username"];
    event.hasPassword = [[eventDict objectForKey:@"has_password"] boolValue];
    return event;
}

// memory managed
@end