#ifndef Blumenkranz_VMPlatform_h
#define Blumenkranz_VMPlatform_h

/*
 * Check if device is iPad
 */
#define VMDevicePad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/*
 * Check if device is iPhone
 */
#define VMDevicePhone (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)

/*
 * Check if runtime is x64
 */
#define VMRuntime64 (sizeof(NSInteger) == 8)

/*
 * Check if runtime is x32
 */
#define VMRuntime32 (sizeof(NSInteger) == 4)

#endif
