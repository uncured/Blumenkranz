@class VMPinButton;

@interface VMPinPad : UIView
@property (nonatomic, strong) UIImage *touchIdIcon;
@property (nonatomic, strong) UIImage *backspaceIcon;
@property (nonatomic, copy) void (^didPressNumberButton)(VMPinButton *button, VMPinPad *sender);
@property (nonatomic, copy) void (^didPressTouchIdButton)(VMPinButton *button, VMPinPad *sender);
@property (nonatomic, copy) void (^didPressBackspaceButton)(VMPinButton *button, VMPinPad *sender);
@end
