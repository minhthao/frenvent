//
//  FriendsTableViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/7/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
