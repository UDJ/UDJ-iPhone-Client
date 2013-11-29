//
//  UDJStoredLibraryEntry.h
//  UDJ
//
//  Created by Matthew Graf on 7/30/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UDJStoredLibraryEntry : NSManagedObject

@property (nonatomic, retain) NSNumber* libraryID;
@property (nonatomic, retain) NSNumber* synced;

@end
