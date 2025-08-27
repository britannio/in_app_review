# in_app_review

![tests](https://github.com/britannio/in_app_review/workflows/tests/badge.svg?branch=master)
[![pub package](https://img.shields.io/pub/v/in_app_review.svg)](https://pub.dartlang.org/packages/in_app_review) ![In-App Review Android Demo](https://raw.githubusercontent.com/britannio/in_app_review/master/in_app_review/screenshots/android.jpg)
![In-App Review iOS Demo](https://raw.githubusercontent.com/britannio/in_app_review/master/in_app_review/screenshots/ios.png)

# Description

A Flutter plugin that lets you show a review pop up where users can leave a review for your app without needing to close your app. Alternatively, you can open your store listing via a deep link.

It uses the [In-App Review](https://developer.android.com/guide/playcore/in-app-review) API on Android and [requestReview](https://developer.apple.com/documentation/storekit/appstore/requestreview(in:)-1q8qs) on iOS/MacOS.


# Usage

## `requestReview()`

The following code triggers the In-App Review prompt. This should **not** be used frequently as the underlying API's enforce strict quotas on this feature to provide a great user experience.

```dart
import 'package:in_app_review/in_app_review.dart';

final InAppReview inAppReview = InAppReview.instance;

if (await inAppReview.isAvailable()) {
    inAppReview.requestReview();
}
```

### Do

- Use this after a user has experienced your app for long enough to provide useful feedback, e.g., after the completion of a game level or after a few days.
- Use this sparingly otherwise no pop up will appear.

### Avoid

- Triggering this via a button in your app as it will only work when the quota enforced by the underlying API has not been exceeded. ([Android](https://developer.android.com/guide/playcore/in-app-review#quotas))
- Interrupting the user if they are mid way through a task.

**Testing `requestReview()` on Android isn't as simple as running your app via the emulator or a physical device. See [Testing](#testing-read-carefully) for more info.**

---

## `openStoreListing()`

The following code opens the Google Play Store on Android, the App Store with a review screen on iOS & MacOS and the Microsoft Store on Windows. Use this if you want to permanently provide a button or other call-to-action to let users leave a review as it isn't restricted by a quota.

```dart
import 'package:in_app_review/in_app_review.dart';

final InAppReview inAppReview = InAppReview.instance;

inAppReview.openStoreListing(appStoreId: '...', microsoftStoreId: '...');
```

`appStoreId` is only required on iOS and MacOS and can be found in App Store Connect under General > App Information > Apple ID.

`microsoftStoreId` is only required on Windows.

# Guidelines
<https://developer.apple.com/design/human-interface-guidelines/ios/system-capabilities/ratings-and-reviews/>

<https://developer.android.com/guide/playcore/in-app-review#when-to-request>
<https://developer.android.com/guide/playcore/in-app-review#design-guidelines>

Since there is a quota on how many times the pop up can be shown, you should **not** trigger `requestReview()` via a button or other *call-to-action* option. Instead, you can reliably redirect users to your store listing via `openStoreListing()`.

# Testing (read carefully)

## Android

You must upload your app to the Play Store to test `requestReview()`. The recommended approach is to build an app bundle and upload it via [internal app sharing](https://play.google.com/apps/publish/internalappsharing/).

Real reviews can only be created when `requestReview()` is used from the production track. The **submit** button is disabled on other tracks and in internal app sharing to emphasize this.

**If you get stuck here as many developers have, please refer to the [troubleshooting table](https://developer.android.com/guide/playcore/in-app-review/test#troubleshooting) found below or the complete [official instructions](https://developer.android.com/guide/playcore/in-app-review/test).**

<details>
<summary>Troubleshooting table</summary>
  
| Issue | Solution |
|-------|----------|
| Your app is not published yet in the Play Store.	                                    | Your app doesn't have to be published to test, but your app's **applicationID** must be available at least in the internal testing track.
| The user account can't review the app.	                                            | Your app must be in the user's Google Play library. To add your app to the user's library, download your app from the Play Store using that user's account.
| The primary account is not selected in the Play Store.	                            | When multiple accounts are available in the device, ensure that the primary account is the one selected in the Play Store.
| The user account is protected (for example, with enterprise accounts).	            | Use a Gmail account instead.
| The user has already reviewed the app.                                                | Delete the review directly from Play Store.
| The quota has been reached.	                                                        | Use an [internal test track](https://developer.android.com/guide/playcore/in-app-review/test#internal-test-track) or [internal app sharing](https://developer.android.com/guide/playcore/in-app-review/test#internal-app-sharing).
| There is an issue with the Google Play Store or Google Play Services on the device.   | This commonly occurs when the Play Store was sideloaded onto the device. Use a different device that has a valid version of the Play Store and Google Play Services.
  
</details>

## iOS

`requestReview()` can be tested via the iOS simulator or on a physical device.
Note that `requestReview()` will do **nothing** when testing via TestFlight [as documented](https://developer.apple.com/documentation/storekit/skstorereviewcontroller/3566727-requestreview#4278434).

Similarly to Android, real reviews can only created when `requestReview()` is used in production. The **submit** button is disabled when testing locally to emphasize this.


`openStoreListing()` can only be tested with a physical device as the iOS simulator does not have the App Store installed.

## MacOS

This plugin can be tested by running your MacOS application locally.

# Cross Platform Compatibility

| Function             | Android | iOS | MacOS | Windows |
|----------------------|---------|-----|-------|--------------|
| `isAvailable()`      | ✅       | ✅   | ✅     | ❌            |
| `requestReview()`    | ✅       | ✅   | ✅     | ❌            |
| `openStoreListing()` | ✅       | ✅   | ✅     | ✅            |

# Requirements

## Android

Requires Android 5 Lollipop(API 21) or higher and the Google Play Store must be installed.

## iOS

Requires iOS version 10.3

## MacOS

Requires MacOS version 10.14

Issues & pull requests are more than welcome!
