//
//  SourcesViewController.h
//  News-Hack
//
//  Created by Lukas Carvajal on 6/17/15.
//  Copyright (c) 2015 Lukas Carvajal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SourcesViewController : UIViewController


@property (weak, nonatomic) IBOutlet UISwitch *switchWSJ;
@property (weak, nonatomic) IBOutlet UISwitch *switchNYT;

@property NSUserDefaults *prefs;  //load NSUserDefaults
@property NSMutableArray *sources;  //declare array to be stored in NSUserDefaults

@end
