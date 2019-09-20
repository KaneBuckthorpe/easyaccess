#import "EasyAccessController.h"
#import <KBAppList/KBAppList.h>

int SBSLaunchApplicationWithIdentifier(CFStringRef identifier,
                                       Boolean suspended);

@interface LSApplicationWorkspace : NSObject
+ (id)defaultWorkspace;
- (BOOL)openApplicationWithBundleID:(NSString *)bundleID;
@end

@interface SBAppSwitcherModel : NSObject
+ (id)sharedInstance;
- (id)mainSwitcherDisplayItems;
- (void)_addApplicationToFront:(id)arg1 role:(long long)arg2;
- (id)_displayItemForApplication:(id)arg1;
- (void)addToFront:(id)arg1 role:(long long)arg2;
@end

@interface SBDisplayItem : NSObject
+ (id)displayItemWithType:(NSString *)arg1 displayIdentifier:(id)arg2;
@end

@interface SBAppLayout : NSObject
@property(nonatomic, copy) NSDictionary *rolesToLayoutItemsMap;
@end

@interface SBRecentAppLayouts : NSObject
- (id)_legacyAppLayoutForItem:(id)arg1 layoutRole:(long long)arg2;
@end

@interface SBMainSwitcherViewController : UIViewController {
    
    NSMutableArray *_displayItems;
}
+ (id)sharedInstance;
- (void)_insertDisplayItem:(id)arg1
                   atIndex:(unsigned long long)arg2
                completion:(/*^block*/ id)arg3; /// iOS 10
- (void)_removeCardForDisplayIdentifier:(id)arg1;
- (void)_addAppLayoutToFront:(id)arg1;
@end

