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

@interface UDJSong : NSObject{
    NSString* title;
    NSString* artist;
    NSString* album;
    NSInteger duration;
    NSInteger downVotes;
    NSInteger upVotes;
    NSString* timeAdded;
}

+ (id)songFromDictionary:(NSDictionary*)songDict isLibraryEntry:(BOOL)isLibEntry;

@property(nonatomic,strong) NSString* libraryID;
@property(nonatomic,strong) NSString* songID;
@property(nonatomic,strong) NSString* title;
@property(nonatomic,strong) NSString* artist;
@property(nonatomic,strong) NSString* album;
@property(nonatomic) NSInteger duration;
@property(nonatomic,strong) NSString* timeAdded;
@property(nonatomic,strong) NSMutableArray* upVoters;
@property(nonatomic,strong) NSMutableArray* downVoters;
@property NSInteger track;
@property(nonatomic,strong) NSString* genre;

@property(nonatomic,strong) UDJUser* adder;

@end