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

#import "UDJSong.h"

// Active Playlist Entry
@implementation UDJSong

@synthesize librarySongId, title, artist, album, duration, downVoters, upVoters, timeAdded, track, genre, adder;

+ (id) songFromDictionary:(NSDictionary *)songDict isLibraryEntry:(BOOL)isLibEntry{
    if([songDict count]==0) return nil;
    UDJSong* song = [UDJSong new];
    
    // this dictionary will be used for reading the Library Entry fields
    NSDictionary* libEntryDict;
    if(isLibEntry) libEntryDict = songDict;
    else libEntryDict = [songDict objectForKey: @"song"];
    
    song.title = [libEntryDict objectForKey:@"title"];
    song.librarySongId = [libEntryDict objectForKey:@"id"]; // TODO: change this back to intValue?
    song.artist = [libEntryDict objectForKey:@"artist"];
    song.album = [libEntryDict objectForKey:@"album"];
    song.duration = [[libEntryDict objectForKey:@"duration"] intValue];
    song.track = [[libEntryDict objectForKey:@"track"] intValue];
    song.genre = [libEntryDict objectForKey:@"genre"];
    
    // initialize up/down voters array
    NSArray* upVotersArray = [songDict objectForKey:@"upvoters"];
    NSArray* downVotersArray = [songDict objectForKey:@"downvoters"];
    song.upVoters = [NSMutableArray arrayWithCapacity: [upVotersArray count]];
    song.downVoters = [NSMutableArray arrayWithCapacity: [downVotersArray count]];
    for(int i=0; i < [upVotersArray count]; i++){
        UDJUser* user = [UDJUser userFromDict: [upVotersArray objectAtIndex: i]];
        [song.upVoters addObject: user];
    }
    for(int i=0; i < [downVotersArray count]; i++){
        UDJUser* user = [UDJUser userFromDict: [downVotersArray objectAtIndex: i]];
        [song.downVoters addObject: user];
    }
    song.timeAdded = [songDict objectForKey:@"time_added"];
    
    song.adder = [UDJUser userFromDict: [songDict objectForKey:@"adder"]];
    return song;
}

@end
