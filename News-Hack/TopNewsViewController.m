//
//  TopNewsViewController.m
//  News-Hack
//
//  Created by Lukas Carvajal on 6/10/15.
//  Copyright (c) 2015 Lukas Carvajal. All rights reserved.
//

#import "TopNewsViewController.h"
#import "ArticleViewController.h"
#import "SourcesViewController.h"
#import "TFHpple.h"
#import "Article.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface TopNewsViewController ()

@property NSMutableArray *wsjArticles; // The Wall Street Journal articles
@property NSMutableArray *nytArticles; // The New York Times articles
@property NSMutableArray *usaArticles; // USA Today articles

@property int numArticles;             // number of articles

@property NSUserDefaults *prefs;    // load NSUserDefaults
@property NSMutableArray *sources;  // declare array to be stored in NSUserDefaults

@end

@implementation TopNewsViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Refresh on pull down
    if(!self.refreshControl) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.backgroundColor = [UIColor colorWithRed: 1.0/255.0f green:8.0/255.0f blue:154.0/255.0f alpha:1.0];
        self.refreshControl.tintColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(getLatestArticles)
                      forControlEvents:UIControlEventValueChanged];
    }
    
    // load user preferences
    if (!self.prefs) {
        _prefs = [NSUserDefaults standardUserDefaults];
    }
    if (!self.sources) {
        
        @try {
            _sources = [[ NSMutableArray alloc] initWithArray:[_prefs arrayForKey:@"favourites"]];
        }
        @catch (NSException *ex) {

            _sources = [[ NSMutableArray alloc] initWithObjects:@"1",@"1", @"1", nil];
            [_prefs setObject:_sources forKey:@"favourites"];  //set the prev Array for key value "favourites"
        }
        
    }
    
    _sources = [[ NSMutableArray alloc] initWithObjects:@"1",@"1", @"1", nil];
    
    self.numArticles = 0;
    //[self loadWallStreetJournal];
    [self loadNewYorkTimes];
    [self loadUSAToday];
    
    
    // set back button for next view
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)refresh {
    
    [self.wsjArticles removeAllObjects];
    [self.nytArticles removeAllObjects];
    [self.usaArticles removeAllObjects];
    
    [self.view setNeedsDisplay];
}

// CUSTOM METHODS

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
    for (int i = 0; i < 30; i++) {
        
        TFHppleElement *element = [wsjNodes objectAtIndex:i];
        
        // create nyt object
        Article *wallStreetJournal = [[Article alloc] init];
        [wsjNews addObject:wallStreetJournal];
        
        // tites
        wallStreetJournal.title = [[element firstChild] content];
        
        // urls
        wallStreetJournal.url = [self translateURL: [element objectForKey:@"href"]];
        
        self.numArticles++;
    }
    
    // 8
    self.wsjArticles = wsjNews;
    [self.tableView reloadData];
}

-(void)loadNewYorkTimes {
    
    // Link for GET request.
    NSURL *url = [[NSURL alloc] initWithString:@"http://api.nytimes.com/svc/topstories/v1/home.json?api-key=bedbf403ee7eb8016c6796596b0384f8:7:72428141"];
    
    // handle JSON and receive nyt results
    NSDictionary* dict = [self setUpJSON:url];
    NSArray *object = [[NSArray alloc] init];
    object = [dict objectForKey:@"results"];
    
    // Set article properties for entire New York Times articles array.
    NSMutableArray *nytNews = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [object count]; i++) {
        
        // create nyt object
        Article *newYorkTimes = [[Article alloc] init];
        [nytNews addObject:newYorkTimes];
        
        // tites
        newYorkTimes.title = [object[i] valueForKey:@"title"];
        
        // urls
        newYorkTimes.url = [self translateURL: [object[i] valueForKey:@"url"]];
        
        self.numArticles++;
    }
    
    self.nytArticles = nytNews;
    [self.tableView reloadData];
}

