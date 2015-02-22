#import "FGUserDefaultsEditViewController.h"
#import "FGUserDefaultsInspectorCell.h"
#import "FGUserDefaultsFormatter.h"
#import "FGUserDefaultsInspectorEditValueCell.h"


static const float kDefaultCellHeight = 44.0f;
static const float kDatePickerCellHeight = 200.0f;
static const NSInteger kNumberOfPossibleTypes = 5;  // NSString, NSNumber, BOOL, NSArray, NSDictionary

typedef NS_ENUM(NSInteger, FGUserDefaultsEditVCMode) {
    FGUserDefaultsEditVCKeyValueMode,
    FGUserDefaultsEditVCIndexValueMode,
    FGUserDefaultsEditVCCreateKeyValueMode,
    FGUserDefaultsEditVCCreateValueMode
};


@interface FGUserDefaultsEditViewController () <FGUserDefaultsEditViewControllerDelegate>
@property(nonatomic) FGUserDefaultsEditVCMode mode;
@property(nonatomic, strong) id value;
@property(nonatomic, strong) id key;
@property(nonatomic) NSUInteger index;
@property(nonatomic) NSInteger selectedTypeIndex;
@property(nonatomic, strong) FGUserDefaultsInspectorEditValueCell *valueEditCell;
@property(nonatomic, strong) FGUserDefaultsInspectorEditValueCell *keyEditCell;
@end

@implementation FGUserDefaultsEditViewController


- (instancetype)initWithKey:(id)key value:(id)value {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.key = key;
        self.value = value;
        self.title = key;
        self.mode = FGUserDefaultsEditVCKeyValueMode;
    }
    return self;
}

- (instancetype)initWithIndex:(NSUInteger)index value:(id)value {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.index = index;
        self.value = value;
        self.title = [NSString stringWithFormat:@"[%lu]", (unsigned long) index];
        self.mode = FGUserDefaultsEditVCIndexValueMode;
    }
    return self;
}

- (instancetype)initToCreateNewKeyValuePair {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.key = @"newKey";
        self.value = @"";
        self.title = @"New key:value";
        self.mode = FGUserDefaultsEditVCCreateKeyValueMode;
    }
    return self;
}

- (instancetype)initToCreateNewValue {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.value = @"";
        self.title = @"New value";
        self.mode = FGUserDefaultsEditVCCreateValueMode;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    if ([self _displaysArrayValues] || [self _displaysDictionaryValues]) {
        self.value = [self.value mutableCopy];
    }

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"keyCell"];
    [self.tableView registerClass:[FGUserDefaultsInspectorEditValueCell class] forCellReuseIdentifier:@"editKeyCell"];
    [self.tableView registerClass:[FGUserDefaultsInspectorCell class] forCellReuseIdentifier:@"valueCell"];
    [self.tableView registerClass:[FGUserDefaultsInspectorEditValueCell class] forCellReuseIdentifier:@"editValueCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newValueButtonCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"typeCell"];

    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                               target:self action:@selector(saveAndDismiss)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self action:@selector(cancel)];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if ([self isMovingFromParentViewController]) {
        [self save];
    }
}

- (void)save {
    if (self.valueEditCell) self.value = self.valueEditCell.value;
    if (self.keyEditCell) self.key = self.keyEditCell.value;
    if (self.mode == FGUserDefaultsEditVCKeyValueMode || self.mode == FGUserDefaultsEditVCCreateKeyValueMode) {
        [self.delegate defaultsEditVC:self requestedSaveOf:self.value atKey:self.key];
    } else if (self.mode == FGUserDefaultsEditVCCreateValueMode) {
        if ([self.delegate respondsToSelector:@selector(defaultsEditVC:requestedSaveOf:)]) {
            [self.delegate defaultsEditVC:self requestedSaveOf:self.value];
        }
    } else if (self.mode == FGUserDefaultsEditVCIndexValueMode) {
        if ([self.delegate respondsToSelector:@selector(defaultsEditVC:requestedSaveOf:atIndex:)]) {
            [self.delegate defaultsEditVC:self requestedSaveOf:self.value atIndex:self.index];
        }
    }
}

#pragma mark user interaction via navigation bar buttons

