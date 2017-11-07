//
//  SSCalendarView.h
//  SSCalendarView
//
//  Created by Siusi on 07/11/2017.
//  Copyright © 2017 Siusi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSCalendarView;
@protocol SSCalendarViewDelegate <NSObject>
@optional
- (BOOL)calendarView:(SSCalendarView *)view shouldSelectDate:(NSDate *)date;

- (void)calendarView:(SSCalendarView *)calendarView didSelectDate:(NSDate *)date;
- (void)calendarView:(SSCalendarView *)calendarView didDeselectDate:(NSDate *)date;
@end

@interface SSCalendarView : UIView
@property (nonatomic, weak) id<SSCalendarViewDelegate> delegate;

@property (nonatomic, strong) NSDate *minDate;
@property (nonatomic, strong) NSDate *maxDate;

@property (nonatomic, strong, readonly) NSArray <NSDate *> *selectedDates;

@property (nonatomic, assign, getter=isPagingEnabled) BOOL pagingEnabled;

@property (nonatomic) BOOL allowsMultipleSelection; // default is NO
@end
