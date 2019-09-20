#import <SpringBoard/SBApplication.h>

@interface EACell : UICollectionViewCell <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *appImageView;
@property (nonatomic, retain) NSString *bundleID;
@property (nonatomic, retain) SBApplication *app;
@end