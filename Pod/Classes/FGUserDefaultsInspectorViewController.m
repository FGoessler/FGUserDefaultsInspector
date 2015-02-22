#import "FGUserDefaultsInspectorViewController.h"
#import "FGUserDefaultsInspectorCell.h"
#import "FGUserDefaultsEditViewController.h"
#import "FGUserDefaultsFormatter.h"


@interface FGUserDefaultsInspectorViewController () <UIActionSheetDelegate, UISearchResultsUpdating, UISearchControllerDelegate, FGUserDefaultsEditViewControllerDelegate>
@property(nonatomic, strong) NSDictionary *dictionaryRepresentation;
@property(nonatomic, strong) NSArray *processedKeys;
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
    if (self.showAllKeys) {
        self.dictionaryRepresentation = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    } else {
        self.dictionaryRepresentation = [[NSUserDefaults standardUserDefaults] persistentDomainForName:[NSBundle mainBundle].bundleIdentifier];
    }
    self.processedKeys = [self.dictionaryRepresentation.allKeys sortedArrayUsingSelector:@selector(compare:)];

    [self.tableView reloadData];
}

- (void)_showActionItems:(id)sender {
    NSString *otherButtonTitle = self.showAllKeys ? @"Show only App Domain" : @"Show All";
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Abbrechen"
                                         destructiveButtonTitle:@"Delete App's UserDefaults"
                                              otherButtonTitles:otherButtonTitle, @"New Entry", @"Export", nil];
    [sheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark table view delegate & data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.processedKeys.count;
}

- (id)keyForIndexPath:(NSIndexPath *)indexPath {
    return self.processedKeys[(NSUInteger) indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    id key = [self keyForIndexPath:indexPath];
    id value = self.dictionaryRepresentation[key];

    cell.textLabel.text = [FGUserDefaultsFormatter descriptionForObject:value];
    cell.detailTextLabel.text = [@"Key: " stringByAppendingString:[FGUserDefaultsFormatter descriptionForObject:key]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id key = [self keyForIndexPath:indexPath];
    id value = self.dictionaryRepresentation[key];
    FGUserDefaultsEditViewController *editVC = [[FGUserDefaultsEditViewController alloc] initWithKey:key value:value];
    editVC.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:editVC] animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id key = [self keyForIndexPath:indexPath];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark UISearchController stuff

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [[self.searchController.searchBar text] lowercaseString];

    NSMutableArray *filteredKeys = [[NSMutableArray alloc] init];
    for(id key in self.dictionaryRepresentation) {
        if(([key respondsToSelector:@selector(containsString:)] && [[key lowercaseString] containsString:searchString]) || [searchString isEqualToString:@""]) {
            [filteredKeys addObject:key];
        }
    }
    self.processedKeys = [filteredKeys sortedArrayUsingSelector:@selector(compare:)];

    [self.tableView reloadData];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    [self _updateList];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if([actionSheet destructiveButtonIndex] == buttonIndex) {
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[NSBundle mainBundle].bundleIdentifier];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"New Entry"]) {
        FGUserDefaultsEditViewController *editVC = [[FGUserDefaultsEditViewController alloc] initToCreateNewKeyValuePair];
        editVC.delegate = self;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:editVC] animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Export"]) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[[self.dictionaryRepresentation description]] applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Show only App Domain"] ||
            [[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Show All"]) {
        self.showAllKeys = ! self.showAllKeys;
        [self _updateList];
    }
}

#pragma mark FGUserDefaultsEditViewControllerDelegate

- (void)defaultsEditVC:(FGUserDefaultsEditViewController *)editVC requestedSaveOf:(id)object atKey:(id)key {
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
