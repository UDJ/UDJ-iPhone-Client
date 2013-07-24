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

#import "LibraryEntryCell.h"
#import "UDJPlayerData.h"

@implementation LibraryEntryCell

@synthesize songLabel, artistLabel, addButton;
@synthesize song;

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    frame = CGRectMake(boundsX+275 ,1, 40, 40);
    addButton.frame = frame;
    
    frame= CGRectMake(boundsX+10 ,3, 250, 19);
    songLabel.frame = frame;
    
    frame= CGRectMake(boundsX+14 ,22, 250, 17);
    artistLabel.frame = frame;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        songLabel = [[UILabel alloc] init];
        songLabel.textAlignment = UITextAlignmentLeft;
        songLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        songLabel.textColor=[UIColor whiteColor];
        songLabel.backgroundColor = [UIColor clearColor];
        songLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        
        artistLabel = [[UILabel alloc]init];
        artistLabel.textAlignment = UITextAlignmentLeft;
        artistLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        artistLabel.textColor = [UIColor whiteColor];
        artistLabel.backgroundColor = [UIColor clearColor];
        
        UIImage* addButtonImg = [UIImage imageNamed:@"plus.png"];
        addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.tintColor = [UIColor blackColor];
        [addButton setImage:addButtonImg forState:UIControlStateNormal];
        addButton.titleLabel.textColor = [UIColor blackColor];
        addButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
        //[addButton addTarget:self action:@selector(onButtonClick:)   
           //forControlEvents:UIControlEventTouchUpInside];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:songLabel];
        [self.contentView addSubview:artistLabel];
        [self.contentView addSubview:addButton];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
