/**
 * Copyright 2011 Matthew M. Graf
 *
 * This file is part of UDJ.
 *
 * UDJ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *r
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
#import "UDJData.h"

@interface ParticipantManager : NSObject <UITableViewDataSource, UDJRequestDelegate>

@property(nonatomic,strong) NSString* playerID;
@property(nonatomic,strong) UDJData* globalData;
@property(nonatomic,strong) NSMutableArray* participantArray;

-(void)getPlayerParticipants;

@end
