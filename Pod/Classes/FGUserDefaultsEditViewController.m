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
        return [self _cleanType:self.key];
    } else if(self.value) {
        return [self _cleanType:self.value];
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
            cell.textLabel.text = [self _cleanDescription:value];
        } else if([self.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = self.value;
            id key = dictionary.allKeys[(NSUInteger) indexPath.row];
            id value = dictionary[key];
            cell.textLabel.text = [self _cleanDescription:value];
            cell.detailTextLabel.text = [self _cleanDescription:key];
        } else {
            cell.textLabel.text = [self _cleanDescription:self.value];
            cell.detailTextLabel.text = nil;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1 || !self.key) {
        if([self.value isKindOfClass:[NSArray class]]) {
            id value = self.value[(NSUInteger) indexPath.row];
            FGUserDefaultsEditViewController *recursiveEditVC = [[FGUserDefaultsEditViewController alloc] initWithKey:nil value:value];
            [self.navigationController pushViewController:recursiveEditVC animated:YES];
        } else if([self.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = self.value;
            id key = dictionary.allKeys[(NSUInteger) indexPath.row];
            id value = dictionary[key];
            FGUserDefaultsEditViewController *recursiveEditVC = [[FGUserDefaultsEditViewController alloc] initWithKey:key value:value];
            [self.navigationController pushViewController:recursiveEditVC animated:YES];
        }
    }
}

- (NSString*)_cleanDescription:(id)object {
    if(object == nil) {
        return @"(nil)";
    } else {
        NSString *str = [object description];
        NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:nil];
        return [regEx stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, str.length) withTemplate:@" "];
    }
}

- (NSString*)_cleanType:(id)object {
    return [@"Type: " stringByAppendingString:[[object class] description]];
}

@end