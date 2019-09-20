#import "EACell.h"

@implementation EACell
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        self.backgroundColor = UIColor.clearColor;
        self.appImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.appImageView.backgroundColor = UIColor.clearColor;
        self.appImageView.clipsToBounds = YES;
        self.appImageView.userInteractionEnabled = NO;
        self.appImageView.layer.masksToBounds = YES;
        [self addSubview:self.appImageView];
    }
    return self;
}
@end