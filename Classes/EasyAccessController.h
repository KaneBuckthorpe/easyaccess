#import <notify.h>
#import <objc/runtime.h>
#import <SpringBoard/SpringBoard.h>
#import <FrontBoard/FBSceneHostWrapperView.h>


#import "PIWindow.h"
#import "EABaseView.h"
#import "EACell.h"
#import "EAGradientView.h"
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>
#import <FrontBoard/FBScene.h>
#import <FrontBoard/FBSceneClientProvider.h>
#import <FrontBoard/FBSceneHostManager.h>
#import <FrontBoard/FBSceneManager.h>
#import <FrontBoardServices/FBSMutableSceneSettings.h>
#import <FrontBoard/FBSceneHostManager.h>
#import <FrontBoard/FBProcessState.h>
#import <FrontBoardServices/FBSSystemService.h>

@interface SBApplication()
-(id)processState;
@end

@interface FBSSceneClientSettings:NSObject
@property (nonatomic,readonly) long long interfaceOrientation; 
@end

@interface FBSceneHostWrapperView()
@property (nonatomic,retain) UIView * hostContainerView;
@end

@interface FBScene()
@property (nonatomic,retain,readonly) FBSceneHostManager * hostManager;   
@property (nonatomic,retain,readonly) FBSSceneClientSettings * clientSettings;  
-(id)uiSettings;
@end

@interface FBSSceneSettingsDiff : NSObject
+(id)diffFromSettings:(id)arg1 toSettings:(id)arg2 ;
@end

@interface EasyAccessController :NSObject <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
@property (nonatomic, retain) PIWindow *window;
@property (nonatomic, retain) EABaseView *baseView;
@property (nonatomic, retain) EAGradientView *backgroundView;
@property (nonatomic, retain) EAGradientView *appBackgroundView;
@property (nonatomic, retain)UICollectionView *dockCollectionView;
@property (nonatomic, retain) FBSceneHostManager *sceneHostManager;
@property (nonatomic, retain) FBSceneHostWrapperView *hostView;
@property (nonatomic, retain) SBApplication *application;
@property (nonatomic, retain) UITapGestureRecognizer *tap;
@property (nonatomic, retain) UITapGestureRecognizer *doubleTap;
@property (nonatomic, assign) BOOL isDisplayingApp;
@property (nonatomic, strong) NSArray*apps;
@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign) CGFloat cellSize;
@property (nonatomic, assign) CGFloat iconSizeMultiplier;
@property (nonatomic, assign) int cellsPerPage;
@property (nonatomic, assign) int dockThickness;
@property (nonatomic, assign) int dockBorderWidth;
@property (nonatomic, assign) CGFloat dockCornerRadius;
@property (nonatomic, assign) CGRect backgroundFrame;
@property (nonatomic, assign) BOOL circleIcons;
@property (nonatomic, assign) BOOL isVertical;
@property (nonatomic, assign) BOOL dockGradient;
@property (nonatomic, assign) BOOL windowGradient;
@property (nonatomic, assign) CGFloat animationSpeed;
-(void)setup;
-(void)toggleApp:(NSString*)bundleID;
-(void)stopDisplayingApp;
-(void)showOrHide;
-(void)hideEasyAccess;
-(void)showEasyAccess;
@end

@interface UIImage (IndieDev)
+ (UIImage *)_applicationIconImageForBundleIdentifier:( NSString *)bundleIdentifier format:(int)format scale:(CGFloat)scale;
@end

@interface UIView (custom)

- (UIView *)setRoundedCorners:(UIRectCorner)corners withRadius:(CGFloat)radius;

@end



