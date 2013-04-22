//
//  ARBCascadeDemoAppDelegate.m
//  ARBCollectionViewCascadeLayoutDemo
//
//  Created by Adam Becevello on 2013-04-21.
//  Copyright (c) 2013 Adam Becevello. All rights reserved.
//

#import "ARBCascadeDemoAppDelegate.h"

#import "ARBCascadeDemoViewController.h"

@implementation ARBCascadeDemoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.viewController = [[ARBCascadeDemoViewController alloc] init];
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
