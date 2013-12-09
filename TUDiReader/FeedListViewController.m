//
//  FeedListViewController.m
//  TUDiReader
//
//  Created by Martin Weißbach on 10/28/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "FeedListViewController.h"

#import "NewFeedViewController.h"
#import "Feed.h"
#import "ItemListViewController.h"

@interface FeedListViewController () <NewFeedViewControllerDelegate>

/// Feeds that are stored and displayed in this view.
@property (strong, nonatomic) NSMutableArray *feeds;    // mutable objects can be modified at runtime. Objects can be added / removed to the array.

/*!
    Displays the NewFeedView to create a new feed for the list.
    
    @param sender   The object who send this message to the receiver.
 */
- (void)openNewFeedView:(id)sender;

@end

@implementation FeedListViewController

- (void)viewDidLoad
{
    [super viewDidLoad]; // Always forward viewDidLoad to the super class. Views will not correctly otherwise.

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DefaultFeeds" ofType:@"plist"];
    NSArray *rawFeeds = [NSArray arrayWithContentsOfFile:filePath]; // Array of NSDictionary objects (compare to DefaultFeeds.plist)
    self.feeds = [NSMutableArray arrayWithCapacity:rawFeeds.count];
    for (NSDictionary *rawFeed in rawFeeds) {
        /*!
            An NSDictionary stores pairs of key-value.
            keyForValue: returns the value represented by the given key or nil if the key is not existing
         */
        Feed *feed = [[Feed alloc] initWithTitle:[rawFeed valueForKey:@"title"]
                                          andURL:[NSURL URLWithString:[rawFeed valueForKey:@"url"]]];
        [self.feeds addObject:feed];
    }
    
    /*!
        The navigation item represents the view controller in a parent's view navigation controller.
        It is inherited from UIViewController and only visible when the view was added to a navigation controller's view stack.
     
        The _target_ of the UIBarButton item is the receiver of messages that will be sent when the button reckognizes a touch event.
        The _action_ is the name of the message sent when the button detects a touch event.
     */
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(openNewFeedView:)];
    /*!
        Just an example why the dot-syntax for properties is so much nicer than using the actual getter and setter methods ;)
     [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                                target:self
                                                                                                action:@selector(openNewFeedView:)]];
     */
}

- (NSString *)title
{
    /*!
        Return the title of the View. It will be displayed in the navigation bar in the title field.
        Alternatively you could use (in viewDidLoad):
        [self.navigationItem.title = @"Feeds"];
     */
    return @"Feeds";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
/*!
    Implementation of UITableViewDataSource methods.
 
    numberOfSectionsInTableView:
    tableView:numberOfRowsInSection:
    tableView:cellForRowAtIndexPath:
 
    are mandatory.
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*!
        Return the number of rows in the respective section.
        Since we have only one section and a one-dimensional array as a data structure we can simply return the number of
        items in the array.
     */
    return self.feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*!
        The _reuseIdentifier_ is used to identify the cell object if it is to be reused.
        If you pass nil as a reuse identifier, the cell will not be reused.
        The same reuse identifier should be used for cells that have the same form. Consequently, multiple different reuse identifiers
        are possible for differently formed cells.
     */
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    /*!
        Keep in mind that we know what kind of objects are stored in the Array.
        Objects stored in here that are not feeds would cause a crash.
        One possible solution is to check the object's type we want to add to the array.
        If it is of kind 'Feed' we can added, otherwise not.
     */
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    cell.textLabel.text = feed.title;
    cell.detailTextLabel.text = [feed.url absoluteString];
    /*!
        Displays a gray arrow – the disclosure indicator – at the UITableView's right border.
     */
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = [self.feeds objectAtIndex:indexPath.row];
    
    ItemListViewController *itemListViewController = [[ItemListViewController alloc] initWithNibName:@"ListView" bundle:nil];
    itemListViewController.feed = feed;
    
    [self.navigationController pushViewController:itemListViewController animated:YES];
}

#pragma mark - Custom Actions

- (void)openNewFeedView:(id)sender
{
    NewFeedViewController *newFeedViewController = [[NewFeedViewController alloc] initWithNibName:@"NewFeedView" bundle:nil];
    newFeedViewController.delegate = self;
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:newFeedViewController]
                       animated:YES
                     completion:nil];
}

#pragma mark - NewFeedViewControllerDelegate

- (void)saveFeed:(Feed *)feed
{
    /*!
        The parameters type actually is already a type check, but it is weak because Xcode only gives us a warning when
        we send this message to FeedListViewController, which we can ignore.
        To really make sure only objects of kind 'Feed' are added to the array the following construct would do the job.
    if ([feed isKindOfClass:[Feed class]]) {
        [self.feeds addObject:feed];
    } else NSLog(@"Not a feed!");
     */
    [self.feeds addObject:feed];
    [((UITableView *)self.view) reloadData];
}

@end
