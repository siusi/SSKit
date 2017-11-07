//
//  SSCalendarMonthView.m
//  SSCalendarView
//
//  Created by Siusi on 07/11/2017.
//  Copyright © 2017 Siusi. All rights reserved.
//

#import "SSCalendarMonthView.h"

@implementation SSCalendarMonthView

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
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.font = [UIFont systemFontOfSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:label];
    _textLabel = label;
}

@end
