//
//  SSCalendarView.m
//  SSCalendarView
//
//  Created by Siusi on 07/11/2017.
//  Copyright © 2017 Siusi. All rights reserved.
//

#import "SSCalendarView.h"

#import "SSCalendarView.h"
#import "SSCalendarMonthView.h"
#import "SSCalendarDayView.h"

#import "SSCalendarLayout.h"

static NSString * const kCellIdentifier = @"kCellIdentifier";
static NSString * const kHeaderIdentifier = @"kHeaderIdentifier";

enum {
    kDayViewTag = 100,
    kMonthViewTag
};

enum {
    kDaysInWeek = 7,
    kMonthInterval = 6
};


@interface SSCalendarView () <UICollectionViewDataSource, SSCalendarLayoutDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, strong) NSDate *today;
@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;

@end

@implementation SSCalendarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (void)awakeFromNib {
    [self commonInit];
}

- (void)commonInit {
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                         collectionViewLayout:[SSCalendarLayout new]];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.backgroundColor = [UIColor clearColor];
    
    SSCalendarLayout *flowLayout = (SSCalendarLayout *)_collectionView.collectionViewLayout;
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:kHeaderIdentifier];
    
    _calendar = [NSCalendar currentCalendar];
   
    
    NSDate *now = [self.calendar dateFromComponents:[self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]]];
   
    if (_minDate) {
        _fromDate = [self dateWithFirstDayOfMonth:_minDate];
    } else {
        NSDateComponents *components = [NSDateComponents new];
        components.month = -kMonthInterval;
        _fromDate = [self.calendar dateByAddingComponents:components toDate:now options:0];
    }
    
    if (_maxDate) {
        _toDate = [self dateWithFirstDayOfNextMonth:_maxDate];
    } else {
        NSDateComponents *components = [NSDateComponents new];
        components.month = kMonthInterval;
        _toDate = [self.calendar dateByAddingComponents:components toDate:now options:0];
    }
    
    NSDateComponents *todayYearMonthDayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    _today = [self.calendar dateFromComponents:todayYearMonthDayComponents];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:_collectionView];
    
    [self scrollToToday:NO];
    
}

#pragma mark UICollectionViewDataSource & SSCalendarLayoutDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    SSCalendarDayView *dayView = [cell.contentView viewWithTag:kDayViewTag];
    
    if (!dayView) {
        dayView = [[SSCalendarDayView alloc] initWithFrame:cell.contentView.bounds];
        dayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dayView.tag = kDayViewTag;
        [cell.contentView addSubview:dayView];
    }
   
    dayView.textLabel.text = [@([self dateComponentsForCellAtIndexPath:indexPath].day) description];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderIdentifier forIndexPath:indexPath];
    view.backgroundColor = [UIColor clearColor];
    
    SSCalendarMonthView *monthView = [view viewWithTag:kMonthViewTag];
    
    if (!monthView) {
        monthView = [[SSCalendarMonthView alloc] initWithFrame:view.bounds];
        monthView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        monthView.tag = kMonthViewTag;
        [view addSubview:monthView];
    }
   
    monthView.textLabel.text = [NSString stringWithFormat:@"%li月", [self dateComponentsForCellAtIndexPath:indexPath].month];
    
    return view;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.calendar components:NSCalendarUnitMonth fromDate:self.fromDate toDate:self.toDate options:0].month;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    return [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[self dateForCellAtIndexPath:indexPath]].length;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(SSCalendarLayout *)layout indentLevelForSectionAtIndex:(NSInteger)section {
    NSDate *firstDayInMonth = [self dateForFirstDayInSection:section];
    NSUInteger firstDayInMonthWeekday = [self reorderedWeekday:[self.calendar components:NSCalendarUnitWeekday fromDate:firstDayInMonth].weekday];
    
    return firstDayInMonthWeekday;
}

- (NSDateComponents *)dateComponentsForCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                            fromDate:[self dateForCellAtIndexPath:indexPath]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSDate *)dateForFirstDayInSection:(NSInteger)section {
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = section;
    
    return [self.calendar dateByAddingComponents:dateComponents toDate:self.fromDate options:0];
}

