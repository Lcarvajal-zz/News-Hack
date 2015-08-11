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

@property NSMutableArray *nytArticles;  // The New York Times articles
@property NSMutableArray *usaArticles;  // USA Today articles
@property NSUserDefaults *defaults;     // current defaults

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

- (void)viewWillAppear:(BOOL)animated {
    
    // Get current preferences.
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    // Reload data if sources change.
    if ([self.defaults boolForKey:@"sourcesChanged"]){
        
        // Reset.
        [self.defaults setBool:NO forKey:@"sourcesChanged"];
        
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
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    // User preferences have not been set! First launch.
    if (![self.defaults boolForKey:@"hasBeenLaunched"]) {
        
        [self.defaults setBool:YES forKey:@"hasBeenLaunched"];
        [self.defaults setBool:YES forKey:@"NYT"];
        [self.defaults setBool:YES forKey:@"USA"];
        [self.defaults setBool:NO forKey:@"sourcesChanged"];
        [self.defaults synchronize];
    }
    
    // Get current preferences.
    BOOL nyt = [self.defaults boolForKey:@"NYT"];
    BOOL usa = [self.defaults boolForKey:@"USA"];
    
    
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
    
    // Link for GET request from News Hack web service.
    NSURL *url = [[NSURL alloc] initWithString:@"http://newshackapp.bitnamiapp.com/News-Hack-Web-Service/readArticlesTable.php"];
    
    // Array for holding all articles.
    self.nytArticles = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Handle JSON and receive News Hack web service results.
    NSDictionary* dict = [self setUpJSON:url];
    
    // Store results in article objects in  nytNews array.
    for (id object in dict) {
        
        Article *article = [[Article alloc] init];
        article.title = [object valueForKey:@"title"];
        article.author = [[[object valueForKey:@"author"] lowercaseString] capitalizedString];
        article.url = [self translateURL: [object valueForKey:@"url"]] ;
        article.category = [object valueForKey:@"category"];
        article.snippet = [object valueForKey:@"snippet"];
        article.content = [object valueForKey:@"content"];
        
        [self.nytArticles addObject:article];
    }
    
    [self.tableView reloadData];
}

- (void) loadUSAToday {
    
    // Link for GET request.
    NSURL *url = [[NSURL alloc] initWithString:@"http://api.usatoday.com/open/articles?expired=true&count=20&encoding=json&api_key=d7hw56bu2ve9sxmq4yf78452"];
    
    // Handle JSON and receive USA Today results.
    NSDictionary* dict = [self setUpJSON:url];
    NSArray *object = [[NSArray alloc] init];
    object = [dict objectForKey:@"stories"];
    
    // Set article properties for entire USA Today articles array.
    NSMutableArray *usaNews = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [object count]; i++) {
        
        // Create usaToday article.
        Article *usaToday = [[Article alloc] init];
        
        // Titles.
        usaToday.title = [object[i] valueForKey:@"title"];
        
        // URLs.
        usaToday.url = [self translateURL: [object[i] valueForKey:@"link"]];
        
        // Authors, need to be in capitalized format.
        usaToday.author = [object[i] valueForKey:@"author"];
        
        // Authors, need to be in capitalized format.
        usaToday.snippet = [object[i] valueForKey:@"description"];
        
        // Add article to arrays.
        [usaNews addObject:usaToday];
    }
    
    self.usaArticles = usaNews;
    [self.tableView reloadData];
}

- (NSDictionary*) setUpJSON:(NSURL*) url {
    
    // Declare dictionary of urls to be returned.
    NSDictionary *dict;
    
    // Prepare request object.
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
    
    // Check for error in retrieving data.
    if (urlData != nil)
    {
        dict = [NSJSONSerialization JSONObjectWithData:urlData options: NSJSONReadingMutableContainers error: &error];
        
        return dict;
    }
    else
    {
        if (error != nil)
        {
            NSLog(@"Error description=%@", [error description]);
        }
    }
    
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
        
        ArticleViewController *controller = segue.destinationViewController;
        controller.articleTitle = object.title;
        controller.articleURL = object.url;
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
            headerLabel.text = @"The New York Times";
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
    
    BOOL nyt = [self.defaults boolForKey:@"NYT"];
    BOOL usa = [self.defaults boolForKey:@"USA"];
    
    if (nyt && (section == 0)) {
        
        return 50.0f;
    }
    
    if (usa && (section == 1)) {
        
        return 50.0f;
    }
    
    return 0.0f;
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
    static NSString *USATodayCellIdentifier = @"USATodayCell";
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (indexPath.section == 1) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:USATodayCellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:USATodayCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    UILabel *articleTitleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *articleSnippetLabel = (UILabel *)[cell viewWithTag:3];
    
    
    if (indexPath.section == 0) {
        UILabel *articleAuthorLabel = (UILabel *)[cell viewWithTag:2];
        
        Article *thisArticle = [self.nytArticles objectAtIndex:indexPath.row];
        
        articleTitleLabel.text = thisArticle.title;
        articleAuthorLabel.text = thisArticle.author;
        articleSnippetLabel.text = thisArticle.snippet;
    } else if (indexPath.section == 1) {
        Article *thisArticle = [self.usaArticles objectAtIndex:indexPath.row];
        
        articleTitleLabel.text = thisArticle.title;
        articleSnippetLabel.text = thisArticle.snippet;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 200;
    }
    return 131;
}

@end