- (void)saveAndDismiss {
    [self save];
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

- (void)defaultsEditVC:(FGUserDefaultsEditViewController *)editVC requestedSaveOf:(id)object {
    [self.value addObject:object];
    [self.tableView reloadData];
}

#pragma mark table view data source / delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (self.mode) {
        case FGUserDefaultsEditVCKeyValueMode:
            return 2;
        case FGUserDefaultsEditVCIndexValueMode:
            return 1;
        case FGUserDefaultsEditVCCreateKeyValueMode:
            return 3;
        case FGUserDefaultsEditVCCreateValueMode:
            return 2;
        default:
            return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self _isKeySection:section]) {
        return 1;
    } else if ([self _isValuesSection:section]) {
        if ([self _displaysArrayValues] || [self _displaysDictionaryValues]) {
            return [self.value count] + 1;
        } else {
            return 1;
        }
    } else {
        return kNumberOfPossibleTypes;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self _isKeySection:section]) {
        return @"Key";
    } else if ([self _isValuesSection:section]) {
        return [self.value respondsToSelector:@selector(count)] && [self.value count] > 1 ? @"Values" : @"Value";
    } else {
        return @"Type of new value";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([self _isKeySection:section]) {
        return [FGUserDefaultsFormatter typeStringForObject:self.key];
    } else if ([self _isValuesSection:section] && self.value) {
        return [FGUserDefaultsFormatter typeStringForObject:self.value];
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([self _isKeySection:indexPath.section]) {
        if (self.mode == FGUserDefaultsEditVCCreateKeyValueMode) {
            self.keyEditCell = [tableView dequeueReusableCellWithIdentifier:@"editKeyCell"];
            self.keyEditCell.value = self.key;
            cell = self.keyEditCell;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"keyCell"];
            cell.textLabel.text = [self.key description];
        }
    } else if ([self _isValuesSection:indexPath.section]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"valueCell"];
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;

        if (([self _displaysArrayValues] || [self _displaysDictionaryValues]) && ![self _isLastCellInSection:indexPath]) {
            if ([self _displaysArrayValues]) {
                id value = self.value[(NSUInteger) indexPath.row];
                cell.textLabel.text = [FGUserDefaultsFormatter descriptionForObject:value];
            } else if ([self _displaysDictionaryValues]) {
                NSDictionary *dictionary = self.value;
                id key = dictionary.allKeys[(NSUInteger) indexPath.row];
                id value = dictionary[key];
                cell.textLabel.text = [FGUserDefaultsFormatter descriptionForObject:value];
                cell.detailTextLabel.text = [@"Key: " stringByAppendingString:[FGUserDefaultsFormatter descriptionForObject:key]];
            }
        } else if (([self _displaysArrayValues] || [self _displaysDictionaryValues]) && [self _isLastCellInSection:indexPath]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"newValueButtonCell"];
            cell.textLabel.text = @"+ create new entry";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        } else {
            self.valueEditCell = [tableView dequeueReusableCellWithIdentifier:@"editValueCell"];
            self.valueEditCell.value = self.value;
            cell = self.valueEditCell;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"typeCell"];
        NSString *typeName = @[@"NSString", @"NSNumber", @"Boolean", @"NSArray", @"NSDictionary"][(NSUInteger) indexPath.row];
        cell.textLabel.text = typeName;
        cell.accessoryType = self.selectedTypeIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
    if ([self _isValuesSection:indexPath.section] && ![self _isLastCellInSection:indexPath]) {
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
    } else if ([self _isValuesSection:indexPath.section] && [self _isLastCellInSection:indexPath]) {
        FGUserDefaultsEditViewController *recursiveEditVC;
        if ([self _displaysArrayValues]) {
            recursiveEditVC = [[FGUserDefaultsEditViewController alloc] initToCreateNewValue];
        } else if ([self _displaysDictionaryValues]) {
            recursiveEditVC = [[FGUserDefaultsEditViewController alloc] initToCreateNewKeyValuePair];
        }
        recursiveEditVC.delegate = self;
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:recursiveEditVC];
        [self presentViewController:navVC animated:YES completion:nil];
    } else if ([self _isTypeSection:indexPath.section]) {
        if (self.selectedTypeIndex != indexPath.row) {
            self.selectedTypeIndex = indexPath.row;
            self.valueEditCell = nil;
            if (self.keyEditCell) self.key = self.keyEditCell.value;
            self.value = @[@"", @1, @YES, [@[] mutableCopy], [@{} mutableCopy]][(NSUInteger) self.selectedTypeIndex];
            [tableView reloadData];
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
    return (section == 1 && (self.mode == FGUserDefaultsEditVCKeyValueMode || self.mode == FGUserDefaultsEditVCCreateKeyValueMode)) ||
            (section == 0 && (self.mode == FGUserDefaultsEditVCIndexValueMode || self.mode == FGUserDefaultsEditVCCreateValueMode));
}

- (BOOL)_isTypeSection:(NSInteger)section {
    return section == 2 || (section == 1 && self.mode == FGUserDefaultsEditVCCreateValueMode);
}

- (BOOL)_isLastCellInSection:(NSIndexPath *)indexPath {
    return [self.tableView numberOfRowsInSection:indexPath.section] == indexPath.row + 1;
}

- (BOOL)_displaysArrayValues {
    return [self.value isKindOfClass:[NSArray class]];
}

- (BOOL)_displaysDictionaryValues {
    return [self.value isKindOfClass:[NSDictionary class]];
}

@end
