//
//  LibraryEntryCell.h
//  UDJ
//
//  Created by Matthew Graf on 1/16/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LibraryEntryCell : UITableViewCell{
    UILabel* songLabel;
    UILabel* artistLabel;
    UIButton* addButton;
}

@property(nonatomic,retain) UILabel* songLabel;
@property(nonatomic,retain) UILabel* artistLabel;
@property(nonatomic,retain) UIButton* addButton;

@end