@implementation EasyAccessController
int iOSVersion;
static NSUserDefaults *preferences;
- (void)setup {
    
    int regToken;
    
    if (kCFCoreFoundationVersionNumber>1500.00){
        iOSVersion=12;
    } else{
        iOSVersion=11;
    }
    
    notify_register_dispatch("com.kaneb.easyaccess/prefchanged", &regToken,
                             dispatch_get_main_queue(), ^(int token) {
                                 [self loadPreferences];
                                 [self loadBackgroundViews];
                             });
    
    notify_register_dispatch("com.kaneb.easyaccess/showorhide", &regToken,
                             dispatch_get_main_queue(), ^(int token) {
                                 [self showOrHide];
                             });
    [self loadPreferences];
    [self loadWindowWithBase];
    [self loadBackgroundViews];
    self.application = nil;
}
- (void)loadPreferences {
    
    preferences =
    [[NSUserDefaults alloc] initWithSuiteName:@"com.kaneb.easyaccess"];
    self.apps = [preferences objectForKey:@"EASelectedApps"]
    ? [preferences objectForKey:@"EASelectedApps"]
    : [NSArray arrayWithArray:KBAppList.allApps];
    
    self.cellsPerPage = [preferences objectForKey:@"EACellCount"]
    ? [preferences integerForKey:@"EACellCount"]
    : 7;
    
    self.iconSizeMultiplier =
    [preferences objectForKey:@"EACellSizeMultiplier"]
    ? ([preferences floatForKey:@"EACellSizeMultiplier"] / 100)
    : 0.5;
    
    self.dockThickness = [preferences objectForKey:@"EADockThickness"]
    ? [preferences integerForKey:@"EADockThickness"]
    : 70;
    
    self.dockBorderWidth =
    [preferences objectForKey:@"EADockBorderWidth"]
    ? [preferences integerForKey:@"EADockBorderWidth"]
    : 20;
    
    self.dockCornerRadius =
    [preferences objectForKey:@"EADockCornerRadius"]
    ? [preferences integerForKey:@"EADockCornerRadius"]
    : 20;
    
    self.circleIcons = [preferences objectForKey:@"EARoundIcons"]
    ? [preferences boolForKey:@"EARoundIcons"]
    : NO;
    
    self.isVertical = [preferences objectForKey:@"EAVerticalMode"]
    ? [preferences boolForKey:@"EAVerticalMode"]
    : NO;
    
    self.dockGradient = [preferences objectForKey:@"EADockGradient"]
    ? [preferences boolForKey:@"EADockGradient"]
    : YES;
    
    self.windowGradient = [preferences objectForKey:@"EAAppGradient"]
    ? [preferences boolForKey:@"EAAppGradient"]
    : YES;
    
    self.animationSpeed =
    [preferences objectForKey:@"EAAnimationSpeed"]
    ? ([preferences floatForKey:@"EAAnimationSpeed"])
    : 0.3;
}
- (void)loadWindowWithBase {
    self.window = [[PIWindow alloc]
                   initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width,
                                            UIScreen.mainScreen.bounds.size.height)];
    self.window.hidden = NO;
    
    self.baseView = [[EABaseView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:self.baseView];
}
- (void)loadBackgroundViews {
    self.backgroundFrame =
    self.isVertical
    ? CGRectMake(40, UIScreen.mainScreen.bounds.size.height * 0.74,
                 self.dockThickness,
                 UIScreen.mainScreen.bounds.size.width - 80)
    : CGRectMake(40, UIScreen.mainScreen.bounds.size.height * 0.74,
                 UIScreen.mainScreen.bounds.size.width - 80,
                 self.dockThickness);
    
    if (self.backgroundView) {
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
    
    self.backgroundView =
    [[EAGradientView alloc] initWithFrame:self.backgroundFrame
                               layerStyle:self.dockGradient];
    
    self.backgroundView.layer.borderWidth = self.self.dockBorderWidth / 10;
    
    self.backgroundView.centerKey = @"easyAccessCenter";
    self.backgroundView.scaleKey = @"easyAccessScale";
    self.backgroundView.layer.cornerRadius =
    self.dockThickness / (100 / self.dockCornerRadius);
    [self.baseView addSubview:self.backgroundView];
    
    if (self.appBackgroundView) {
        if (self.isDisplayingApp == YES) {
            self.isDisplayingApp = NO;
            [self stopDisplayingApp];
        }
        [self.appBackgroundView removeFromSuperview];
        self.appBackgroundView = nil;
    }
    
    self.appBackgroundView =
    [[EAGradientView alloc] initWithFrame:CGRectZero
                               layerStyle:self.windowGradient];
    self.appBackgroundView.layer.cornerRadius = 20;
    [self.baseView addSubview:self.appBackgroundView];
    [self.backgroundView setPositionAndScale];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(handleDoubleTapGesture:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.appBackgroundView addGestureRecognizer:doubleTapGesture];
    
    [self loadCollectionView];
}
- (void)loadCollectionView {
    if (self.dockCollectionView) {
        [self.dockCollectionView removeFromSuperview];
        self.dockCollectionView = nil;
    }
    
    UICollectionViewFlowLayout *layout =
    [[UICollectionViewFlowLayout alloc] init];
    
    CGRect iconListFrame;
    int numberOfRows;
    
    CGFloat thickness;
    CGFloat length;
    
    if (self.isVertical) {
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        iconListFrame = CGRectMake(0, 15, self.backgroundView.bounds.size.width,
                                   self.backgroundView.bounds.size.height - 30);
        
        thickness = iconListFrame.size.width;
        length = iconListFrame.size.height;
        
    } else {
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        iconListFrame =
        CGRectMake(15, 0, self.backgroundView.bounds.size.width - 30,
                   self.backgroundView.bounds.size.height);
        
        thickness = iconListFrame.size.height;
        length = iconListFrame.size.width;
    }
    
    self.cellSize = thickness * self.iconSizeMultiplier;
    
    numberOfRows = ceil((self.cellsPerPage * self.cellSize) / length);
    
    CGFloat totalSpacing = length - (self.cellsPerPage * self.cellSize);
    
    self.spacing = (totalSpacing / (self.cellsPerPage));
    
    layout.itemSize = CGSizeMake(self.cellSize, self.cellSize);
    
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = self.spacing;
    
    self.dockCollectionView =
    [[UICollectionView alloc] initWithFrame:iconListFrame
                       collectionViewLayout:layout];
    
    self.dockCollectionView.pagingEnabled = YES;
    self.dockCollectionView.backgroundColor = UIColor.clearColor;
    
    [self.dockCollectionView registerClass:[EACell class]
                forCellWithReuseIdentifier:@"EACell"];
    
    self.dockCollectionView.showsHorizontalScrollIndicator = NO;
    self.dockCollectionView.showsVerticalScrollIndicator = NO;
    
    self.doubleTap = [UITapGestureRecognizer new];
    self.doubleTap.numberOfTapsRequired = 2;
    [self.doubleTap addTarget:self
                       action:@selector(collectionViewDoubleTapped:)];
    self.doubleTap.delegate = self;
    [self.dockCollectionView addGestureRecognizer:self.doubleTap];
    
    [self.doubleTap requireGestureRecognizerToFail:self.backgroundView.movePan];
    
    self.tap = [UITapGestureRecognizer new];
    self.tap.numberOfTapsRequired = 1;
    [self.tap addTarget:self action:@selector(collectionViewTapped:)];
    self.tap.delegate = self;
    [self.dockCollectionView addGestureRecognizer:self.tap];
    [self.tap requireGestureRecognizerToFail:self.backgroundView.movePan];
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    
    for (UIGestureRecognizer *aRecognizer in
         [self.dockCollectionView gestureRecognizers]) {
        
        if (![aRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            [aRecognizer requireGestureRecognizerToFail:self.backgroundView
             .twoFingerPinch];
        }
        
        if ([aRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self.tap requireGestureRecognizerToFail:aRecognizer];
        }
        if ([aRecognizer isKindOfClass:[UITapGestureRecognizer class]] &&
            (aRecognizer != self.tap)) {
            [aRecognizer
             requireGestureRecognizerToFail:self.backgroundView.movePan];
        }
    }
    
    self.dockCollectionView.dataSource = self;
    self.dockCollectionView.delegate = self;
    
    [self.backgroundView addSubview:self.dockCollectionView];
}

/// UICollectionView Delegates
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.apps.count ? self.apps.count : 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EACell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"EACell"
                                              forIndexPath:indexPath];
    
    int count = self.apps.count;
    if (count == 0) {
        cell.appImageView.image = nil;
    } else {
        cell.bundleID =
        [[self.apps objectAtIndex:indexPath.row] objectForKey:@"bundleID"];
        CGFloat cornerRadius =
        self.circleIcons ? (cell.appImageView.frame.size.height / 2) : 0;
        
        [cell.appImageView
         setRoundedCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight |
         UIRectCornerTopLeft | UIRectCornerTopRight
         withRadius:cornerRadius];
        
        cell.appImageView.image = [UIImage
                                   _applicationIconImageForBundleIdentifier:cell.bundleID
                                   format:1
                                   scale:UIScreen.mainScreen.scale];
    }
    
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView {
    
    return 1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.cellSize, self.cellSize);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:
(UICollectionViewFlowLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    return self.isVertical
    ? UIEdgeInsetsMake(
                       self.spacing / 2,
                       (collectionView.frame.size.width - self.cellSize) / 2,
                       self.spacing / 2,
                       (collectionView.frame.size.width - self.cellSize) / 2)
    : UIEdgeInsetsMake(
                       (collectionView.frame.size.height - self.cellSize) / 2,
                       self.spacing / 2,
                       (collectionView.frame.size.height - self.cellSize) / 2,
                       self.spacing / 2);
}
- (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)collectionViewTapped:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint p = [sender locationInView:self.dockCollectionView];
        
        NSIndexPath *indexPath =
        [self.dockCollectionView indexPathForItemAtPoint:p];
        if (indexPath == nil) {
            
        } else {
            // get the cell at indexPath
            EACell *cell = (EACell *)[self.dockCollectionView
                                      cellForItemAtIndexPath:indexPath];
            if (![[objc_getClass("SBApplicationController") sharedInstance]
                  applicationWithBundleIdentifier:cell.bundleID]) {
                
                NSLog(@"madeIt");
                NSMutableArray *newAppList = [self.apps mutableCopy];
                
                [newAppList removeObjectAtIndex:indexPath.row];
                
                preferences = [[NSUserDefaults alloc]
                               initWithSuiteName:@"com.kaneb.easyaccess"];
                [preferences setObject:newAppList forKey:@"EASelectedApps"];
                self.apps = [NSArray arrayWithArray:newAppList];
                [self.dockCollectionView reloadData];
            } else {
                [self toggleApp:cell.bundleID];
            }
        }
    }
}

