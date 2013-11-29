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

#import "UDJUser.h"

@implementation UDJUser

@synthesize userID, username, firstName, lastName;

+(UDJUser*)userFromDict:(NSDictionary*)dict{
    UDJUser* user = [UDJUser new];
    user.userID = [dict objectForKey: @"id"];
    user.username = [dict objectForKey: @"username"];
    user.firstName = [dict objectForKey: @"first_name"];
    user.lastName = [dict objectForKey: @"last_name"];
    return user;
}

@end
