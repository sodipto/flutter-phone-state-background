package me.sodipto.phone_state_background

import androidx.annotation.NonNull
import android.Manifest
import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.ActivityCompat.shouldShowRequestPermissionRationale
import androidx.core.app.ActivityCompat.startActivityForResult
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** PhoneStateBackgroundPlugin */
class PhoneStateBackgroundPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
  companion object {
    const val PLUGIN_NAME = "me.sodipto.phone_state_background"
    const val CALLBACK_SHAREDPREFERENCES_KEY = "phoneStateBackgroundPluginCallbackHandler"
    const val CALLBACK_USER_SHAREDPREFERENCES_KEY = "phoneStateBackgroundCallbackHandlerUser"
  }

  /// The MethodChannel that will the communication between Flutter and native Android
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private var channel: MethodChannel? = null
  private var currentActivity: Activity? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, PLUGIN_NAME)
    channel!!.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    val arguments = call.arguments as ArrayList<*>?
    if (call.method == "initialize" && arguments?.size == 2) {
      if (!doCheckPermission()) {
        result.error("MISSING_PERMISSION", null, null)
        return
      }
      val sharedPref = currentActivity!!.getSharedPreferences(PLUGIN_NAME, Context.MODE_PRIVATE)
      val editor = sharedPref.edit()
      editor.putLong(CALLBACK_SHAREDPREFERENCES_KEY, (arguments[0] as Long))
      editor.putLong(CALLBACK_USER_SHAREDPREFERENCES_KEY, (arguments[1] as Long))
      editor.commit()

      val context = currentActivity!!.applicationContext
      val receiver = ComponentName(context, PhoneStateBackgroundServiceReceiver::class.java)
      context.packageManager.setComponentEnabledSetting(receiver,
              PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
              PackageManager.DONT_KILL_APP
      )
      Log.d(PLUGIN_NAME, "Service initialized...")
      result.success(true)

    } else if (call.method == "stopcallstate") {
      val sharedPref = currentActivity!!.getSharedPreferences(PLUGIN_NAME, Context.MODE_PRIVATE)
      val editor = sharedPref.edit()
      editor.remove(CALLBACK_SHAREDPREFERENCES_KEY)
      editor.remove(CALLBACK_USER_SHAREDPREFERENCES_KEY)
      val context: Context = currentActivity!!.applicationContext
      val receiver = ComponentName(context, PhoneStateBackgroundServiceReceiver::class.java)
        context.packageManager.setComponentEnabledSetting(receiver,
              PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
              PackageManager.DONT_KILL_APP
      )
      editor.commit()
      result.success(true)

    } else if (call.method == "requestPermissions") {
      Log.d(PLUGIN_NAME, "Requesting permission...")
      requestPermissions()

    } else if (call.method == "checkPermissions") {
      val check = doCheckPermission()
      Log.d(PLUGIN_NAME, "Permission checked: $check")
      result.success(check)

    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    channel!!.setMethodCallHandler(null)
  }

  private fun doCheckPermission(): Boolean {
    if (currentActivity != null && currentActivity!!.applicationContext != null) {
      val permPhoneState = ContextCompat.checkSelfPermission(currentActivity!!, Manifest.permission.READ_PHONE_STATE)
      val permReadCallLog = ContextCompat.checkSelfPermission(currentActivity!!, Manifest.permission.READ_CALL_LOG)
      val grantedCode = PackageManager.PERMISSION_GRANTED
      return permPhoneState == grantedCode && permReadCallLog == grantedCode
    }
    return false
  }

  private fun requestPermissions() {
    if (currentActivity?.applicationContext == null)
      return;

    val grantedCode = PackageManager.PERMISSION_GRANTED

    val permissions = arrayOf(
      Manifest.permission.READ_PHONE_STATE,
      Manifest.permission.READ_CALL_LOG
    )
    val permissionsToAsk = arrayListOf<String>()

    for(permission in permissions) {
      val permState = ContextCompat.checkSelfPermission(currentActivity!!, permission)

      if(permState == grantedCode)
        continue

      val shouldShowRequest = shouldShowRequestPermissionRationale(currentActivity!!, permission)

      if(!shouldShowRequest){
        val intent = Intent()
        intent.action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
        val uri = Uri.fromParts("package", currentActivity!!.packageName, null)
        intent.data = uri
        currentActivity!!.startActivity(intent)

      } else {
        permissionsToAsk.add(permission)
      }
    }

    if(permissionsToAsk.size > 0)
      ActivityCompat.requestPermissions(currentActivity!!, permissions, 999)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    currentActivity = binding.activity
    binding.addRequestPermissionsResultListener(this)
    requestPermissions()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    currentActivity = binding.activity
    binding.addRequestPermissionsResultListener(this)
    requestPermissions()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    currentActivity = null
  }

  override fun onDetachedFromActivity() {
    currentActivity = null
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
    return when (requestCode) {
      999 -> grantResults != null && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
      else -> false
    }
  }
}
