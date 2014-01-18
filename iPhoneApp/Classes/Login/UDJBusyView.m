//
//  UDJBusyView.m
//  UDJ
//
//  Created by Matthew Graf on 1/17/14.
//
//

#import "UDJBusyView.h"

@implementation UDJBusyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *loginLabel = [[UILabel alloc] init];
        [loginLabel setTextColor:[UIColor whiteColor]];
        [loginLabel setTextAlignment:NSTextAlignmentCenter];
        [loginLabel setText:@"Logging in"];
        [loginLabel setFrame:CGRectMake(0, 0, 150, 30)];
        [loginLabel setCenter:CGPointMake(frame.size.width / 2, frame.size.height / 2)];
        [self addSubview:loginLabel];
        
        // init cancel button
        UIButton* cancelButton = [[UIButton alloc] init];
        [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(0, 0, 150, 30)];
        [cancelButton setCenter:CGPointMake(frame.size.width / 2, frame.size.height / 2)];
        [self addSubview:cancelButton];
        
    }
    return self;
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
