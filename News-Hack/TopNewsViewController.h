//
//  TopNewsViewController.h
//  News-Hack
//
//  Created by Lukas Carvajal on 6/10/15.
//  Copyright (c) 2015 Lukas Carvajal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@class ArticleViewController;

@interface TopNewsViewController : UITableViewController

- (NSString*) translateURL: (NSString*) url;

@property (strong, nonatomic) ArticleViewController *detailViewController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end

