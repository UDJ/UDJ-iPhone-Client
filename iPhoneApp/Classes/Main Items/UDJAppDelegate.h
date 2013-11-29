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

#import <UIKit/UIKit.h>
#import "UDJPlayerManager.h"


@class UDJViewController;

@interface UDJAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UDJViewController *viewController;
    UINavigationController *navigationController;
    NSString* baseUrl;
	
    //Application Model Data
    NSString *modelData;
	
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UDJViewController *viewController;
@property (nonatomic, strong) IBOutlet UDJViewController *mainViewController;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) NSString* baseUrl;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;  
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property(nonatomic,strong) UDJPlayerManager* playerManager;

- (void) setModelData:(NSString *)modelData;
- (NSString *) getModelData;
- (void)openSession;


@end

