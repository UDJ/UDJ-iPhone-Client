//
//  EventList.h
//  UDJ
//
//  Created by Matthew Graf on 12/21/11.
//  Copyright (c) 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDJConnection.h"

@interface EventList : NSObject{
    
    NSMutableArray* currentList; // holds the last event list we loaded
    NSMutableArray* tempList; // list to use while we are loading events
    NSString* lastSearchParam; // the last string we tried searching
    BOOL refresh; // whether or not to refresh the list
}

+ (EventList*)sharedEventList;
- (void)getNearbyEvents; // put the nearby events into templist, then set it to currentList
- (void)getEventsByName:(NSString*)name; // search for events by name and put them in table

@property(nonatomic,retain) NSMutableArray* currentList;
@property(nonatomic,retain) NSMutableArray* tempList;
@property(nonatomic,retain) NSString* lastSearchParam;
@property(nonatomic) BOOL refresh;

@end