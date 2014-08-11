//
//  FbUserPhotoViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/28/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FbUserPhotoViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (nonatomic) int index;
@property (nonatomic, strong) NSArray *photoUrls;
@end
