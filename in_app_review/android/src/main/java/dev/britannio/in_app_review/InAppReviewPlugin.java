package dev.britannio.in_app_review;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.tasks.Task;
import com.google.android.play.core.review.ReviewInfo;
import com.google.android.play.core.review.ReviewManager;
import com.google.android.play.core.review.ReviewManagerFactory;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * InAppReviewPlugin
 */
public class InAppReviewPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private Context context;
    private Activity activity;

    private ReviewInfo reviewInfo;

    private final String TAG = "InAppReviewPlugin";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "dev.britannio.in_app_review");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Log.i(TAG, "onMethodCall: " + call.method);
        switch (call.method) {
            case "isAvailable":
                isAvailable(result);
                break;
            case "requestReview":
                requestReview(result);
                break;
            case "openStoreListing":
                openStoreListing(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        context = null;
    }

    private void isAvailable(final Result result) {
        Log.i(TAG, "isAvailable: called");
        if (noContextOrActivity()) {
            result.success(false);
            return;
        }

        if (appInstalledByUnsupportedStore()) {
            invalidStoreWarning();
        }

        final boolean playStoreAndPlayServicesAvailable = isPlayStoreInstalled() && isPlayServicesAvailable();
        final boolean lollipopOrLater = Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP;

        Log.i(TAG, "isAvailable: playStoreAndPlayServicesAvailable: " + playStoreAndPlayServicesAvailable);
        Log.i(TAG, "isAvailable: lollipopOrLater: " + lollipopOrLater);

        if (!(playStoreAndPlayServicesAvailable && lollipopOrLater)) {
            // The play store isn't installed or the device isn't running Android 5 Lollipop(API 21) or
            // higher
            Log.w(TAG, "isAvailable: The Play Store must be installed, Play Services must be available and Android 5 or later must be used");
            result.success(false);
        } else {
            // The API is likely available but we can ensure that it is by getting a ReviewInfo object
            // from the API. This will also speed up the review flow when we're ready to launch it as
            // the ReviewInfo doesn't need to be fetched.
            Log.i(TAG, "isAvailable: Play Store, Play Services and Android version requirements met");
            cacheReviewInfo(result);
        }
    }

    private void cacheReviewInfo(final Result result) {
        Log.i(TAG, "cacheReviewInfo: called");
        if (noContextOrActivity(result)) return;

        final ReviewManager manager = ReviewManagerFactory.create(context);

        final Task<ReviewInfo> request = manager.requestReviewFlow();

        Log.i(TAG, "cacheReviewInfo: Requesting review flow");
        request.addOnCompleteListener((task) -> {
            if (task.isSuccessful()) {
                // We can get the ReviewInfo object
                Log.i(TAG, "onComplete: Successfully requested review flow");
                reviewInfo = task.getResult();
                result.success(true);
            } else {
                // The API isn't available
                Log.w(TAG, "onComplete: Unsuccessfully requested review flow");
                result.success(false);
            }
        });

    }

    private void requestReview(final Result result) {
        Log.i(TAG, "requestReview: called");
        if (noContextOrActivity(result)) return;

        if (appInstalledByUnsupportedStore()) {
            invalidStoreWarning();
        }

        final ReviewManager manager = ReviewManagerFactory.create(context);

        if (reviewInfo != null) {
            launchReviewFlow(result, manager, reviewInfo);
            return;
        }

        final Task<ReviewInfo> request = manager.requestReviewFlow();

        Log.i(TAG, "requestReview: Requesting review flow");
        request.addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                // We can get the ReviewInfo object
                Log.i(TAG, "onComplete: Successfully requested review flow");
                ReviewInfo reviewInfo = task.getResult();
                launchReviewFlow(result, manager, reviewInfo);
            } else {
                Log.w(TAG, "onComplete: Unsuccessfully requested review flow");
                result.error("error", "In-App Review API unavailable", null);
            }
        });
    }

    private void launchReviewFlow(final Result result, ReviewManager manager, ReviewInfo reviewInfo) {
        Log.i(TAG, "launchReviewFlow: called");
        if (noContextOrActivity(result)) return;

        Task<Void> flow = manager.launchReviewFlow(activity, reviewInfo);
        flow.addOnCompleteListener(task -> result.success(null));
    }

    private boolean isPlayStoreInstalled() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                context.getPackageManager().getPackageInfo("com.android.vending", PackageManager.PackageInfoFlags.of(0));
            } else {
                context.getPackageManager().getPackageInfo("com.android.vending", 0);
            }
        } catch (PackageManager.NameNotFoundException e) {
            Log.i(TAG, "Play Store not installed.");
            return false;
        }

        return true;
    }

    private boolean isPlayServicesAvailable() {
        GoogleApiAvailability availability = GoogleApiAvailability.getInstance();
        if (availability.isGooglePlayServicesAvailable(context) != ConnectionResult.SUCCESS) {
            Log.i(TAG, "Google Play Services not available");
            return false;
        }

        return true;
    }

    private boolean appInstalledByUnsupportedStore() {
        final List<String> validInstallers = new ArrayList<>(List.of("com.android.vending"));
        final String installer = context.getPackageManager().getInstallerPackageName(context.getPackageName());
        Log.i(TAG, "appInstalledByUnsupportedStore: installer: " + installer);
        return installer == null || !validInstallers.contains(installer);
    }


    private void invalidStoreWarning() {
        Log.w(TAG, "The app should be installed by the Play Store to test in_app_review. See https://pub.dev/packages/in_app_review#testing-read-carefully for more information.");
    }


    private void openStoreListing(Result result) {
        Log.i(TAG, "openStoreListing: called");
        if (noContextOrActivity(result)) return;

        // https://developer.android.com/distribute/marketing-tools/linking-to-google-play#OpeningDetails
        final String packageName = context.getPackageName();

        final Intent intent = new Intent(Intent.ACTION_VIEW,
                Uri.parse("https://play.google.com/store/apps/details?id=" + packageName)
        );

        activity.startActivity(intent);

        result.success(null);
    }

    private boolean noContextOrActivity() {
        Log.i(TAG, "noContextOrActivity: called");
        if (context == null) {
            Log.e(TAG, "noContextOrActivity: Android context not available");
            return true;
        } else if (activity == null) {
            Log.e(TAG, "noContextOrActivity: Android activity not available");
            return true;
        } else {
            return false;
        }
    }

    private boolean noContextOrActivity(Result result) {
        Log.i(TAG, "noContextOrActivity: called");
        if (context == null) {
            Log.e(TAG, "noContextOrActivity: Android context not available");
            result.error("error", "Android context not available", null);
            return true;
        } else if (activity == null) {
            Log.e(TAG, "noContextOrActivity: Android activity not available");
            result.error("error", "Android activity not available", null);
            return true;
        } else {
            return false;
        }
    }

}
