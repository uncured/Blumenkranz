#ifndef Blumenkranz_VMSingletone_h
#define Blumenkranz_VMSingletone_h

#define VMStoreAndReturn(objectProviding) \
    static id singletoneObject = nil; \
    static dispatch_once_t predicate; \
    dispatch_once(&predicate, ^{ \
        singletoneObject = objectProviding; \
    }); \
    return singletoneObject;

#endif
