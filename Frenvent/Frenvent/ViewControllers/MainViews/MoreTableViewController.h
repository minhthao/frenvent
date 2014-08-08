//
//  MoreTableViewController.h
//  Frenvent
//
//  Created by minh thao nguyen on 7/11/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
