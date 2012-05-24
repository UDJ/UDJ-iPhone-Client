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
#import "RestKit/RestKit.h"

@interface UDJData : NSObject<RKRequestDelegate>{
    NSString* ticket;
    NSNumber* userID;
    NSString* username;
}

@property NSInteger requestCount;
@property(nonatomic,strong) NSString* ticket;
@property(nonatomic,strong) NSMutableDictionary* headers;
@property(nonatomic,strong) NSNumber* userID;
@property(nonatomic,strong) NSString* username;
@property(nonatomic,strong) NSString* password;
@property BOOL loggedIn;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext; 

+(UDJData*)sharedUDJData;
-(BOOL)ticketIsValid;
-(void)renewTicket;
-(void)handleRenewTicket:(RKResponse*)response;

@end
