//
//  UDJSong.m
//  UDJ
//
//  Created by Matthew Graf on 12/27/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJSong.h"

@implementation UDJSong

@synthesize songId, librarySongId, title, artist, duration, downVotes, upVotes, timeAdded, adderId, adderName;

+ (id) songFromDictionary:(NSDictionary *)songDict{
    UDJSong* song = [UDJSong new];
    return song;
}

// memory managed
-(void)dealloc{
    [title release];
    [artist release];
    [adderName release];
    [super dealloc];
}

@end