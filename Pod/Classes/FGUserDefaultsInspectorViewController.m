#import "FGUserDefaultsInspectorViewController.h"
#import "FGUserDefaultsInspectorCell.h"
#import "FGUserDefaultsEditViewController.h"
#import "FGUserDefaultsFormatter.h"


@interface FGUserDefaultsInspectorViewController () <UIActionSheetDelegate, UISearchResultsUpdating, UISearchControllerDelegate>
@property(nonatomic, strong) NSDictionary *dictionaryRepresentation;
@property(nonatomic, strong) NSDictionary *filteredDictionaryRepresentation;
@property(nonatomic) BOOL showAllKeys;
@property(nonatomic, strong) UISearchController *searchController;
@end

@implementation FGUserDefaultsInspectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"NSUserDefaults Inspector";

    [self.tableView registerClass:[FGUserDefaultsInspectorCell class] forCellReuseIdentifier:@"cell"];

    if([UISearchController class]) {
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchResultsUpdater = self;
        self.searchController.delegate = self;
        self.searchController.dimsBackgroundDuringPresentation = NO;
        self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);

        self.tableView.tableHeaderView = self.searchController.searchBar;

        self.definesPresentationContext = YES;
    }

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(_showActionItems:)];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateList) name:NSUserDefaultsDidChangeNotification object:nil];

    [self _updateList];
}

- (void)_updateList {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.showAllKeys) {
        self.dictionaryRepresentation = [userDefaults dictionaryRepresentation];
    } else {
        self.dictionaryRepresentation = [userDefaults persistentDomainForName:[NSBundle mainBundle].bundleIdentifier];
    }
    self.filteredDictionaryRepresentation = self.dictionaryRepresentation;

    [self.tableView reloadData];
}

- (void)_showActionItems:(id)sender {
    NSString *otherButtonTitle = self.showAllKeys ? @"Show only App Domain" : @"Show All";
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Abbrechen" destructiveButtonTitle:@"Delete App's UserDefaults" otherButtonTitles:otherButtonTitle, nil];
    [sheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark table view delegate & data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredDictionaryRepresentation.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    id key = self.filteredDictionaryRepresentation.allKeys[(NSUInteger) indexPath.row];
    id value = self.filteredDictionaryRepresentation[key];

    cell.textLabel.text = [FGUserDefaultsFormatter descriptionForObject:value];
    cell.detailTextLabel.text = [@"Key: " stringByAppendingString:[FGUserDefaultsFormatter descriptionForObject:key]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id key = self.filteredDictionaryRepresentation.allKeys[(NSUInteger) indexPath.row];
    id value = self.filteredDictionaryRepresentation[key];
    FGUserDefaultsEditViewController *editVC = [[FGUserDefaultsEditViewController alloc] initWithKey:key value:value];
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark UISearchController stuff

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [self.searchController.searchBar text];

    NSMutableDictionary *filtered = [[NSMutableDictionary alloc] init];
    for(id key in self.dictionaryRepresentation) {
        if(([key respondsToSelector:@selector(containsString:)] && [key containsString:searchString]) || [searchString isEqualToString:@""]) {
            filtered[key] = self.dictionaryRepresentation[key];
        }
    }
    self.filteredDictionaryRepresentation = filtered;

    [self.tableView reloadData];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    self.filteredDictionaryRepresentation = self.dictionaryRepresentation;
    [self.tableView reloadData];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if([actionSheet destructiveButtonIndex] == buttonIndex) {
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[NSBundle mainBundle].bundleIdentifier];
    } else {
        self.showAllKeys = ! self.showAllKeys;
        [self _updateList];
    }
}

@end
