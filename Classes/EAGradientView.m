#import "EAGradientView.h"

@implementation EAGradientView
static NSUserDefaults *preferences;
- (id)initWithFrame:(CGRect)frame layerStyle:(BOOL)style {
    self = [super initWithFrame:frame];
    self.backgroundColor = UIColor.clearColor;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1;
    self.layer.borderColor = UIColor.blackColor.CGColor;
    self.clipsToBounds = YES;

    if (style) {
        CAGradientLayer *gradient = (CAGradientLayer *)self.layer;
        gradient.startPoint = CGPointZero;
        gradient.endPoint = CGPointMake(1.5, 1.5);
        gradient.colors =
            [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:34.0 / 255.0
                                                           green:211 / 255.0
                                                            blue:198 / 255.0
                                                           alpha:1.0] CGColor],
                                      (id)[[UIColor colorWithRed:145 / 255.0
                                                           green:72.0 / 255.0
                                                            blue:203 / 255.0
                                                           alpha:1.0] CGColor],
                                      nil];
    }
    UIBlurEffect *blurEffect =
        [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView =
        [[UIVisualEffectView alloc] initWithEffect:blurEffect];

    blurEffectView.frame = self.bounds;

    blurEffectView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:blurEffectView];

    self.movePan = [[UIPanGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(moveEasyAccess:)];
    self.movePan.minimumNumberOfTouches = 1;
    self.movePan.maximumNumberOfTouches = 1;
    self.movePan.delegate = self;
    [self addGestureRecognizer:self.movePan];

    self.twoFingerPinch = [[UIPinchGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(scalePlayer:)];
    self.twoFingerPinch.delegate = self;
    [self addGestureRecognizer:self.twoFingerPinch];

    [self.twoFingerPinch requireGestureRecognizerToFail:self.movePan];

    return self;
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (void)setPositionAndScale {
    [self setScale];
    [self setPosition];
    [self checkWithinBounds];
    ////[preferences synchronize];
}
- (void)checkWithinBounds {
    if (!CGRectEqualToRect(
            CGRectIntersection(self.superview.bounds, self.frame),
            self.frame)) {
        [self reset];
    }
}
- (void)reset {
    self.center = CGPointMake(self.superview.bounds.size.width / 2,
                              self.superview.bounds.size.height / 2);

    float newScale =
        (self.superview.bounds.size.width / self.superview.bounds.size.height) -
        0.01;

    CGAffineTransform transform =
        CGAffineTransformMakeScale(newScale, newScale);
    self.transform = transform;
    self.scale = newScale;
}
- (void)disableTouches {
    self.userInteractionEnabled = NO;
    self.twoFingerPinch.enabled = NO;
    self.movePan.enabled = NO;
}
- (void)enableTouches {
    self.userInteractionEnabled = YES;
    self.twoFingerPinch.enabled = YES;
    self.movePan.enabled = YES;
}

- (void)setPosition {
    preferences =
        [[NSUserDefaults alloc] initWithSuiteName:@"com.kaneb.centerpoints"];

    self.center = CGPointFromString([preferences objectForKey:self.centerKey]);

    self.currentCenter =
        CGPointFromString([preferences objectForKey:self.centerKey]);

    if (CGPointEqualToPoint(self.center, CGPointZero) ||
        !CGRectEqualToRect(
            CGRectIntersection(self.superview.bounds, self.frame),
            self.frame)) {
        self.center = CGPointMake(self.superview.bounds.size.width / 2,
                                  self.superview.bounds.size.height / 2);
    }
}

- (void)moveEasyAccess:(UIPanGestureRecognizer *)pan {

    CGPoint translation = [pan translationInView:pan.view.superview];
    CGRect recognizerFrame = pan.view.frame;
    recognizerFrame.origin.x += translation.x;
    recognizerFrame.origin.y += translation.y;

    // Check if UIView is completely inside its superView
    if (CGRectContainsRect(pan.view.superview.bounds, recognizerFrame)) {
        pan.view.frame = recognizerFrame;
    } else {

        // Else check if UIView is vertically and/or horizontally outside of its
        // superView. If yes, then set UIView frame accordingly.
        // This is required so that when user pans rapidly then it provides
        // smooth translation.

        // Check vertically
        if (recognizerFrame.origin.y < pan.view.superview.bounds.origin.y) {
            recognizerFrame.origin.y = 0;
        } else if (recognizerFrame.origin.y + recognizerFrame.size.height >
                   pan.view.superview.bounds.size.height) {
            recognizerFrame.origin.y = pan.view.superview.bounds.size.height -
                                       recognizerFrame.size.height;
        }

        // Check horizantally
        if (recognizerFrame.origin.x < pan.view.superview.bounds.origin.x) {
            recognizerFrame.origin.x = 0;
        } else if (recognizerFrame.origin.x + recognizerFrame.size.width >
                   pan.view.superview.bounds.size.width) {
            recognizerFrame.origin.x = pan.view.superview.bounds.size.width -
                                       recognizerFrame.size.width;
        }
    }

    [preferences setObject:NSStringFromCGPoint(pan.view.center)
                    forKey:self.centerKey];

    // Reset translation so that on next pan recognition
    // we get correct translation value
    [pan setTranslation:CGPointMake(0, 0) inView:pan.view.superview];

    if (pan.state == UIGestureRecognizerStateEnded) {
        [preferences synchronize];
    }
}

- (void)setScale {
    preferences =
        [[NSUserDefaults alloc] initWithSuiteName:@"com.kaneb.centerpoints"];

    CGFloat newScale = [preferences floatForKey:self.scaleKey];

    if (!newScale) {
        newScale = (self.superview.bounds.size.width /
                    self.superview.bounds.size.height) -
                   0.01;
    }

    CGAffineTransform transform =
        CGAffineTransformMakeScale(newScale, newScale);
    self.transform = transform;
    self.scale = newScale;
}

- (void)scalePlayer:(UIPinchGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with
        // different scales
        self.lastGestureScale = gestureRecognizer.scale;
    }

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
        gestureRecognizer.state == UIGestureRecognizerStateChanged){
	        

   CGFloat currentScale = gestureRecognizer.view.transform.d;
   
       CGRect gestureSuperViewBounds = gestureRecognizer.view.superview.bounds;
       CGRect unscaledViewBounds = CGRectMake(0,0,gestureRecognizer.view.frame.size.width/currentScale ,gestureRecognizer.view.frame.size.height/currentScale);
       
    CGFloat newScale =
        (1 - (self.lastGestureScale -
             gestureRecognizer.scale))*currentScale;
             

    // Constants to adjust the max/min values of zoom

    CGFloat maxViewScale =MIN((gestureSuperViewBounds.size.width /
                            unscaledViewBounds.size.width),(gestureSuperViewBounds.size.height/
         unscaledViewBounds.size.height))-0.01f;

    NSLog(@"self.lastGestureScale%f", self.lastGestureScale);
    NSLog(@"gestureRecognizer.scale%f", gestureRecognizer.scale);
 NSLog(@"newScale:%f", newScale);
 
///CGFloat minimumSize=gestureSuperViewBounds.size.width*0.6;   ///width 

    CGFloat minViewScale = maxViewScale*0.6;

    newScale = MIN(newScale, maxViewScale); ///ensure less than or equal to max
    newScale = MAX(newScale, minViewScale); ///ensure more than or equal to min 

 
    dispatch_async(dispatch_get_main_queue(), ^{
      CGAffineTransform transform = CGAffineTransformScale(
          gestureRecognizer.view.transform, newScale/currentScale, newScale/currentScale);
      gestureRecognizer.view.transform = transform;
    });
    
    CGRect gestureViewFrame = gestureRecognizer.view.frame;

    if (gestureViewFrame.origin.y < gestureSuperViewBounds.origin.y) {
        gestureViewFrame.origin.y = 0;
    } else if (gestureViewFrame.origin.y + gestureViewFrame.size.height >
               gestureSuperViewBounds.size.height) {
        gestureViewFrame.origin.y =
            gestureSuperViewBounds.size.height - gestureViewFrame.size.height;
    }

    // Check horizantally
    if (gestureViewFrame.origin.x < gestureSuperViewBounds.origin.x) {
        gestureViewFrame.origin.x = 0;
    } else if (gestureViewFrame.origin.x + gestureViewFrame.size.width >
               gestureSuperViewBounds.size.width) {

        gestureViewFrame.origin.x =
            gestureSuperViewBounds.size.width - gestureViewFrame.size.width;
    }
    gestureRecognizer.view.frame = gestureViewFrame;

    self.lastGestureScale = gestureRecognizer.scale;

    CGFloat xScale = gestureRecognizer.view.transform.a;
    [preferences setFloat:xScale forKey:self.scaleKey];
    [preferences setObject:NSStringFromCGPoint(gestureRecognizer.view.center)
                    forKey:self.centerKey];
}
if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
    [preferences synchronize];
}
}
@end