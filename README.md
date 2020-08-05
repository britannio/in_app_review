# in_app_review

![In-App Review Android Demo](https://github.com/britannio/in_app_review/blob/master/screenshots/android.jpg)
![In-App Review IOS Demo](https://github.com/britannio/in_app_review/blob/master/screenshots/ios.png)

# Description
Flutter plugin that lets you show a system review pop up where users can leave a review for your app without needing to leave it.


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

Issues & pull requests are more than welcome!