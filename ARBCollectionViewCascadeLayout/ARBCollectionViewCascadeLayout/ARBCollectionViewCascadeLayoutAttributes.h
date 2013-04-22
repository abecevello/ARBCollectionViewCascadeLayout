//
//  ARBCollectionViewCascadeLayoutAttributes.h
//  ARBCollectionViewCascadeLayout
//
//  Created by Adam Becevello on 2013-04-21.
//  Copyright (c) 2013 Adam Becevello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARBCollectionViewCascadeLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) BOOL valid;
@property (nonatomic, assign) CGRect previousFrame;
@property (nonatomic, assign) NSInteger currentColumn;

@end
