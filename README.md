# in_app_review

[![pub package](https://img.shields.io/pub/v/in_app_review.svg)](https://pub.dartlang.org/packages/in_app_review)

![In-App Review Android Demo](https://github.com/britannio/in_app_review/blob/master/screenshots/android.jpg)
![In-App Review IOS Demo](https://github.com/britannio/in_app_review/blob/master/screenshots/ios.png)

# Description
Flutter plugin that lets you show a system review pop up where users can leave a review for your app without needing to leave it. Alternatively you can open your store listing via a deep link.

Uses the [In-App Review](https://developer.android.com/guide/playcore/in-app-review) API on Android and the [SKStoreReviewController](https://developer.apple.com/documentation/storekit/skstorereviewcontroller) on IOS


# Usage

```dart
final InAppReview inAppReview = InAppReview.instance;

if (await inAppReview.isAvailable()) {
    inAppReview.requestReview();
} else {
    inAppReview.openStoreListing(iOSAppStoreId: '<YOUR_APP_STORE_ID>')
}
```

# Guidelines
https://developer.apple.com/design/human-interface-guidelines/ios/system-capabilities/ratings-and-reviews/

https://developer.android.com/guide/playcore/in-app-review#when-to-request
https://developer.android.com/guide/playcore/in-app-review#design-guidelines

Since there is a quota on how many times the pop up can be shown, you should **not** trigger `requestReview` via a button or other *call-to-action* option. Instead, you can reliably redirect users to your store listing via `openStoreListing`.


# Requirements
## IOS
Requires IOS version 10.3.
## Android
Requires Android 5 Lollipop(API 21) or higher and the Google Play Store must be installed.

# Testing
## IOS
`requestReview` can be tested via the IOS simulator or on a physical device.

## Android
You must upload your app to the Play Store to test `requestReview`. An easy way to do this is to build an apk/app bundle and upload it via [internal app sharing](https://play.google.com/apps/publish/internalappsharing/).

More details at https://developer.android.com/guide/playcore/in-app-review/test



Issues & pull requests are more than welcome!