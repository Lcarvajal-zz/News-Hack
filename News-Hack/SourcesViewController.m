//
//  SourcesViewController.m
//  News-Hack
//
//  Created by Lukas Carvajal on 6/17/15.
//  Copyright (c) 2015 Lukas Carvajal. All rights reserved.
//

#import "SourcesViewController.h"

@interface SourcesViewController ()

@end

@implementation SourcesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Pull current user preferences.
    BOOL nyt = [defaults boolForKey:@"NYT"];
    BOOL usa = [defaults boolForKey:@"USA"];
    
    // Set switches based on current user preferences.
    if (!nyt)
        [self.nytSwitchOutlet setOn:NO animated:NO];
    else
        [self.nytSwitchOutlet setOn:YES animated:NO];
    
    if (!usa)
        [self.usaSwitchOutlet setOn:NO animated:NO];
    else
        [self.usaSwitchOutlet setOn:YES animated:NO];
    
    [self.nytSwitchOutlet addTarget:self
                      action:@selector(nytSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.usaSwitchOutlet addTarget:self
                             action:@selector(usaSwitch:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nytSwitch:(id)sender {
    
    // Pull current preferences.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Turn switch on or off and store correct user setting.
    if ([self.nytSwitchOutlet isOn]) {
        [self.nytSwitchOutlet setOn:YES animated:YES];
        [defaults setBool:YES forKey:@"NYT"];
    }
    else {
        
        [self.nytSwitchOutlet setOn:NO animated:YES];
        [defaults setBool:NO forKey:@"NYT"];
    }
    
    // Sync user preferences.
    [defaults synchronize];
}

- (IBAction)usaSwitch:(id)sender {
    
    // Pull current preferences.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Turn switch on or off and store correct user setting.
    if ([self.usaSwitchOutlet isOn]) {
        [self.usaSwitchOutlet setOn:YES animated:YES];
        [defaults setBool:YES forKey:@"USA"];
    }
    else {
        [self.usaSwitchOutlet setOn:NO animated:YES];
        [defaults setBool:NO forKey:@"USA"];
    }
    
    // Sync user preferences.
    [defaults synchronize];
}
@end
