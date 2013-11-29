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

#import "UDJEventGoerList.h"

@implementation UDJEventGoerList

@synthesize eventGoerList;

- (id) init{
    self = [super init];
    if (self != nil){
        eventGoerList = [NSMutableArray new];
    }
    return self;
}

-(UDJEventGoer*)eventGoerAtIndex:(NSInteger)i{
    UDJEventGoer* eventGoer = [eventGoerList objectAtIndex:i];
    return eventGoer;
}

-(void)addEventGoer:(UDJEventGoer*)eventGoer{
    [eventGoerList addObject:eventGoer];
}

-(NSInteger)count{
    return [eventGoerList count];
}

@end
