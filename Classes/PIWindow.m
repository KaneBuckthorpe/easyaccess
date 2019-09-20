#import "PIWindow.h"

@implementation PIWindow
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

self.windowLevel = 1055;
self.clipsToBounds=YES;
self.backgroundColor=UIColor.clearColor;
self.opaque=NO;
self.layer.cornerRadius=20.0f;
self.layer.masksToBounds=YES;
    return self;
}
- (bool)_shouldCreateContextAsSecure{
        return YES;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView* subview in self.subviews ) {
        if ( [subview hitTest:[self convertPoint:point toView:subview] withEvent:event] != nil ) {
            return YES;
        }
    }
    return NO;
}

@end
