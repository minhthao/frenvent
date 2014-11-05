//
//  WebViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 7/24/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "WebViewController.h"
#import "RecommendFbUserRequest.h"
#import "DbFBUserRequest.h"
#import "ToastView.h"

@interface WebViewController ()
@property (nonatomic, strong) RecommendFbUserRequest *recommendFbUserRequest;
@property (nonatomic, strong) NSMutableArray *quoteArray;
@end

@implementation WebViewController
#pragma mark - initiation
/**
 * Lazily instantiate the recommendFbUserRequest
 * @return RecommendFbUserRequest
 */
-(RecommendFbUserRequest *)recommendFbUserRequest {
    if (_recommendFbUserRequest == nil) {
        _recommendFbUserRequest = [[RecommendFbUserRequest alloc] init];
        _recommendFbUserRequest.delegate = self;
    }
    return _recommendFbUserRequest;
}

/**
 * Lazily instantiate the quote array
 * @param quote array
 */
-(NSMutableArray *)quoteArray {
    if (_quoteArray == nil) {
        _quoteArray = [[NSMutableArray alloc] init];
        [_quoteArray addObject:@"Hey, I found you on \n friendfiend"];
    }
    return _quoteArray;
}

/**
 * Although not the intantiation, but basically, we will pick one pickup quote from the quote array
 */
-(void)pickQuoteAndInsertIntoMessageTextArea {
    NSString *quote = [[self quoteArray] objectAtIndex:(rand() % [[self quoteArray] count])];
    NSString *javaScriptString = [NSString stringWithFormat:@"document.getElementsByClassName('_5whq input m_messaging_body')[0].value = '%@'", quote];
    [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
}


#pragma mark - view delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.shareButton setEnabled:false];
    if (self.isModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    }

    if (self.url != nil) [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    if (self.uid != nil && self.name != nil) {
        self.title = self.name;
        if ([DbFBUserRequest addFbUserWithUid:self.uid andName:self.name])
            [self.shareButton setEnabled:[FBDialogs canPresentMessageDialog]];
    } else if (self.uid != nil) {
        self.title = @"Recommended Friend";
        //this case, you are getting the view from the modal, so we did not need to add it to the db anymore
        NSString *urlString = [NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", self.uid];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
        [self.shareButton setEnabled:[FBDialogs canPresentMessageDialog]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - web view delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self pickQuoteAndInsertIntoMessageTextArea];
    
//    NSString *currentUrl = webView.request.URL.absoluteString;
//    if ([currentUrl rangeOfString:@"m.facebook.com/home.php?"].location != NSNotFound) {
//        [[self secondLoginWebView] removeFromSuperview];
//        _secondLoginWebView = nil;
//        _loginErrorLabel = nil;
//        [self navigateToMainPage];
//    } else if (![currentUrl isEqualToString:@"https://m.facebook.com/"]) {
//        [self loginErrorLabel].hidden = false;
//        [[self secondLoginWebView] goBack];
//    }

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)backClick {
    [self dismissViewControllerAnimated:true completion:NULL];
}

#pragma mark - recommend user delegate
- (void)notifyRecommendFbUserRequestSuccess:(BOOL)success {
    if (success) [ToastView showToastInParentView:self.view withText:@"User shared successfully" withDuaration:2.0];
    else [ToastView showToastInParentView:self.view withText:@"Fail to share user" withDuaration:2.0];
}

- (IBAction)shareButtonClick:(id)sender {
    [[self recommendFbUserRequest] shareUserWithUid:self.uid];
}
@end
