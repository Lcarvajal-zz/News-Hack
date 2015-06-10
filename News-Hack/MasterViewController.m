//
//  MasterViewController.m
//  News-Hack
//
//  Created by Lukas Carvajal on 6/10/15.
//  Copyright (c) 2015 Lukas Carvajal. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "TFHpple.h"
#import "Article.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController

// CUSTOM CLASSES

-(void)loadNewYorkTimes {
    // download webpage
    NSURL *nytUrl = [NSURL URLWithString:@"http://www.nytimes.com/"];
    NSData *nytHtmlData = [NSData dataWithContentsOfURL:nytUrl];
    
    // create parser
    TFHpple *nytParser = [TFHpple hppleWithHTMLData:nytHtmlData];
    
    // array for holding nyt objects
    NSString *nytArticleURL = @"//article/h2[@class='story-heading']/a";
    NSArray *nytNodes = [nytParser searchWithXPathQuery:nytArticleURL];
    
    // loop through articles
    NSMutableArray *nytNews = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 1; i < 30; i++) {
        
        TFHppleElement *element = [nytNodes objectAtIndex:i];
        
        // create nyt object
        Article *newYorkTimes = [[Article alloc] init];
        [nytNews addObject:newYorkTimes];
        
        // tites
        newYorkTimes.title = [[element firstChild] content];
        
        // descriptions
        newYorkTimes.description = [[element firstChildWithTagName:@"p"] content];
        
        // urls
        newYorkTimes.url = [self translateURL: [element objectForKey:@"href"]];
        
    }
    
    // 8
    _objects = nytNews;
    [self.tableView reloadData];
}

-(void)loadWallStreetJournal {
    // download webpage
    NSURL *wsjUrl = [NSURL URLWithString:@"http://www.wsj.com/"];
    NSData *wsjHtmlData = [NSData dataWithContentsOfURL:wsjUrl];
    
    // create parser
    TFHpple *wsjParser = [TFHpple hppleWithHTMLData:wsjHtmlData];
    
    // array for holding nyt objects
    NSString *wsjArticleURL = @"//a[@class='wsj-headline-link']";
    NSArray *wsjNodes = [wsjParser searchWithXPathQuery:wsjArticleURL];
    
    // loop through articles
    NSMutableArray *wsjNews = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 1; i < 30; i++) {
        
        TFHppleElement *element = [wsjNodes objectAtIndex:i];
        
        // create nyt object
        Article *walStreetJournal = [[Article alloc] init];
        [wsjNews addObject:walStreetJournal];
        
        // tites
        walStreetJournal.title = [[element firstChild] content];
        
        // urls
        walStreetJournal.url = [self translateURL: [element objectForKey:@"href"]];
        
    }
    
    // 8
    _objects = wsjNews;
    [self.tableView reloadData];
}

- (NSString*) translateURL:(NSString *)url {
    
    // "translate" article from japanese
    url = [ @"http://translate.google.com/translate?sl=ja&tl=en&u=" stringByAppendingString: url];
    
    // download webpage
    NSURL *exUrl = [NSURL URLWithString:url];
    NSData *htmlData = [NSData dataWithContentsOfURL:exUrl];
    
    // create parser
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    
    // get url from google translated iframe
    NSString *articleURL = @"//iframe";
    NSArray *node = [parser searchWithXPathQuery:articleURL];
    TFHppleElement *element = [node objectAtIndex:0];
    url = [element objectForKey:@"src"];
    
    // add google translate url
    url = [@"http://translate.google.com" stringByAppendingString: url];
    
    return url;
    
}

// END OF CUSTOM CLASSES

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadWallStreetJournal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Article *object = self.objects[indexPath.row];
        NSString* articleUrlPass = [[NSString alloc] init];
        articleUrlPass = object.url;
        
        DetailViewController *controller = segue.destinationViewController;
        controller.articleURL = articleUrlPass;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Article *article = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = article.title;
    cell.detailTextLabel.text = article.url;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


@end
