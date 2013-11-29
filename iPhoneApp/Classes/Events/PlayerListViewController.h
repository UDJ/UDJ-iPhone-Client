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
#import "UDJUserData.h"
#import "UDJPlayerData.h"
#import "PullRefreshTableViewController.h"

enum SearchType {
    SearchTypeNull = 0,
    SearchTypeName = 1,
    SearchTypeNearby = 2
};

@interface PlayerListViewController : UIViewController <UIAlertViewDelegate, UDJRequestDelegate, UISearchBarDelegate>


@property enum SearchType lastSearchType;
@property(nonatomic,strong) NSString* lastSearchQuery;

@property(nonatomic,strong) UDJPlayerData* playerData;

@property(nonatomic,strong) NSMutableArray *tableList;
@property(nonatomic,strong) IBOutlet UITableView* tableView;
@property(nonatomic,strong) IBOutlet UILabel* statusLabel;

@property(nonatomic,strong) UDJUserData* globalData;
@property(nonatomic,strong) NSNumber* currentRequestNumber;

@property(nonatomic,strong) IBOutlet UISearchBar* playerSearchBar;
@property(nonatomic,strong) IBOutlet UIButton* findNearbyButton;
@property(nonatomic,strong) IBOutlet UIButton* cancelSearchButton;
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView* searchIndicatorView;

@property(nonatomic,strong) IBOutlet UIView* joiningView;
@property(nonatomic,strong) IBOutlet UIView* joiningBackgroundView;

@property BOOL shouldShowMyPlayer;

@end
