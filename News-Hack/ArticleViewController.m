//
//  ArticleViewController.m
//  News-Hack
//
//  Created by Lukas Carvajal on 6/10/15.
//  Copyright (c) 2015 Lukas Carvajal. All rights reserved.
//

#import "ArticleViewController.h"

@interface ArticleViewController ()

@end

@implementation ArticleViewController

#pragma mark - Managing the detail item

- (void)configureView {
    
    if (self.articleURL) {
        
        [self.article loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.articleURL]]];
        
    }
    else
        self.navigationItem.title = @"News Hack Error";
   
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.article.dataDetectorTypes = UIDataDetectorTypeNone;
    
    // Use article title for navigation bar title.
    if (self.articleTitle)
        self.navigationItem.title = @"News Hack(ed)";
    
    // Use web view to display article.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
