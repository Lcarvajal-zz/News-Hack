//
//  SourcesViewController.m
//  News-Hack
//
//  Created by Lukas Carvajal on 6/17/15.
//  Copyright (c) 2015 Lukas Carvajal. All rights reserved.
//

#import "SourcesViewController.h"

@interface SourcesViewController ()

@property NSUserDefaults *defaults;     // current defaults

@end

@implementation SourcesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    // Pull current user preferences.
    BOOL nyt = [self.defaults boolForKey:@"NYT"];
    BOOL usa = [self.defaults boolForKey:@"USA"];
    
    // Set switches based on current user preferences.
    if (!nyt) {
        
        [self.nytSwitchOutlet setOn:NO animated:NO];
    }
    else {
        
        [self.nytSwitchOutlet setOn:YES animated:NO];
    }
    if (!usa) {
        
        [self.usaSwitchOutlet setOn:NO animated:NO];
    }
    else {
        
        [self.usaSwitchOutlet setOn:YES animated:NO];
    }
    
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
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    // Turn switch on or off and store correct user setting.
    if ([self.nytSwitchOutlet isOn]) {
        [self.nytSwitchOutlet setOn:YES animated:YES];
        [self.defaults setBool:YES forKey:@"NYT"];
    }
    else {
        
        [self.nytSwitchOutlet setOn:NO animated:YES];
        [self.defaults setBool:NO forKey:@"NYT"];
    }
    
    [self.defaults setBool:YES forKey:@"sourcesChanged"];
    
    // Sync user preferences.
    [self.defaults synchronize];
}

- (IBAction)usaSwitch:(id)sender {
    
    // Pull current preferences.
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    // Turn switch on or off and store correct user setting.
    if ([self.usaSwitchOutlet isOn]) {
        [self.usaSwitchOutlet setOn:YES animated:YES];
        [self.defaults setBool:YES forKey:@"USA"];
    }
    else {
        [self.usaSwitchOutlet setOn:NO animated:YES];
        [self.defaults setBool:NO forKey:@"USA"];
    }
    
    [self.defaults setBool:YES forKey:@"sourcesChanged"];
    
    // Sync user preferences.
    [self.defaults synchronize];
}
@end
