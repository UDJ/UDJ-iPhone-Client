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

// UDJResultList is used to store the results of a library search
// it is basically a wrapper class to ensure LibraryResultsController is using
// an array that only has UDJSongs in it
@interface UDJSongList : NSObject{
    NSMutableArray* currentList;
}

@property(nonatomic,strong) NSMutableArray* currentList;

-(void)addSong:(UDJSong*)song;
-(UDJSong*)songAtIndex:(NSUInteger)index;
-(NSInteger)count;


@end
