#ifndef Blumenkranz_VMLog_h
#define Blumenkranz_VMLog_h

#ifdef DEBUG
#define VMLog(string, ...) \
    NSLog(@"%s [%d]:", __PRETTY_FUNCTION__, __LINE__); \
    NSLog(string, ##__VA_ARGS__);
#else
#define VMLog(string, ...)
#endif

#endif