//
//  MainViewTabBarViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/7/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "MainViewTabBarViewController.h"

@interface MainViewTabBarViewController ()

@end

@implementation MainViewTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
    [self.tabBarController.tabBar setTranslucent:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
