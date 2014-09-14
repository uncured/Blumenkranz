#import "VMGameCenterService.h"

@implementation VMGameCenterService {
    BOOL _animated;
}

- (instancetype)init {
    return [[self class] singletone];
}

- (void)dealloc {
    self.controllerWillPresentBlock = nil;
    self.controllerDidPresentBlock = nil;
    self.controllerWillDismissBlock = nil;
    self.controllerDidDismissBlock = nil;
    self.errorBlock = nil;
}

#pragma mark VMGameCenterService
- (void)showIn:(UIViewController *)parentViewController animated:(BOOL)animated {
    _animated = animated;
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController) {
        gameCenterController.gameCenterDelegate = self;
        if (self.controllerWillPresentBlock) {
            self.controllerWillPresentBlock(gameCenterController);
        }
        [parentViewController presentViewController:gameCenterController animated:animated completion:^(){
            if (self.controllerDidPresentBlock) {
                self.controllerDidPresentBlock(gameCenterController);
            }
        }];
    }
}

- (void)setAuthenticationHandler:(VMViewControllerBlock)handler {
    VMViewControllerBlock handlerCopy = [handler copy];
    
    [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *viewController, NSError *error) {
        if (error) {
            if (self.errorBlock) {
                self.errorBlock(error);
            }
        } else if (![[GKLocalPlayer localPlayer] isAuthenticated] && viewController) {
            if (handlerCopy) {
                handlerCopy(viewController);
            }
        }
    }];
}

#pragma mark GKGameCenterControllerDelegate
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    if (self.controllerWillDismissBlock) {
        self.controllerWillDismissBlock(gameCenterViewController);
    }
    [gameCenterViewController dismissViewControllerAnimated:_animated completion:^{
        if (self.controllerDidDismissBlock) {
            self.controllerDidDismissBlock(gameCenterViewController);
        }
    }];
}

@end
