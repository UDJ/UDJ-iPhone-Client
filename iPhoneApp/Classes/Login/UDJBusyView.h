//
//  UDJBusyView.h
//  UDJ
//
//  Created by Matthew Graf on 1/17/14.
//
//

#import <UIKit/UIKit.h>
#import "UDJBusyViewDelegate.h"

@interface UDJBusyView : UIView

@property (nonatomic, weak) id<UDJBusyViewDelegate> delegate;

@property (nonatomic, strong) UILabel *titleLabel;

-(void)setTitle:(NSString*)title;
-(void)hideAndRemoveFromSuperView;

@end
