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
    //[self updateButtons];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //[self updateButtons];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //[self updateButtons];
}

#pragma mark - view delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.shareButton setEnabled:false];
    if (self.url != nil) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
        Event *event = [EventCoreData getEventWithEid:self.eid];
        if ([event canShare] && self.eid != nil) [self.shareButton setEnabled:true];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareButtonClick:(id)sender {
    if ([FBDialogs canPresentMessageDialog])
        [[self shareActionSheet] showInView:[UIApplication sharedApplication].keyWindow];
    else [[self shareEventRequest] shareToWallTheEvent:self.eid];

}
@end