- (void)shiftDatesWithDateComponents:(NSDateComponents *)components {
    UICollectionView *collectionView = self.collectionView;
    SSCalendarLayout *layout = (SSCalendarLayout *)self.collectionView.collectionViewLayout;
    
    NSArray *visibleCells = [collectionView visibleCells];
    if (![visibleCells count])
        return;
    
    NSIndexPath *fromIndexPath = [collectionView indexPathForCell:((UICollectionViewCell *)visibleCells[0]) ];
    NSInteger fromSection = fromIndexPath.section;
    NSDate *fromSectionOfDate = [self dateForFirstDayInSection:fromSection];
    UICollectionViewLayoutAttributes *fromAttrs = [layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:fromSection]];
    CGPoint fromSectionOrigin = [self convertPoint:fromAttrs.frame.origin fromView:collectionView];
    
    if (!self.minDate) {
        _fromDate = [self dateWithFirstDayOfMonth:[self.calendar dateByAddingComponents:components toDate:self.fromDate options:0]];
    }
    
    if (!self.maxDate) {
        _toDate = [self dateWithFirstDayOfMonth:[self.calendar dateByAddingComponents:components toDate:self.toDate options:0]];
    }
    
    [layout invalidateLayout];
    [layout prepareLayout];
    
    [self restoreSelection];
    
    NSInteger toSection = [self sectionForDate:fromSectionOfDate];
    UICollectionViewLayoutAttributes *toAttrs = [layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:toSection]];
    CGPoint toSectionOrigin = [self convertPoint:toAttrs.frame.origin fromView:collectionView];
    
    [collectionView setContentOffset:(CGPoint) {
        collectionView.contentOffset.x,
        collectionView.contentOffset.y + (toSectionOrigin.y - fromSectionOrigin.y)
    }];
}

- (NSDate *)dateWithFirstDayOfNextMonth:(NSDate *)date {
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    components.month = components.month + 1;
    components.day = 1;
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *firstDayInMonth = [self dateForFirstDayInSection:indexPath.section];
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = indexPath.item;
    
    NSDate *cellDate = [self.calendar dateByAddingComponents:dateComponents toDate:firstDayInMonth options:0];
    
    return cellDate;
}

- (NSDate *)dateWithFirstDayOfMonth:(NSDate *)date {
    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    dateComponents.day = 1;
    return [self.calendar dateFromComponents:dateComponents];
}

- (NSUInteger)reorderedWeekday:(NSUInteger)weekday {
    NSInteger ordered = weekday - self.calendar.firstWeekday;
    if (ordered < 0) {
        ordered = kDaysInWeek + ordered;
    }
    
    return ordered;
}

- (void)appendFutureDates {
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = kMonthInterval;
    [self shiftDatesWithDateComponents:dateComponents];
}

- (void)appendPastDates {
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = -kMonthInterval;
    [self shiftDatesWithDateComponents:dateComponents];
}

- (void)restoreSelection {
    for (NSDate *selectedDate in self.selectedDates) {
        if (selectedDate &&
            [selectedDate compare:self.fromDate] != NSOrderedAscending &&
            [selectedDate compare:self.toDate] == NSOrderedAscending) {
            NSIndexPath *indexPathForSelectedDate = [self indexPathForDate:selectedDate];
            [self.collectionView selectItemAtIndexPath:indexPathForSelectedDate animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPathForSelectedDate];
            if (selectedCell) {
                [selectedCell setNeedsDisplay];
            }
        }
        
    }

}

- (NSIndexPath *)indexPathForDate:(NSDate *)date {
    NSInteger monthSection = [self sectionForDate:date];
    NSDate *firstDayInMonth = [self dateForFirstDayInSection:monthSection];
    NSUInteger weekday = [self reorderedWeekday:[self.calendar components:NSCalendarUnitWeekday fromDate:firstDayInMonth].weekday];
    NSInteger dateItem = [self.calendar components:NSCalendarUnitDay fromDate:firstDayInMonth toDate:date options:0].day + weekday;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:dateItem inSection:monthSection];
    
    return indexPath;
}

