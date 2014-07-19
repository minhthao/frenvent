//
//  FriendInfoViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/18/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FriendInfoViewController.h"

@interface FriendInfoViewController ()

@end

@implementation FriendInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)viewSegments:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger index = [segmentedControl selectedSegmentIndex];
    
    if (index == 0) {
        [self.firstView setHidden:false];
        [self.secondView setHidden:true];
        [self.thirdView setHidden:true];
    }
    if (index == 1) {
        [self.firstView setHidden:true];
        [self.secondView setHidden:false];
        [self.thirdView setHidden:true];
    }

    if (index == 2) {
        [self.firstView setHidden:true];
        [self.secondView setHidden:true];
        [self.thirdView setHidden:false];
    }

    
}

@end