- (void)collectionViewDoubleTapped:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint p = [sender locationInView:self.dockCollectionView];
        
        NSIndexPath *indexPath =
        [self.dockCollectionView indexPathForItemAtPoint:p];
        if (indexPath == nil) {
            
        } else {
            // get the cell at indexPath
            EACell *cell = (EACell *)[self.dockCollectionView
                                      cellForItemAtIndexPath:indexPath];
            if (![[objc_getClass("SBApplicationController") sharedInstance]
                  applicationWithBundleIdentifier:cell.bundleID]) {
                
                NSMutableArray *newAppList = [self.apps mutableCopy];
                
                [newAppList removeObjectAtIndex:indexPath.row];
                
                preferences = [[NSUserDefaults alloc]
                               initWithSuiteName:@"com.kaneb.easyaccess"];
                [preferences setObject:newAppList forKey:@"EASelectedApps"];
                self.apps = [NSArray arrayWithArray:newAppList];
                [self.dockCollectionView reloadData];
            } else {
                if (!([cell.bundleID
                       isEqualToString:self.application.bundleIdentifier] &&
                      self.isDisplayingApp)) {
                    dispatch_async(
                                   dispatch_get_global_queue(
                                                             DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                   ^(void) {
                                       [[objc_getClass("LSApplicationWorkspace")
                                         defaultWorkspace]
                                        openApplicationWithBundleID:cell.bundleID];
                                   });
                }
            }
        }
    }
}

