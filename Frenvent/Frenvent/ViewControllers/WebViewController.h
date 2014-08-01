//
//  WebViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/24/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>


@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@end
