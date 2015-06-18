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
    
    NSLog( [_sources objectAtIndex:0] );
    NSLog( [_sources objectAtIndex:1] );
    
    [_switchWSJ addTarget:self action:@selector(changeWSJ:) forControlEvents:UIControlEventValueChanged];
    [_switchNYT addTarget:self action:@selector(changeNYT:) forControlEvents:UIControlEventValueChanged];
    
    // turn source switch on or off
    if ([_sources[0] isEqualToString:@"1"])
        [_switchWSJ setOn:YES animated:NO];
    else
        [_switchWSJ setOn:NO animated:NO];
    
    if ([_sources[0] isEqualToString:@"1"])
        [_switchNYT setOn:YES animated:NO];
    else
        [_switchNYT setOn:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// handle switch clicks
- (void)changeWSJ: (id)sender {
    NSLog( @"touched" );

    if ([_sources[0] isEqualToString: @"1"])
        _sources[0] = @"0";
    else
        _sources[0] = @"1";
    
    [_prefs setObject:_sources forKey:@"favourites"];
}

// handle switch clicks
- (void)changeNYT: (id)sender {
    NSLog( @"touched" );
    
    if ([_sources[1] isEqualToString: @"1"])
        _sources[1] = @"0";
    else
        _sources[1] = @"1";
    
    [_prefs setObject:_sources forKey:@"favourites"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
