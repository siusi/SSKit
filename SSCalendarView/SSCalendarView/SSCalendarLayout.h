//
//  SSCalendarLayout.h
//  SSCalendarView
//
//  Created by Siusi on 07/11/2017.
//  Copyright © 2017 Siusi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSCalendarLayout;
@protocol SSCalendarLayoutDelegate <UICollectionViewDelegate>
@optional
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(SSCalendarLayout *)layout indentLevelForSectionAtIndex:(NSInteger)section;
@end

@interface SSCalendarLayout : UICollectionViewLayout


@property (nonatomic, strong) NSDictionary <NSIndexPath *, UICollectionViewLayoutAttributes *> *itemAttrsDict;
@property (nonatomic, strong) NSDictionary <NSIndexPath *, UICollectionViewLayoutAttributes *> *headerAttrsDict;
@property (nonatomic, assign) UIEdgeInsets sectionInset;

@end
