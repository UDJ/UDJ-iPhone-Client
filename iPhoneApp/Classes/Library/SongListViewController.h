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
#import "UDJSong.h"
#import "UDJSongList.h"
#import "UDJUserData.h"

enum UDJQueryType {
    UDJQueryTypeArtist,
    UDJQueryTypeGeneric
};

@interface SongListViewController : UIViewController{
    NSInteger MAX_RESULTS;
}



@property(nonatomic,strong) IBOutlet UILabel* statusLabel;
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView* searchIndicatorView;
@property(nonatomic,strong) IBOutlet UITableView* songTableView;

@property(nonatomic,strong) UDJUserData* globalData;
@property(nonatomic,strong) NSNumber* currentRequestNumber;

@property(nonatomic,strong) UDJSongList* resultList;

@property(nonatomic,strong) NSString* lastQuery;
@property enum UDJQueryType lastQueryType;

@property(nonatomic,strong) IBOutlet UIView* addNotificationView;
@property(nonatomic,strong) IBOutlet UILabel* addNotificationLabel;

@property(nonatomic,strong) IBOutlet UISearchBar* searchBar;

@property(nonatomic,unsafe_unretained) id<UDJRequestDelegate> artistViewController;


-(void)getSongsByArtist:(NSString*)artist;
-(void)getSongsByQuery:(NSString*)query;

- (void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response;

@end