/// hosting stuffs
- (void)toggleApp:(NSString *)bundleID {
    
    if (!self.isDisplayingApp) {
        self.application = [[objc_getClass("SBApplicationController")
                             sharedInstance] applicationWithBundleIdentifier:bundleID];
    }
    
    if (!self.application.processState) {
        [self addAppToSwitcher:bundleID];
    } else if (self.application !=
               [(SpringBoard *)[objc_getClass("SpringBoard") sharedApplication]
                _accessibilityTopDisplay]) {
                   [self toggleApp];
               }
}

- (void)addAppToSwitcher:(NSString *)bundleID {
    BOOL iOS11AndPlus = kCFCoreFoundationVersionNumber > 1400;
    
    /// Thanks @SparkDev_
    // Spawn the process on a background thread to avoid locking up
    
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                       int r = SBSLaunchApplicationWithIdentifier(
                                                                  (__bridge CFStringRef)bundleID, TRUE);
                       
                       // Result code 0 = success!
                       if (r == 0) {
                           
                           // Add it to the switcher (We should do this on the main thread)
                           dispatch_async(dispatch_get_main_queue(), ^{
                               SBDisplayItem *item = [objc_getClass("SBDisplayItem")
                                                      displayItemWithType:@"App"
                                                      displayIdentifier:bundleID];
                               
                               if (iOS11AndPlus) {
                                   // get SBAppLayout from SBDisplayItem
                                   SBAppLayout *applayout =
                                   [[objc_getClass("SBRecentAppLayouts") sharedInstance]
                                    _legacyAppLayoutForItem:item
                                    layoutRole:1];
                                   [[objc_getClass("SBMainSwitcherViewController")
                                     sharedInstance] _addAppLayoutToFront:applayout];
                               } else {
                                   [[objc_getClass("SBAppSwitcherModel") sharedInstance]
                                    addToFront:item
                                    role:2];
                               }
                           });
                           
                       } else {
                           dispatch_async(
                                          dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                          ^(void) {
                                              [[objc_getClass("LSApplicationWorkspace") defaultWorkspace]
                                               openApplicationWithBundleID:bundleID];
                                          });
                       }
                       // And this is how we would remove the app if we wanted to...
                       /*
                        dispatch_async(dispatch_get_main_queue(), ^{
                        [[objc_getClass("SBMainSwitcherViewController")
                        sharedInstance] _removeCardForDisplayIdentifier: bundleID];
                        });
                        */
                   });
}

- (void)toggleApp {
    //// disable multiple taps + scaling bugs
    
    // dock
    [self.backgroundView disableTouches];
    
    // app Window
    [self.appBackgroundView disableTouches];
    
    if (!self.isDisplayingApp) {
        
        ////check orientation
        
        int appOrientation =
        [self appOrientationForBundleID:self.application.bundleIdentifier];
        
        NSLog(@"appOrientation %d",appOrientation);
        
        if ((appOrientation == 3) || appOrientation == 4) {
            self.appBackgroundView.centerKey = @"easylandscapecenter";
            self.appBackgroundView.scaleKey = @"easylandscapescale";
        } else {
            self.appBackgroundView.centerKey = @"easyportraitcenter";
            self.appBackgroundView.scaleKey = @"easyportraitscale";
        }
        
        /// Setup/open App Display
        
        /// setup AppView
        self.sceneHostManager = [[self.application mainScene] hostManager];
        
        self.hostView =
        [self.sceneHostManager hostViewForRequester:@"com.kaneb.easyaccess"
                                enableAndOrderFront:true];
        /// allow app background use
        [self setApp:self.application backgrounded:FALSE];
        
        // self.hostView.backgroundColor=UIColor.clearColor;
        /// self.hostView.clipsToBounds=NO;
        
        //// setup apps movable backgroundView
        
        self.appBackgroundView.hidden = NO;
        
        self.hostView.backgroundColor = UIColor.clearColor;
        CGRect appBackgroundFrame;
        
        if (iOSVersion >= 12){
            appBackgroundFrame = CGRectMake(0, 0, self.hostView.hostContainerView.bounds.size.width,
                       self.hostView.hostContainerView.bounds.size.height + 40);
        } else {
            appBackgroundFrame =
            CGRectMake(0, 0, self.hostView.bounds.size.width,
                       self.hostView.bounds.size.height + 40);
        }
        self.appBackgroundView.frame = appBackgroundFrame;
        [self.appBackgroundView addSubview:self.hostView];
        self.appBackgroundView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        self.isDisplayingApp = YES;
        
        [UIView animateWithDuration: self.animationSpeed
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self.baseView bringSubviewToFront: self.backgroundView];
                             
                             [self.appBackgroundView setPositionAndScale];
                             
                             self.hostView.transform = CGAffineTransformIdentity;
                             
                             self.hostView.frame = self.hostView.bounds;
                         }
                         completion:^(BOOL finished) {
                             [self.appBackgroundView setPosition];
                             [self.backgroundView enableTouches];
                             [self.appBackgroundView enableTouches];
                             
                             [self setApp:self.application backgrounded:FALSE];
                         }];
        
    } else {
        /// App needs hiding
        
        [self stopDisplayingApp];
    }
}

