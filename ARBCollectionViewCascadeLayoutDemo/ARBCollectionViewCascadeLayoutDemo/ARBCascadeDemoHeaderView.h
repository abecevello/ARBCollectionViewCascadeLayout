//
//  ARBCascadeDemoHeaderView.h
//  ARBCollectionViewCascadeLayoutDemo
//
//  Created by Adam Becevello on 2013-04-21.
//  Copyright (c) 2013 Adam Becevello. All rights reserved.
//

#import "ARBCascadeDemoHeaderFooterView.h"

@interface ARBCascadeDemoHeaderView : ARBCascadeDemoHeaderFooterView

@property (nonatomic, assign) NSInteger section;

@property (nonatomic, readonly, strong) UIButton *addButton;
@property (nonatomic, readonly, strong) UIButton *removeButton;

@end
