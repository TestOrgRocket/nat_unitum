#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "loading_ic" asset catalog image resource.
static NSString * const ACImageNameLoadingIc AC_SWIFT_PRIVATE = @"loading_ic";

/// The "loading_point_ic" asset catalog image resource.
static NSString * const ACImageNameLoadingPointIc AC_SWIFT_PRIVATE = @"loading_point_ic";

/// The "notifications_back" asset catalog image resource.
static NSString * const ACImageNameNotificationsBack AC_SWIFT_PRIVATE = @"notifications_back";

/// The "skip_btn" asset catalog image resource.
static NSString * const ACImageNameSkipBtn AC_SWIFT_PRIVATE = @"skip_btn";

/// The "splash_back" asset catalog image resource.
static NSString * const ACImageNameSplashBack AC_SWIFT_PRIVATE = @"splash_back";

/// The "splash_back_land" asset catalog image resource.
static NSString * const ACImageNameSplashBackLand AC_SWIFT_PRIVATE = @"splash_back_land";

/// The "title_1" asset catalog image resource.
static NSString * const ACImageNameTitle1 AC_SWIFT_PRIVATE = @"title_1";

/// The "title_2" asset catalog image resource.
static NSString * const ACImageNameTitle2 AC_SWIFT_PRIVATE = @"title_2";

/// The "want_btn" asset catalog image resource.
static NSString * const ACImageNameWantBtn AC_SWIFT_PRIVATE = @"want_btn";

#undef AC_SWIFT_PRIVATE
