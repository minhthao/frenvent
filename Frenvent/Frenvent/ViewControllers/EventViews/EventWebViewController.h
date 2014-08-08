//
//  EventWebViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 8/5/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareEventRequest.h"

@interface EventWebViewController : UIViewController <UIActionSheetDelegate, ShareEventRequestDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
- (IBAction)shareButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *eid;

@end
