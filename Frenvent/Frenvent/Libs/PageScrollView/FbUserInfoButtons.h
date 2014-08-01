//
//  FbUserInfoButtons.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/30/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FbUserInfoButtonsDelegate <NSObject>
@required
-(void)profileButtonTap;
-(void)messageButtonTap;
-(void)photoButtonTap;
-(void)friendButtonTap;
@end

@interface FbUserInfoButtons : UIView

@property (nonatomic, weak) id <FbUserInfoButtonsDelegate> delegate;

@end
