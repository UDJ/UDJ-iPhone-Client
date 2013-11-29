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
#import "PullRefreshTableViewController.h"

@interface ArtistsViewController : PullRefreshTableViewController <UDJRequestDelegate,UISearchBarDelegate>

@property(nonatomic,strong) IBOutlet UISearchBar* searchBar;
@property(nonatomic,strong) NSMutableArray* artistsArray;
@property(nonatomic,strong) IBOutlet UDJUserData* globalData;

@property(nonatomic,strong) IBOutlet UILabel* statusLabel;
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView* searchIndicatorView;

@property(nonatomic,strong) NSNumber* currentRequestNumber;

-(void)sendArtistsRequest;

@end
