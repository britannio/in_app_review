package dev.britannio.in_app_review

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import androidx.core.net.toUri
import com.google.android.play.core.review.ReviewManagerFactory

/** InAppReviewPlugin */
class InAppReviewPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null

    private val TAG = "InAppReviewPlugin"

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "dev.britannio.in_app_review"
        )
        channel.setMethodCallHandler(this)
        // Initialise context
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.i(TAG, "onMethodCall: ${call.method}")
        when (call.method) {
            "isAvailable" -> isAvailable(result)
            "requestReview" -> requestReview(result)
            "openStoreListing" -> openStoreListing(result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
        activity = null
    }

    // ActivityAware overrides
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    private fun isAvailable(result: Result) {
        Log.i(TAG, "isAvailable: called")
        val currentContext = context
        if (currentContext == null) {
            Log.e(TAG, "isAvailable: Android context not available")
            result.success(false)
            return
        }
        try {
            val manager = ReviewManagerFactory.create(currentContext)
            val request = manager.requestReviewFlow()
            request.addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    // To our best knowledge, the plugin is compatible with this device
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "isAvailable: error", e)
            result.success(false)
        }
    }

    private fun requestReview(result: Result) {
        Log.i(TAG, "requestReview: called")
        val currentContext = context
        if (currentContext == null) {
            result.error("error", "Android context not available", null)
            return
        }

        val currentActivity = activity
        if (currentActivity == null) {
            result.error("error", "Android activity not available", null)
            return
        }

        try {
            val manager = ReviewManagerFactory.create(currentContext)
            val request = manager.requestReviewFlow()
            request.addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    Log.i(TAG, "onComplete: Successfully requested review flow")
                    val info = task.result
                    val flow = manager.launchReviewFlow(currentActivity, info)
                    flow.addOnCompleteListener { flowTask ->
                        // The API does not indicate whether the user reviewed or if the dialog was shown.
                        if (flowTask.isSuccessful) {
                            result.success(null)
                        } else {
                            result.error(
                                "error",
                                "Failed to launch in-app review flow",
                                null
                            )
                        }
                    }
                } else {
                    Log.w(TAG, "onComplete: Unsuccessfully requested review flow")
                    result.error(
                        "error",
                        "In-App Review API unavailable",
                        null
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "requestReview: error", e)
            result.error(
                "error",
                "An error occurred during the request review flow",
                null
            )
        }
    }

    private fun openStoreListing(result: Result) {
        Log.i(TAG, "openStoreListing: called")
        val currentContext = context
        if (currentContext == null) {
            result.error("error", "Android context not available", null)
            return
        }

        val currentActivity = activity
        if (currentActivity == null) {
            result.error("error", "Android activity not available", null)
            return
        }

        try {
            val packageName = currentContext.packageName
            val marketIntent = Intent(Intent.ACTION_VIEW)
                .setData("market://details?id=$packageName".toUri())
                .setPackage("com.android.vending")

            val playStoreIntent = if (marketIntent.resolveActivity(currentContext.packageManager) != null) {
                marketIntent
            } else {
                Intent(Intent.ACTION_VIEW)
                    .setData("https://play.google.com/store/apps/details?id=$packageName".toUri())
            }

            currentActivity.startActivity(playStoreIntent)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "openStoreListing: error", e)
            result.error(
                "error",
                "An error occurred while opening the play store",
                null
            )
        }
    }

}