- (void)stopDisplayingApp {
    [UIView animateWithDuration: self.animationSpeed
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.appBackgroundView.transform =
                         CGAffineTransformMakeScale(0.1, 0.1);
                         self.appBackgroundView.center = self.backgroundView.center;
                     }
                     completion:^(BOOL finished) {
                         [self.backgroundView enableTouches];
                         [self.appBackgroundView enableTouches];
                         self.appBackgroundView.hidden = YES;
                         self.appBackgroundView.transform = CGAffineTransformIdentity;
                         
                         [self.sceneHostManager
                          disableHostingForRequester:@"com.kaneb.easyaccess"];
                     }];
    
    if ([(SpringBoard *)[objc_getClass("SpringBoard") sharedApplication]
         _accessibilityTopDisplay] == self.application) {
        [self setApp:self.application backgrounded:FALSE];
        
    } else {
        
        [self setApp:self.application backgrounded:TRUE];
    }
    self.isDisplayingApp = NO;
}

- (void)setApp:(SBApplication *)application backgrounded:(BOOL)backgrounded {
    
    FBSceneManager *sceneManager = [FBSceneManager sharedInstance];
    FBScene *scene =
    [sceneManager sceneWithIdentifier:application.bundleIdentifier];
    FBSSceneSettings *settings = [scene settings];
    
    id<FBSceneClientProvider> clientProvider = [scene clientProvider];
    id<FBSceneClient> client = [scene client];
    
    FBSMutableSceneSettings *mutableSettings = [settings mutableCopy];
    
    mutableSettings.backgrounded = backgrounded;
    FBSSceneSettingsDiff *settingsDiff =
    [FBSSceneSettingsDiff diffFromSettings:settings
                                toSettings:mutableSettings];
    
    [clientProvider beginTransaction];
    [client host:scene
didUpdateSettings:mutableSettings
        withDiff:settingsDiff
transitionContext:nil
      completion:nil];
    [settings setValue:[NSNumber numberWithBool:backgrounded]
                forKey:@"_backgrounded"];
    [clientProvider endTransaction];
}

- (int)appOrientationForBundleID:(NSString *)bundleID {
    FBSceneManager *sceneManager = [FBSceneManager sharedInstance];
    FBScene *scene = [sceneManager sceneWithIdentifier:bundleID];
    
    FBSSceneClientSettings *clientSettings = [scene clientSettings];
    
    int appOrientation = clientSettings.interfaceOrientation;
    
    /// 3 or 4 is landscape. 1 is portrait
    
    return appOrientation;
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        self.backgroundView.hidden = !self.backgroundView.hidden;
    }
}

- (void)hideEasyAccess {
    if (self.isDisplayingApp) {
        [self stopDisplayingApp];
    }
    self.baseView.hidden = YES;
}

- (void)showEasyAccess {
    self.backgroundView.hidden = NO;
    self.baseView.hidden = NO;
}

- (void)showOrHide {
    if (self.baseView.hidden) {
        [self showEasyAccess];
    } else {
        [self hideEasyAccess];
    }
}
/// Gesture Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldBeRequiredToFailByGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer {
    
    return NO;
}
@end

@implementation UIView (custom)

- (UIView *)setRoundedCorners:(UIRectCorner)corners withRadius:(CGFloat)radius {
    UIBezierPath *maskPath =
    [UIBezierPath bezierPathWithRoundedRect:self.bounds
                          byRoundingCorners:corners
                                cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = self.bounds;
    
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
    
    return self;
}
@end
