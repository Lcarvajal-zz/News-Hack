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
    [_article loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.articleURL]]];
   
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