- (NSInteger)sectionForDate:(NSDate *)date; {
    return [self.calendar components:NSCalendarUnitMonth fromDate:[self dateForFirstDayInSection:0] toDate:date options:0].month;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isPagingEnabled) {
            if (!self.minDate && scrollView.contentOffset.y < CGRectGetHeight(scrollView.bounds) * 2) {
                [self appendPastDates];
            }
            
            if (!self.maxDate && scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) * 2 > scrollView.contentSize.height) {
                [self appendFutureDates];
            }
        }
    });
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.isPagingEnabled) {
        NSArray *sortedIndexPathsForVisibleItems = [[self.collectionView indexPathsForVisibleItems] sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath * obj2) {
            return obj1.section > obj2.section;
        }];
        
        NSUInteger visibleSection;
        NSUInteger nextSection;
        if (velocity.y > 0.0) {
            visibleSection = [[sortedIndexPathsForVisibleItems firstObject] section];
            
            if (self.maxDate && visibleSection >= [self sectionForDate:self.maxDate]) {
                nextSection = visibleSection;
            } else {
                nextSection = visibleSection + 1;
            }
        } else if (velocity.y < 0.0) {
            visibleSection = [[sortedIndexPathsForVisibleItems lastObject] section];
            
            if (self.minDate && visibleSection <= [self sectionForDate:self.minDate]) {
                nextSection = visibleSection;
            } else {
                nextSection = visibleSection - 1;
            }
        } else {
            visibleSection = [sortedIndexPathsForVisibleItems[sortedIndexPathsForVisibleItems.count / 2] section];
            nextSection = visibleSection;
        }
        
        CGRect headerRect = [self frameForHeaderInSectionAtIndex:nextSection];
        CGPoint topOfHeader = CGPointMake(0, headerRect.origin.y - self.collectionView.contentInset.top);
        CGFloat maxYContentOffset = self.collectionView.contentSize.height - CGRectGetHeight(self.collectionView.bounds);
        if (topOfHeader.y > maxYContentOffset) {
            topOfHeader.y = maxYContentOffset;
        }
        
        *targetContentOffset = topOfHeader;
        
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
}

- (CGRect)frameForHeaderInSectionAtIndex:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    return [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                                                  atIndexPath:indexPath].frame;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.minDate && scrollView.contentOffset.y < 0) {
        [self appendPastDates];
    }
    
    if (!self.maxDate && scrollView.contentOffset.y > (scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds))) {
        [self appendFutureDates];
    }
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated {
    if (self.minDate && [date compare:self.minDate] == NSOrderedAscending) {
        return;
    }
    
    if (self.maxDate && [date compare:self.maxDate] == NSOrderedDescending) {
        return;
    }
    
    UICollectionView *collectionView = self.collectionView;
    SSCalendarLayout *layout = (SSCalendarLayout *)self.collectionView.collectionViewLayout;
    
    NSDate *month = [self.calendar dateFromComponents:[self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:date]];
    
    if (!self.minDate) {
        
        NSDateComponents *components = [NSDateComponents new];
        components.month = -kMonthInterval;
        
        _fromDate = [self dateWithFirstDayOfMonth:[self.calendar dateByAddingComponents:components toDate:month options:0]];
    }
    
    if (!self.maxDate) {
        NSDateComponents *components = [NSDateComponents new];
        components.month = kMonthInterval;
        _toDate = [self dateWithFirstDayOfMonth:[self.calendar dateByAddingComponents:components toDate:month options:0]];
    }
    
    [collectionView reloadData];
    [layout invalidateLayout];
    [layout prepareLayout];
    
    [self restoreSelection];
    
    NSIndexPath *dateItemIndexPath = [self indexPathForDate:date];
    NSInteger monthSection = [self sectionForDate:date];
    
    CGRect dateItemRect = [self frameForItemAtIndexPath:dateItemIndexPath];
    CGRect monthSectionHeaderRect = [self frameForHeaderInSectionAtIndex:monthSection];
    
    CGFloat delta = CGRectGetMaxY(dateItemRect) - CGRectGetMinY(monthSectionHeaderRect);
    CGFloat actualViewHeight = CGRectGetHeight(collectionView.frame) - collectionView.contentInset.top - collectionView.contentInset.bottom;
    
    if (delta <= actualViewHeight) {
        [self scrollToTopOfSection:monthSection animated:animated];
    } else {
        [collectionView scrollToItemAtIndexPath:dateItemIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
    }
}

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
}

- (void)scrollToTopOfSection:(NSInteger)section animated:(BOOL)animated {
    CGRect headerRect = [self frameForHeaderInSectionAtIndex:section];
    CGPoint topOfHeader = CGPointMake(0, headerRect.origin.y - _collectionView.contentInset.top);
    [_collectionView setContentOffset:topOfHeader animated:animated];
}

- (void)scrollToToday:(BOOL)animated {
    [self scrollToDate:self.today animated:animated];
}

@end
