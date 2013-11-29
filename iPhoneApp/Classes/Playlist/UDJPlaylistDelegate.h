//
//  UDJPlaylistDelegate.h
//  UDJ
//
//  Created by Matthew Graf on 8/19/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UDJPlaylistDelegate <NSObject>

@required 

-(void)playlistDidUpdate:(NSDictionary*)responseDictionary;

@end
