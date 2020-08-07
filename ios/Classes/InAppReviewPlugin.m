#import "InAppReviewPlugin.h"
#if __has_include(<in_app_review/in_app_review-Swift.h>)
#import <in_app_review/in_app_review-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "InAppReviewPlugin.h"
#endif

@implementation InAppReviewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [InAppReviewPlugin registerWithRegistrar:registrar];
}
@end
