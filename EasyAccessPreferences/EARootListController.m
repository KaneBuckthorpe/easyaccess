#include "EARootListController.h"
#import <Preferences/PSTableCell.h>
#import <objc/runtime.h>


@implementation EARootListController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root"
                                                  target:self];
    }

    return _specifiers;
}
@end

@implementation EACustomisationController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"EACustomisationController"
                                                  target:self];
    }

    return _specifiers;
}
-(void)loadView{
[super loadView];

UIBarButtonItem *toggleEasyAccessButton = [[UIBarButtonItem alloc]  initWithTitle:@"Toggle EA" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEasyAccess)];
	self.navigationItem.rightBarButtonItem=toggleEasyAccessButton;

}
-(void)toggleEasyAccess{
    	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(r, (CFStringRef)@"com.kaneb.easyaccess/showorhide", NULL, NULL, true);
}
@end

@implementation EAActivatorController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"EAActivatorController"
                                                  target:self];
    }

    return _specifiers;
}
@end

@implementation EAInstructionsController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"EAInstructionsController"
                                                  target:self];
    }

    return _specifiers;
}
@end
