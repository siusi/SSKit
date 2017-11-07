//
//  SSCalendarDayView.m
//  SSCalendarView
//
//  Created by Siusi on 07/11/2017.
//  Copyright © 2017 Siusi. All rights reserved.
//

#import "SSCalendarDayView.h"

@implementation SSCalendarDayView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 1)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self addSubview:lineView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18];
    
    [self addSubview:label];
    _textLabel = label;
    

}

@end
