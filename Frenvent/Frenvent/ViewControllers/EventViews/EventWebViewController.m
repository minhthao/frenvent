//
//  EventWebViewController.m
//  Frenvent
//
//  Created by minh thao nguyen on 8/5/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "EventWebViewController.h"
#import "ShareEventRequest.h"
#import "ToastView.h"
#import "Event.h"
#import "EventCoreData.h"

@interface EventWebViewController ()

@property (nonatomic, strong) UIActionSheet *shareActionSheet;
@property (nonatomic, strong) ShareEventRequest *shareEventRequest;

@end

@implementation EventWebViewController
#pragma mark - initiation
/**
 * Lazily instantiate the share action sheet
 * @return share action sheet
 */
-(UIActionSheet *)shareActionSheet {
    if (_shareActionSheet == nil) {
        _shareActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share via messenger", @"Share on wall", nil];
        _shareActionSheet.tag = 2;
    }
    return _shareActionSheet;
}

/**
 * Lazily instantiate the share event request
 * @return Share event request
 */
-(ShareEventRequest *)shareEventRequest {
    if (_shareEventRequest == nil) {
        _shareEventRequest = [[ShareEventRequest alloc] init];
        _shareEventRequest.delegate = self;
    }
    return _shareEventRequest;
}

#pragma mark - uiactionsheet delegate and share delegates
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [[self shareEventRequest] shareToFriendTheEventWithEid:self.eid];
            break;
            
        case 1:
            [[self shareEventRequest] shareToWallTheEvent:self.eid];
            break;
            
        default:
            break;
    }
}

-(void)notifyShareEventRequestSuccess:(BOOL)success {
    if (success) [ToastView showToastInParentView:self.view withText:@"Event shared successfully" withDuaration:3.0];
    else [ToastView showToastInParentView:self.view withText:@"Fail to share event" withDuaration:3.0];
}

#pragma mark - web view delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    Event *event = [EventCoreData getEventWithEid:self.eid];
    self.shareButton.enabled = [event canShare];
    self.title = event.name;
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
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, navFrame.size.width, 64);
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(barHideOnSwipeGestureRecognizer)]) {
        [self.navigationController.barHideOnSwipeGestureRecognizer removeTarget:self action:@selector(swipe:)];
    }
}

- (void)swipe:(UISwipeGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.2 animations:^{
        [UIApplication sharedApplication].statusBarHidden = (self.navigationController.navigationBar.frame.origin.y < 0);
        
        if (![UIApplication sharedApplication].statusBarHidden) {
            CGRect navFrame =  self.navigationController.navigationBar.frame;
            self.navigationController.navigationBar.frame = CGRectMake(0, 0, navFrame.size.width, 64);
        }
    }];
}

- (IBAction)shareButtonClick:(id)sender {
    if ([FBDialogs canPresentMessageDialog])
        [[self shareActionSheet] showInView:[UIApplication sharedApplication].keyWindow];
    else [[self shareEventRequest] shareToWallTheEvent:self.eid];

}
@end
