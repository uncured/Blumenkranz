#ifndef Blumenkranz_VMTypes_h
#define Blumenkranz_VMTypes_h

typedef void (^VMBlock)();
typedef void (^VMErrorBlock)(NSError *);
typedef void (^VMViewControllerBlock)(UIViewController *);
typedef id (^VMObjectProvidingBlock)();

#endif
