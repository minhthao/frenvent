//
//  FbUserPhotoViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/28/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "FbUserPhotoViewController.h"
#import "MyColor.h"
#import "PagedPhotoScrollView.h"

@implementation FbUserPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.photoUrls count] > 0) {
        PagedPhotoScrollView *pageScrollView = [[PagedPhotoScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.mainView.frame.size.height)];
        
        pageScrollView.backgroundColor = [MyColor eventCellButtonsContainerBorderColor];
        [pageScrollView setScrollViewPhotoUrls:self.photoUrls withContentModeFit:true];
        [pageScrollView changeToPage:self.index];
        
        [self.mainView addSubview:pageScrollView];
    } else [self.navigationController popViewControllerAnimated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
