package dev.britannio.in_app_review

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
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
        if (noContextOrActivity()) {
            result.success(false)
            return
        }
        try {
            val manager = ReviewManagerFactory.create(context!!)
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
        if (noContextOrActivity(result)) return

        try {
            val manager = ReviewManagerFactory.create(context!!)
            val request = manager.requestReviewFlow()
            request.addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    Log.i(TAG, "onComplete: Successfully requested review flow")
                    val info = task.result
                    val flow = manager.launchReviewFlow(activity!!, info)
                    flow.addOnCompleteListener {
                        // The API does not indicate whether the user reviewed or if the dialog was shown.
                        result.success(null)
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
        if (noContextOrActivity(result)) return
        try {
            val packageName = context!!.packageName
            val intent = Intent(Intent.ACTION_VIEW)
                .setData("https://play.google.com/store/apps/details?id=$packageName".toUri())
            activity!!.startActivity(intent)
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

    private fun noContextOrActivity(result: Result? = null): Boolean {
        Log.i(TAG, "noContextOrActivity: called")

        if (context == null) {
            val msg = "Android context not available"
            Log.e(TAG, "noContextOrActivity: $msg")
            result?.error("error", msg, null)
            return true
        }

        if (activity == null) {
            val msg = "Android activity not available"
            Log.e(TAG, "noContextOrActivity: $msg")
            result?.error("error", msg, null)
            return true
        }

        return false
    }

}
