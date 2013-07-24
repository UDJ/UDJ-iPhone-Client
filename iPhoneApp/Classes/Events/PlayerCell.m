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

#define PCELL_HORIZONTAL_PADDING        5
#define PCELL_VERTICAL_PADDING          2

#import "PlayerCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PlayerCell

@synthesize cellImageView, playerNameLabel;
@synthesize containerView;

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat boundsY = contentRect.origin.y;
    CGRect frame;
    
    frame = CGRectMake(boundsX+15, boundsY+PCELL_VERTICAL_PADDING, 250, containerView.frame.size.height);
    playerNameLabel.frame = frame;
    
    
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIColor* containerColor = [UIColor colorWithRed:72.0/255.0 green:147.0/255.0 blue:203.0/255.0 alpha:0.85];
        UIColor* borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.9];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        containerView = [[UIView alloc] initWithFrame:CGRectMake(PCELL_HORIZONTAL_PADDING, PCELL_VERTICAL_PADDING, 320-2*PCELL_HORIZONTAL_PADDING, self.frame.size.height-2*PCELL_VERTICAL_PADDING)];
        [containerView setBackgroundColor: containerColor];
        [containerView.layer setCornerRadius: 5];
        [containerView.layer setBorderColor: [borderColor CGColor]];
        [containerView.layer setBorderWidth: 1];
        [self.contentView addSubview:containerView];
        
        // add shadow
        [containerView.layer setShadowColor: [[UIColor blackColor] CGColor]];
        [containerView.layer setShadowOffset: CGSizeMake(0, 5)];
        [containerView.layer setShadowOpacity:0.8];
        [containerView.layer setShadowRadius:5];
        
        playerNameLabel = [[UILabel alloc] init];
        playerNameLabel.font = [UIFont fontWithName:@"Helvetica" size:22];
        playerNameLabel.textColor = [UIColor whiteColor];
        playerNameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview: playerNameLabel];
    }
    return self;
}

@end
