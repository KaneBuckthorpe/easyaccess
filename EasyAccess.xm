#import "EasyAccess.h"
EasyAccessController*easyAccess;
%hook SpringBoard
-(void) applicationDidFinishLaunching:(id) application {
    %orig;
    easyAccess =[EasyAccessController new];
    [easyAccess setup];
    easyAccess.backgroundView.hidden=YES;
}
-(void)frontDisplayDidChange:(id)newDisplay {
    %orig(newDisplay);

    if ([newDisplay isKindOfClass:%c(SBApplication)]){
        NSLog(@"NewDisplayIdentifier:%@", [(SBApplication*)newDisplay bundleIdentifier]);
        
        if ([[(SBApplication*)newDisplay bundleIdentifier] isEqualToString:easyAccess.application.bundleIdentifier]&& easyAccess.isDisplayingApp){
            [easyAccess stopDisplayingApp];
        }
    }
}
%end

///handle activator events

@implementation EAActivator

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName{
    
    if ([listenerName isEqualToString:@"com.easyaccess.show"]){
        [easyAccess showEasyAccess];
    } else if ([listenerName isEqualToString:@"com.easyaccess.hide"]){
        [easyAccess hideEasyAccess];
    } else if ([listenerName isEqualToString:@"com.easyaccess.toggleshowing"]){
        [easyAccess showOrHide];
    }
    [event setHandled:YES];
}

+(void)load {
    LAActivator *activator= [%c(LAActivator) sharedInstance];
    
    [activator registerListener:[self new] forName:@"com.easyaccess.show"];
    
    [activator registerListener:[self new] forName:@"com.easyaccess.hide"];
    
    [activator registerListener:[self new] forName:@"com.easyaccess.toggleshowing"];
}

- (NSArray *)exclusiveAssignmentGroupsForListenerName:(NSString *)listenerName{
    NSArray *groups = @[@"EasyAccess"];
    return groups;
}
@end
