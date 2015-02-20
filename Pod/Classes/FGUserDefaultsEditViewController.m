#import "FGUserDefaultsEditViewController.h"
#import "FGUserDefaultsInspectorCell.h"


@interface FGUserDefaultsEditViewController ()
@property(nonatomic, strong) id value;
@property(nonatomic, strong) id key;
@end

@implementation FGUserDefaultsEditViewController


- (instancetype)initWithKey:(id)key value:(id)value {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self) {
        self.key = key;
        self.value = value;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"keyCell"];
    [self.tableView registerClass:[FGUserDefaultsInspectorCell class] forCellReuseIdentifier:@"valueCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
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
    return @[@"Key", @"Value(s)"][(NSUInteger) section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 0) {
        return [@"Type: " stringByAppendingString:[[self.key class] description]];
    } else {
        return [@"Type: " stringByAppendingString:[[self.value class] description]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if(indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"keyCell"];
        cell.textLabel.text = [self.key description];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"valueCell"];

        if([self.value isKindOfClass:[NSArray class]]) {
            id value = self.value[(NSUInteger) indexPath.row];
            cell.textLabel.text = [[value description] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            cell.detailTextLabel.text = [@"Type: " stringByAppendingString:[[value class] description]];
        } else if([self.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = self.value;
            id key = dictionary.allKeys[(NSUInteger) indexPath.row];
            id value = dictionary[key];
            cell.textLabel.text = [[value description] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            cell.detailTextLabel.text = [[key description] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];;
        } else {
            cell.textLabel.text = [[self.value description] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            cell.detailTextLabel.text = nil;
        }
    }

    return cell;
}

@end