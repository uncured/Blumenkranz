@import GameKit;

@interface VMGameCenterService : NSObject <GKGameCenterControllerDelegate>
@property (nonatomic, copy) VMViewControllerBlock controllerWillPresentBlock;
@property (nonatomic, copy) VMViewControllerBlock controllerDidPresentBlock;
@property (nonatomic, copy) VMViewControllerBlock controllerWillDismissBlock;
@property (nonatomic, copy) VMViewControllerBlock controllerDidDismissBlock;
@property (nonatomic, copy) VMErrorBlock errorBlock;

- (void)showIn:(UIViewController *)parentViewController animated:(BOOL)animated;

- (void)setAuthenticationHandler:(VMViewControllerBlock)handler;

@end
