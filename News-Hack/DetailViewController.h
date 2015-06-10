//
//  DetailViewController.h
//  News-Hack
//
//  Created by Lukas Carvajal on 6/10/15.
//  Copyright (c) 2015 Lukas Carvajal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSString* articleURL;
@property (weak, nonatomic) IBOutlet UIWebView *article;

@end

