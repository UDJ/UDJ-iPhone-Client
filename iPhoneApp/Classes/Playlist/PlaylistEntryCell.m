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

#import "PlaylistEntryCell.h"
#import "PlaylistViewController.h"

@implementation PlaylistEntryCell

@synthesize songLabel, addedByLabel, artistLabel, upVoteButton, downVoteButton, upVoteLabel, downVoteLabel, playingImageView, playingLabel;

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;

    frame= CGRectMake(boundsX+10 ,3, 210, 20);
    songLabel.frame = frame;
    
    frame= CGRectMake(boundsX+14 ,24, 250, 17);
    artistLabel.frame = frame;
    
    frame= CGRectMake(boundsX+14 ,42, 250, 16);
    addedByLabel.frame = frame;
    
    frame = CGRectMake(boundsX+225, 4, 38, 38);
    upVoteButton.frame = frame;
    
    frame = CGRectMake(boundsX+275, 4, 38, 38);
    downVoteButton.frame = frame;
    
    frame = CGRectMake(boundsX+239, 42, 30, 20);
    upVoteLabel.frame = frame;
    
    frame = CGRectMake(boundsX+289, 42, 30, 20);
    downVoteLabel.frame = frame;
    
    frame = CGRectMake(boundsX + 271, 3, 42, 42);
    playingImageView.frame = frame;
    
    frame = CGRectMake(boundsX + 274, 46, 42, 12);
    playingLabel.frame = frame;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        songLabel = [[UILabel alloc] init];
        songLabel.textAlignment = UITextAlignmentLeft;
        songLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        songLabel.textColor=[UIColor whiteColor];
        songLabel.backgroundColor = [UIColor colorWithRed:50 green:112 blue:176 alpha:0];
        songLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        
        artistLabel = [[UILabel alloc]init];
        artistLabel.textAlignment = UITextAlignmentLeft;
        artistLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        artistLabel.textColor = [UIColor whiteColor];
        artistLabel.backgroundColor = [UIColor clearColor];
        
        addedByLabel = [[UILabel alloc]init];
        addedByLabel.textAlignment = UITextAlignmentLeft;
        addedByLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        addedByLabel.textColor = [UIColor whiteColor];
        addedByLabel.backgroundColor = [UIColor clearColor];
        
        UIImage* upVoteImage = [UIImage imageNamed:@"voteup.png"];
        upVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [upVoteButton setImage:upVoteImage forState:UIControlStateNormal];
        UIImage* downVoteImage = [UIImage imageNamed:@"votedown.png"];
        downVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [downVoteButton setImage:downVoteImage forState:UIControlStateNormal];
     
        upVoteLabel = [[UILabel alloc] init];
        downVoteLabel = [[UILabel alloc] init];
        upVoteLabel.textColor = [UIColor greenColor];
        upVoteLabel.backgroundColor = [UIColor clearColor];
        upVoteLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
        upVoteLabel.textAlignment = UITextAlignmentLeft;
        downVoteLabel.textColor = [UIColor redColor];
        downVoteLabel.backgroundColor = [UIColor clearColor];
        downVoteLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
        downVoteLabel.textAlignment = UITextAlignmentLeft;
        self.backgroundColor = [UIColor clearColor];
        
        playingImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"playing.png"]];
        playingImageView.hidden = YES;
        
        playingLabel = [[UILabel alloc] init];
        [playingLabel setText: @"playing"];
        playingLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
        playingLabel.backgroundColor = [UIColor clearColor];
        playingLabel.textColor = [UIColor whiteColor];
        playingLabel.hidden = YES;
        
        
        [self.contentView addSubview:songLabel];
        [self.contentView addSubview:artistLabel];
        [self.contentView addSubview:addedByLabel];
        [self.contentView addSubview:upVoteButton];
        [self.contentView addSubview:downVoteButton];
        [self.contentView addSubview:upVoteLabel];
        [self.contentView addSubview:downVoteLabel];
        [self.contentView addSubview:playingImageView];
        [self.contentView addSubview:playingLabel];
    }
    return self;
}

#pragma mark - Selection methods

// These methods have been overridden so that the voting buttons
// do not get highlighted upon cell selection

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];

    self.upVoteButton.highlighted = NO;
    self.downVoteButton.highlighted = NO;
}

- (void)setHighlighted: (BOOL)highlighted animated: (BOOL)animated{
    self.upVoteButton.highlighted = NO;
    self.downVoteButton.highlighted = NO;
}


@end
