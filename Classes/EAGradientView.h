@interface EAGradientView :UIView <UIGestureRecognizerDelegate>
@property (nonatomic, retain) UIPinchGestureRecognizer*twoFingerPinch;
@property (nonatomic, retain) UIPanGestureRecognizer*movePan;
@property (nonatomic, retain)NSString *centerKey;
@property (nonatomic, retain)NSString *scaleKey;
@property (nonatomic, assign) float lastGestureScale;
@property (nonatomic, assign) float scale;
@property (nonatomic, assign)CGPoint currentCenter;
- (id)initWithFrame:(CGRect)frame layerStyle:(BOOL)style;
-(void)enableTouches;
-(void)disableTouches;
-(void)setPositionAndScale;
-(void)setPosition;
-(void)setScale;
@end