- (void) loadUSAToday {
    
    // Link for GET request.
    NSURL *url = [[NSURL alloc] initWithString:@"http://api.usatoday.com/open/articles?expired=true&count=20&encoding=json&api_key=d7hw56bu2ve9sxmq4yf78452"];
    
    // handle JSON and receive USA Today results
    NSDictionary* dict = [self setUpJSON:url];
    NSArray *object = [[NSArray alloc] init];
    object = [dict objectForKey:@"stories"];
    
    // Set article properties for entire New York Times articles array.
    NSMutableArray *usaNews = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [object count]; i++) {
        
        // create nyt object
        Article *usaToday = [[Article alloc] init];
        
        // tites
        usaToday.title = [object[i] valueForKey:@"title"];
        
        // urls
        usaToday.url = [self translateURL: [object[i] valueForKey:@"link"]];
        
        // Add article to arrays.
        [usaNews addObject:usaToday];
        
        self.numArticles++;
    }
    
    self.usaArticles = usaNews;
    [self.tableView reloadData];
}

- (NSDictionary*) setUpJSON:(NSURL*) url {
    
    // Prepare request object
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                            timeoutInterval:30];
    
    // Prepare variables for JSON response.
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    // Make sunchronous request.
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    
    // Construct Array around Data from response.
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:urlData
                                                         options:0
                                                           error:&error];
    return dict;
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


- (void)getLatestArticles {
    [self.refreshControl endRefreshing];    // end refresh on pull down
}

// END OF CUSTOM METHODS

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        Article *object = [[Article alloc] init];
        
        if (indexPath.row < [self.wsjArticles count])
            object = self.wsjArticles[indexPath.row];
        else if (indexPath.row < ([self.wsjArticles count]
                                  + [self.nytArticles count]))
            object = self.nytArticles[indexPath.row - [self.wsjArticles count]];
        else if (indexPath.row < ([self.wsjArticles count]
                                  + [self.nytArticles count]
                                  + [self.usaArticles count]))
            object = self.usaArticles[indexPath.row - [self.wsjArticles count] - [self.nytArticles count]];
        
        NSString* articleUrlPass = [[NSString alloc] init];
        articleUrlPass = object.url;
        
        ArticleViewController *controller = segue.destinationViewController;
        controller.articleURL = articleUrlPass;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
    else if ([[segue identifier] isEqualToString:@"showSources"]) {
        SourcesViewController *controller = segue.destinationViewController;
        controller.sources = [[NSArray alloc] initWithArray:self.sources];
    }
}

#pragma mark - Table View

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, tableView.frame.size.width, 50.0)];
    sectionHeaderView.backgroundColor = UIColorFromRGB(0x00079A);
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(15, 15, sectionHeaderView.frame.size.width, 25.0)];
    
    // Table header styling.
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.textColor = [UIColor whiteColor];
    [sectionHeaderView addSubview:headerLabel];
    
    switch (section) {
        case 0:
            headerLabel.text = @"Wall Street Journal";
            return sectionHeaderView;
            break;
        case 1:
            headerLabel.text = @"New York Times";
            return sectionHeaderView;
            break;
        case 2:
            headerLabel.text = @"USA Today";
            return sectionHeaderView;
            break;
        default:
            break;
    }
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.wsjArticles count];
            break;
        case 1:
            return [self.nytArticles count];
            break;
        case 2:
            return [self.usaArticles count];
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        Article *thisArticle = [self.wsjArticles objectAtIndex:indexPath.row];
        cell.textLabel.text = thisArticle.title;
    } else if (indexPath.section == 1) {
        Article *thisArticle = [self.nytArticles objectAtIndex:indexPath.row];
        cell.textLabel.text = thisArticle.title;
    } else if (indexPath.section == 2) {
        Article *thisArticle = [self.usaArticles objectAtIndex:indexPath.row];
        cell.textLabel.text = thisArticle.title;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.wsjArticles removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


@end
