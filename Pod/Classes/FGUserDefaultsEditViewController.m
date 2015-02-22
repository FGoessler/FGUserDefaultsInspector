#import "FGUserDefaultsEditViewController.h"
#import "FGUserDefaultsInspectorCell.h"
#import "FGUserDefaultsFormatter.h"
#import "FGUserDefaultsInspectorEditValueCell.h"


static const float kDefaultCellHeight = 44.0f;
static const float kDatePickerCellHeight = 200.0f;


@interface FGUserDefaultsEditViewController () <FGUserDefaultsEditViewControllerDelegate>
@property(nonatomic, strong) id value;
@property(nonatomic, strong) id key;
@property(nonatomic) NSUInteger index;
@property(nonatomic, strong) FGUserDefaultsInspectorEditValueCell *valueEditCell;
@end

@implementation FGUserDefaultsEditViewController


- (instancetype)initWithKey:(id)key value:(id)value {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self) {
        self.key = key;
        self.value = value;
        self.title = key;
    }
    return self;
}

- (instancetype)initWithIndex:(NSUInteger)index value:(id)value {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self) {
        self.index = index;
        self.value = value;
        self.title = [NSString stringWithFormat:@"[%lu]", (unsigned long)index];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self _displaysArrayValues] || [self _displaysDictionaryValues]) {
        self.value = [self.value mutableCopy];
    }

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"keyCell"];
    [self.tableView registerClass:[FGUserDefaultsInspectorCell class] forCellReuseIdentifier:@"valueCell"];
    [self.tableView registerClass:[FGUserDefaultsInspectorEditValueCell class] forCellReuseIdentifier:@"editValueCell"];

    if(self.navigationController.viewControllers.count == 1) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                               target:self action:@selector(save)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self action:@selector(cancel)];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if([self isMovingFromParentViewController]) {
        if(self.valueEditCell) self.value = self.valueEditCell.value;
        if(self.key) {
            [self.delegate defaultsEditVC:self requestedSaveOf:self.value atKey:self.key];
        } else {
            [self.delegate defaultsEditVC:self requestedSaveOf:self.value atIndex:self.index];
        }
    }
}

#pragma mark user interaction via navigation bar buttons

- (void)save {
    if(self.valueEditCell) self.value = self.valueEditCell.value;
    [self.delegate defaultsEditVC:self requestedSaveOf:self.value atKey:self.key];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark FGUserDefaultsEditViewControllerDelegate

- (void)defaultsEditVC:(FGUserDefaultsEditViewController *)editVC requestedSaveOf:(id)object atKey:(id)key {
    self.value[key] = object;
    [self.tableView reloadData];
}

- (void)defaultsEditVC:(FGUserDefaultsEditViewController *)editVC requestedSaveOf:(id)object atIndex:(NSUInteger)index {
    self.value[index] = object;
    [self.tableView reloadData];
}

#pragma mark table view data source / delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.key ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self _isKeySection:section]) {
        return 1;
    } else {
        if ([self _displaysArrayValues] || [self _displaysDictionaryValues]) {
            return [self.value count];
        } else {
            return 1;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self _isKeySection:section]) {
        return @"Key";
    } else {
        return [self.value respondsToSelector:@selector(count)] && [self.value count] > 1 ? @"Values" : @"Value";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([self _isKeySection:section]) {
        return [FGUserDefaultsFormatter typeStringForObject:self.key];
    } else if(self.value) {
        return [FGUserDefaultsFormatter typeStringForObject:self.value];
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([self _isKeySection:indexPath.section]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"keyCell"];
        cell.textLabel.text = [self.key description];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"valueCell"];
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;

        if ([self _displaysArrayValues]) {
            id value = self.value[(NSUInteger) indexPath.row];
            cell.textLabel.text = [FGUserDefaultsFormatter descriptionForObject:value];
        } else if ([self _displaysDictionaryValues]) {
            NSDictionary *dictionary = self.value;
            id key = dictionary.allKeys[(NSUInteger) indexPath.row];
            id value = dictionary[key];
            cell.textLabel.text = [FGUserDefaultsFormatter descriptionForObject:value];
            cell.detailTextLabel.text = [@"Key: " stringByAppendingString:[FGUserDefaultsFormatter descriptionForObject:key]];
        } else {
            self.valueEditCell = [tableView dequeueReusableCellWithIdentifier:@"editValueCell"];
            self.valueEditCell.value = self.value;
            cell = self.valueEditCell;
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.value isKindOfClass:[NSDate class]] && [self _isValuesSection:indexPath.section]) {
        return kDatePickerCellHeight;
    } else {
        return kDefaultCellHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self _isValuesSection:indexPath.section]) {
        NSUInteger index = (NSUInteger) indexPath.row;
        if ([self _displaysArrayValues]) {
            id value = self.value[index];
            FGUserDefaultsEditViewController *recursiveEditVC = [[FGUserDefaultsEditViewController alloc] initWithIndex:index value:[value copy]];
            recursiveEditVC.delegate = self;
            [self.navigationController pushViewController:recursiveEditVC animated:YES];
        } else if ([self _displaysDictionaryValues]) {
            NSDictionary *dictionary = self.value;
            id key = dictionary.allKeys[index];
            id value = dictionary[key];
            FGUserDefaultsEditViewController *recursiveEditVC = [[FGUserDefaultsEditViewController alloc] initWithKey:[key copy] value:[value copy]];
            recursiveEditVC.delegate = self;
            [self.navigationController pushViewController:recursiveEditVC animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self _isValuesSection:indexPath.section] && ([self _displaysArrayValues] || [self _displaysDictionaryValues]);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger index = (NSUInteger) indexPath.row;
        if ([self _displaysArrayValues]) {
            [self.value removeObjectAtIndex:index];
        } else if ([self _displaysDictionaryValues]) {
            [self.value removeObjectForKey:[self.value allKeys][index]];
        }
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark private helper methods

- (BOOL)_isKeySection:(NSInteger)section {
    return section == 0 && self.key;
}

- (BOOL)_isValuesSection:(NSInteger)section {
    return section == 1 || (section == 0 && !self.key);
}

- (BOOL)_displaysArrayValues {
    return [self.value isKindOfClass:[NSArray class]];
}

- (BOOL)_displaysDictionaryValues {
    return [self.value isKindOfClass:[NSDictionary class]];
}

@end
