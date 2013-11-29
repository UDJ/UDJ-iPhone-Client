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
#import "UDJUser.h"

@interface UDJPlayer : NSObject{
    
}

+ (UDJPlayer*)playerFromDictionary:(NSDictionary*)playerDict;

@property(nonatomic,strong) NSString* playerID;
@property(nonatomic,strong) NSString* name;
@property(nonatomic) double latitude;
@property(nonatomic) double longitude;
// location dictionary has: latitude, longitude, address, locality, region, postal_code, country
@property(nonatomic,strong) NSDictionary* locationDict;
@property(nonatomic) BOOL hasPassword;
@property(nonatomic,strong) NSString* sortingAlgo;
@property(nonatomic) NSInteger numActiveUsers;
@property(nonatomic) NSInteger sizeLimit;
@property(nonatomic,strong) NSString* state; // player state (not US state)
@property(nonatomic) NSInteger volume;
@property(nonatomic,strong) UDJUser* owner;

@end
