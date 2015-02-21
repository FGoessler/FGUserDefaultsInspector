#import "FGUserDefaultsInspectorEditValueCell.h"
#import "FGUserDefaultsFormatter.h"


@interface FGUserDefaultsInspectorEditValueCell ()
@property(nonatomic, strong) UISwitch *valueSwitch;
@property(nonatomic, strong) UIDatePicker *datePicker;
@property(nonatomic, strong) UITextField *textField;
@end

@implementation FGUserDefaultsInspectorEditValueCell {
    id _value;
}

- (void)setValue:(id)value {
    _value = value;
    [self _updateCellLayout];
}

- (id)value {
    if([[[_value class] description] isEqualToString:@"__NSCFBoolean"]) {
        return @(self.valueSwitch.on);
    } else if([_value isKindOfClass:[NSDate class]]) {
        return self.datePicker.date;
    } else if([_value isKindOfClass:[NSString class]]) {
        return self.textField.text;
    } else if([_value isKindOfClass:[NSNumber class]]) {
        return @([self.textField.text doubleValue]);
    } else {
        return _value;
    }
}

- (void)_updateCellLayout {
    /* reset */
    self.textLabel.text = nil;
    [self.valueSwitch removeFromSuperview];
    [self.datePicker removeFromSuperview];
    [self.textField removeFromSuperview];
    self.valueSwitch = nil;
    self.datePicker = nil;
    self.textField = nil;

    /* config */
    if([[[_value class] description] isEqualToString:@"__NSCFBoolean"]) {
        self.valueSwitch = [[UISwitch alloc] init];
        self.valueSwitch.on = [_value boolValue];
        [self.contentView addSubview:self.valueSwitch];
        self.valueSwitch.frame = CGRectMake(15, 6, self.valueSwitch.bounds.size.width, self.valueSwitch.bounds.size.height);
    } else if([_value isKindOfClass:[NSDate class]]) {
        self.datePicker = [[UIDatePicker alloc] init];
        self.datePicker.date = _value;
        [self.contentView addSubview:self.datePicker];
    } else if([_value isKindOfClass:[NSString class]]) {
        self.textField = [[UITextField alloc] init];
        self.textField.text = _value;
        [self.contentView addSubview:self.textField];
        self.textField.frame = CGRectMake(15, 0, self.contentView.frame.size.width - 30, self.contentView.frame.size.height);
    } else if([_value isKindOfClass:[NSNumber class]]) {
        self.textField = [[UITextField alloc] init];
        self.textField.text = [_value stringValue];
        [self.contentView addSubview:self.textField];
        self.textField.frame = CGRectMake(15, 0, self.contentView.frame.size.width - 30, self.contentView.frame.size.height);
    } else {
        self.textLabel.text = [FGUserDefaultsFormatter descriptionForObject:_value];
    }
}

@end
