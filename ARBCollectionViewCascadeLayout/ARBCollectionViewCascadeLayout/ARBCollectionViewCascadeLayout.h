//
//  ARBCollectionViewCascadeLayout.h
//  ARBCollectionViewCascadeLayout
//
//  Created by Adam Becevello on 2013-04-21.
//  Copyright (c) 2013 Adam Becevello. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const ARBCollectionViewCascadeLayoutSupplementaryViewKindHeaderFooter;

extern NSUInteger const ARBCollectionViewCascadeLayoutHeaderItemNumber;
extern NSUInteger const ARBCollectionViewCascadeLayoutFooterItemNumber;

@protocol ARBCollectionViewCascadeLayoutDelegate;

@interface ARBCollectionViewCascadeLayout : UICollectionViewLayout

@property (nonatomic, weak) id<ARBCollectionViewCascadeLayoutDelegate> delegate;
@property (nonatomic, assign) CGFloat itemPadding;
@property (nonatomic, assign) NSInteger numColumnsLandscape;
@property (nonatomic, assign) NSInteger numColumnsPortrait;

@end

@protocol ARBCollectionViewCascadeLayoutDelegate <NSObject>

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ARBCollectionViewCascadeLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ARBCollectionViewCascadeLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ARBCollectionViewCascadeLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section;

@end
