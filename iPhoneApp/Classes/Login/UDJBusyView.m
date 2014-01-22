//
//  UDJBusyView.m
//  UDJ
//
//  Created by Matthew Graf on 1/17/14.
//
//

#import "UDJBusyView.h"

@implementation UDJBusyView
@synthesize titleLabel;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        const NSInteger VERTICAL_SPACING = 75;
        
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.8]];
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setFrame:CGRectMake(0, 0, 250, 40)];
        [titleLabel setCenter:CGPointMake(frame.size.width / 2, frame.size.height / 2 - VERTICAL_SPACING)];
        [self addSubview:titleLabel];
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] init];
        [activityView setFrame:CGRectMake(0, 0, 50, 50)];
        [activityView setCenter:CGPointMake(frame.size.width / 2, frame.size.height / 2)];
        [activityView startAnimating];
        [self addSubview:activityView];
        
        // init cancel button
        UIButton* cancelButton = [[UIButton alloc] init];
        [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(0, 0, 150, 50)];
        [cancelButton setCenter:CGPointMake(frame.size.width / 2, frame.size.height - VERTICAL_SPACING)];
        [self addSubview:cancelButton];
        
    }
    return self;
}

-(void)cancelButtonClick:(id)sender{
    [delegate actionCanceled];
}

-(void)setTitle:(NSString *)title{
    [titleLabel setText:title];
}

-(void)hideAndRemoveFromSuperView{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
