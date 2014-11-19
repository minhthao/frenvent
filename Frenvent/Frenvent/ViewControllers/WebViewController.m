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
#import "Constants.h"
#import "FriendCoreData.h"

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
        [_quoteArray addObject:@"Hey, I found your profile on TappedIn, and became deeply mesmerized. So I was wonder if I could add you as a friend and have a delightful conversation with you."];
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
        self.url = [NSString stringWithFormat:@"https://m.facebook.com/profile.php?id=%@", self.uid];
    } else ([DbFBUserRequest addFbUserWithUid:self.uid andName:self.name]);
    
    [self.shareButton setEnabled:[FBDialogs canPresentMessageDialog]];
    self.title = self.name ? self.name : @"Recommended Friend";
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    if ([self.navigationController respondsToSelector:@selector(barHideOnSwipeGestureRecognizer)]) {
        self.navigationController.hidesBarsOnSwipe = YES;
        [self.navigationController.barHideOnSwipeGestureRecognizer addTarget:self action:@selector(swipe:)];
    }
    
    CGRect navFrame =  self.navigationController.navigationBar.frame;
    self.navigationController.navigationBar.frame = CGRectMake(0, 20, navFrame.size.width, navFrame.size.height);
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(barHideOnSwipeGestureRecognizer)]) {
        [self.navigationController.barHideOnSwipeGestureRecognizer removeTarget:self action:@selector(swipe:)];
    }
}

- (void)swipe:(UISwipeGestureRecognizer *)recognizer {
    [UIApplication sharedApplication].statusBarHidden = (self.navigationController.navigationBar.frame.origin.y < 0);
}

#pragma mark - web view delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    if (![FriendCoreData getFriendWithUid:self.uid])
//        [self pickQuoteAndInsertIntoMessageTextArea];
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
