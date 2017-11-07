//
//  SSCalendarLayout.m
//  SSCalendarView
//
//  Created by Siusi on 07/11/2017.
//  Copyright © 2017 Siusi. All rights reserved.
//

#import "SSCalendarLayout.h"

static NSInteger const kMaximumNumberOfItemsPerRow = 7;

@implementation SSCalendarLayout


- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
   
    NSMutableArray *result = [NSMutableArray new];
    
    NSMutableIndexSet *appearedSections = [NSMutableIndexSet new];
   
    for (UICollectionViewLayoutAttributes *attrs in self.itemAttrsDict.allValues) {
        if (CGRectIntersectsRect(attrs.frame, rect)) {
            [appearedSections addIndex:attrs.indexPath.section];
            [result addObject:attrs];
        }
    }
    
    [appearedSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [result addObject:self.headerAttrsDict[[NSIndexPath indexPathForItem:0 inSection:idx]]];
    }];
    
    return [result copy];
}

- (void)prepareLayout {
    NSMutableDictionary *itemAttrsDict = [NSMutableDictionary new];
    NSMutableDictionary *headerAttrsDict = [NSMutableDictionary new];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    
    CGRect bounds = self.collectionView.bounds;
    UIEdgeInsets sectionInset = self.sectionInset;
    CGFloat width = (bounds.size.width  - sectionInset.left - sectionInset.right)/kMaximumNumberOfItemsPerRow;
    
    CGRect itemFrame = CGRectIntegral((CGRect){CGPointZero, CGSizeMake(width, width)});
    
    CGFloat lastMaxY = 0;
    
    for (NSInteger section = 0; section < numberOfSections; section++) {
       
        NSInteger numberItemsInSection = [self.collectionView numberOfItemsInSection:section];
        
        CGRect headerFrame = CGRectMake(0, lastMaxY + sectionInset.top , 0, itemFrame.size.height);
        
        CGRect newItemFrame = itemFrame;
        newItemFrame.origin.y = CGRectGetMaxY(headerFrame);
        newItemFrame.origin.x += self.sectionInset.left;
        
        for (NSInteger item = 0; item < numberItemsInSection; item++) {
            
            NSInteger indentLevel = 0;
            
            id<SSCalendarLayoutDelegate> delegate = (id<SSCalendarLayoutDelegate>)self.collectionView.delegate;
            if ([delegate respondsToSelector:@selector(collectionView:layout:indentLevelForSectionAtIndex:)]) {
                indentLevel = [delegate collectionView:self.collectionView layout:self indentLevelForSectionAtIndex:section];
            }
            
            indentLevel = indentLevel % kMaximumNumberOfItemsPerRow;
            
            NSInteger realIndex = item + indentLevel;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            NSInteger column = realIndex % kMaximumNumberOfItemsPerRow;
            NSInteger row = realIndex / kMaximumNumberOfItemsPerRow;
     
            attrs.frame = CGRectOffset(newItemFrame, column * newItemFrame.size.width,
                                       row * newItemFrame.size.height);
            
            if (item == numberItemsInSection - 1) {
                lastMaxY = CGRectGetMaxY(attrs.frame);
            }
            
            if (item == 0) {
                headerFrame.origin.x = CGRectGetMinX(attrs.frame);
                headerFrame.size = attrs.frame.size;
            }
            
            itemAttrsDict[attrs.indexPath] = attrs;
        }
       
        UICollectionViewLayoutAttributes *headerAttrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        headerAttrs.frame = headerFrame;
        headerAttrsDict[headerAttrs.indexPath] = headerAttrs;
        
    }
    
    self.itemAttrsDict = itemAttrsDict;
    self.headerAttrsDict = headerAttrsDict;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemAttrsDict[indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    return self.headerAttrsDict[indexPath];
}

- (CGSize)collectionViewContentSize {
    
    NSInteger section = MAX(0, [self.collectionView numberOfSections] - 1);
    NSInteger item = MAX(0, [self.collectionView numberOfItemsInSection:section] - 1);
    
    NSIndexPath *lastItemIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    return CGSizeMake(self.collectionView.bounds.size.width, CGRectGetMaxY([self.itemAttrsDict[lastItemIndexPath] frame]));
}

@end
