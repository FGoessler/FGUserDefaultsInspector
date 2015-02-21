#import "FGUserDefaultsEditViewController.h"
#import "FGUserDefaultsInspectorCell.h"
#import "FGUserDefaultsFormatter.h"
#import "FGUserDefaultsInspectorEditValueCell.h"


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

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"keyCell"];
    [self.tableView registerClass:[FGUserDefaultsInspectorCell class] forCellReuseIdentifier:@"valueCell"];
    [self.tableView registerClass:[FGUserDefaultsInspectorEditValueCell class] forCellReuseIdentifier:@"editValueCell"];

    if(self.navigationController.viewControllers.count == 1) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
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

- (void)save {
    if(self.valueEditCell) self.value = self.valueEditCell.value;
    [self.delegate defaultsEditVC:self requestedSaveOf:self.value atKey:self.key];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)defaultsEditVC:(FGUserDefaultsEditViewController *)editVC requestedSaveOf:(id)object atKey:(id)key {
    self.value = [self.value mutableCopy];
    self.value[key] = object;
    [self.tableView reloadData];
}

- (void)defaultsEditVC:(FGUserDefaultsEditViewController *)editVC requestedSaveOf:(id)object atIndex:(NSUInteger)index {
    self.value = [self.value mutableCopy];
    self.value[index] = object;
    [self.tableView reloadData];
}

#pragma mark table view data source / delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.key ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0 && self.key) {
        return 1;
    } else {
        if([self.value isKindOfClass:[NSArray class]] || [self.value isKindOfClass:[NSDictionary class]]) {
            return [self.value count];
        } else {
            return 1;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0 && self.key) {
        return @"Key";
    } else {
        return @"Value(s)";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 0 && self.key) {
        return [FGUserDefaultsFormatter typeStringForObject:self.key];
    } else if(self.value) {
        return [FGUserDefaultsFormatter typeStringForObject:self.value];
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if(indexPath.section == 0 && self.key) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"keyCell"];
        cell.textLabel.text = [self.key description];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"valueCell"];

        if([self.value isKindOfClass:[NSArray class]]) {
            id value = self.value[(NSUInteger) indexPath.row];
            cell.textLabel.text = [FGUserDefaultsFormatter descriptionForObject:value];
            cell.detailTextLabel.text = nil;
        } else if([self.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = self.value;
            id key = dictionary.allKeys[(NSUInteger) indexPath.row];
            id value = dictionary[key];
            cell.textLabel.text = [FGUserDefaultsFormatter descriptionForObject:value];
            cell.detailTextLabel.text = [@"Key: " stringByAppendingString:[FGUserDefaultsFormatter descriptionForObject:key]];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"editValueCell"];
            ((FGUserDefaultsInspectorEditValueCell *)cell).value = self.value;
            self.valueEditCell = (FGUserDefaultsInspectorEditValueCell *) cell;
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.value isKindOfClass:[NSDate class]] && (indexPath.section == 1 || !self.key)) {
        return 200.0f;
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1 || !self.key) {
        NSUInteger index = (NSUInteger) indexPath.row;
        if([self.value isKindOfClass:[NSArray class]]) {
            id value = self.value[index];
            FGUserDefaultsEditViewController *recursiveEditVC = [[FGUserDefaultsEditViewController alloc] initWithIndex:index value:[value copy]];
            recursiveEditVC.delegate = self;
            [self.navigationController pushViewController:recursiveEditVC animated:YES];
        } else if([self.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = self.value;
            id key = dictionary.allKeys[index];
            id value = dictionary[key];
            FGUserDefaultsEditViewController *recursiveEditVC = [[FGUserDefaultsEditViewController alloc] initWithKey:[key copy] value:[value copy]];
            recursiveEditVC.delegate = self;
            [self.navigationController pushViewController:recursiveEditVC animated:YES];
        }
    }
}

@end
