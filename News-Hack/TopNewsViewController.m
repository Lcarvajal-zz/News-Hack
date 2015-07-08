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

@property NSMutableArray *nytArticles; // The New York Times articles
@property NSMutableArray *usaArticles; // USA Today articles

@end

@implementation TopNewsViewController

@dynamic tableView;

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
    
    // Get current preferences.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // User preferences have not been set! First launch.
    if (![defaults boolForKey:@"hasBeenLaunched"]) {
        
        [defaults setBool:YES forKey:@"hasBeenLaunched"];
        [defaults setBool:YES forKey:@"NYT"];
        [defaults setBool:YES forKey:@"USA"];
        [defaults synchronize];
    }
    
    // Get current preferences.
    BOOL nyt = [defaults boolForKey:@"NYT"];
    BOOL usa = [defaults boolForKey:@"USA"];

    // Load articles if user wants them.
    if (nyt)
        [self loadNewYorkTimes];
    
    if (usa)
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

// CUSTOM METHODS

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
    
    // "translate" article from japanese.
    url = [ @"http://translate.google.com/translate?sl=ja&tl=en&u=" stringByAppendingString: url];
    
    // Download webpage.
    NSURL *exUrl = [NSURL URLWithString:url];
    NSData *htmlData = [NSData dataWithContentsOfURL:exUrl];
    
    // Create parser.
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    
    // Get url from google translated iframe.
    NSString *articleURL = @"//iframe";
    NSArray *node = [parser searchWithXPathQuery:articleURL];
    TFHppleElement *element = [node objectAtIndex:0];
    url = [element objectForKey:@"src"];
    
    // Add google translate url.
    url = [@"http://translate.google.com" stringByAppendingString: url];
    
    return url;
    
}


- (void)getLatestArticles {
    
    // Reset articles.
    [self.nytArticles removeAllObjects];
    [self.usaArticles removeAllObjects];
    
    // Pull current preferences.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL nyt = [defaults boolForKey:@"NYT"];
    BOOL usa = [defaults boolForKey:@"USA"];
    
    // Reload articles.
    // Load articles if user wants them.
    if (nyt)
        [self loadNewYorkTimes];
    
    if (usa)
        [self loadUSAToday];
    
    // Reload table view data.
    [self.tableView reloadData];
    
    // End refresh on pull down.
    [self.refreshControl endRefreshing];
}

// END OF CUSTOM METHODS

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        Article *object = [[Article alloc] init];
        
        if (indexPath.row < [self.nytArticles count])
            object = self.nytArticles[indexPath.row];
        else if (indexPath.row < ([self.nytArticles count]
                                  + [self.usaArticles count]))
            object = self.usaArticles[indexPath.row - [self.nytArticles count]];
        
        NSString* articleUrlPass = [[NSString alloc] init];
        articleUrlPass = object.url;
        
        ArticleViewController *controller = segue.destinationViewController;
        controller.articleURL = articleUrlPass;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
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
            headerLabel.text = @"New York Times";
            return sectionHeaderView;
            break;
        case 1:
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.nytArticles count];
            break;
        case 1:
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
        Article *thisArticle = [self.nytArticles objectAtIndex:indexPath.row];
        cell.textLabel.text = thisArticle.title;
    } else if (indexPath.section == 1) {
        Article *thisArticle = [self.usaArticles objectAtIndex:indexPath.row];
        cell.textLabel.text = thisArticle.title;
    }
    
    return cell;
}

@end
