#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "edit" asset catalog image resource.
static NSString * const ACImageNameEdit AC_SWIFT_PRIVATE = @"edit";

/// The "nodata" asset catalog image resource.
static NSString * const ACImageNameNodata AC_SWIFT_PRIVATE = @"nodata";

#undef AC_SWIFT_PRIVATE