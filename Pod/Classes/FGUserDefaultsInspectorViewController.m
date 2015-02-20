#import "FGUserDefaultsInspectorViewController.h"
#import "FGUserDefaultsInspectorCell.h"
#import "FGUserDefaultsEditViewController.h"


@interface FGUserDefaultsInspectorViewController () <UIActionSheetDelegate>
@property(nonatomic, strong) NSDictionary *dictionaryRepresentation;
@property(nonatomic) BOOL showAllKeys;
@end

@implementation FGUserDefaultsInspectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"NSUserDefaults Inspector";

    [self.tableView registerClass:[FGUserDefaultsInspectorCell class] forCellReuseIdentifier:@"cell"];
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

    [self.tableView reloadData];
}

- (void)_showActionItems:(id)sender {
    NSString *otherButtonTitle = self.showAllKeys ? @"Show only App Domain" : @"Show All";
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Abbrechen" destructiveButtonTitle:@"Delete App's UserDefaults" otherButtonTitles:otherButtonTitle, nil];
    [sheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark table view delegate & data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dictionaryRepresentation.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    id key = self.dictionaryRepresentation.allKeys[(NSUInteger) indexPath.row];
    id value = self.dictionaryRepresentation[key];

    cell.textLabel.text = [self _cleanDescription:[value description]];
    cell.detailTextLabel.text = [self _cleanDescription:[key description]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id key = self.dictionaryRepresentation.allKeys[(NSUInteger) indexPath.row];
    id value = self.dictionaryRepresentation[key];
    FGUserDefaultsEditViewController *editVC = [[FGUserDefaultsEditViewController alloc] initWithKey:key value:value];
    [self.navigationController pushViewController:editVC animated:YES];
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

#pragma mark helper methods

- (NSString*)_cleanDescription:(id)object {
    if(object == nil) {
        return @"(nil)";
    } else {
        NSString *str = [object description];
        NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:nil];
        return [regEx stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, str.length) withTemplate:@" "];
    }
}

@end
