//
//  SourcesViewController.h
//  News-Hack
//
//  Created by Lukas Carvajal on 6/17/15.
//  Copyright (c) 2015 Lukas Carvajal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SourcesViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISwitch *nytSwitchOutlet;
@property (strong, nonatomic) IBOutlet UISwitch *usaSwitchOutlet;

- (IBAction)nytSwitch:(id)sender;
- (IBAction)usaSwitch:(id)sender;

@end
