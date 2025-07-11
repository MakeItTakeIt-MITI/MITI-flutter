package com.miti.miti

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.*
import io.flutter.embedding.engine.dart.DartExecutor
import android.content.ActivityNotFoundException;

import android.R
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private var CHANNEL = "fcm_default_channel"
    private var DEEPLINK_CHANNEL = "app/deeplink"  // 딥링크 채널 추가

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        // 기존 FCM 채널
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppUrl" -> {
                    try {
                        print(message = "메소드 출력")
                        val url: String = call.argument("url")!!
                        val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
                        result.success(intent.dataString)
                    }
                    catch (e: ActivityNotFoundException) {
                        result.notImplemented()
                    }
                }
            }
        }

        // 🆕 딥링크 처리 채널 추가
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEEPLINK_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "handleDeepLink" -> {
                    try {
                        val url: String = call.argument("url") ?: ""
                        print("Received deep link in Android: $url")
                        // Flutter로 딥링크 전달
                        result.success("Deep link handled: $url")
                    } catch (e: Exception) {
                        print("Error handling deep link: ${e.message}")
                        result.error("DEEP_LINK_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // 🆕 앱이 실행 중일 때 새로운 인텐트 처리
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    // 🆕 앱이 처음 실행될 때 인텐트 처리
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    // 🆕 딥링크 인텐트 처리 메서드
    private fun handleIntent(intent: Intent?) {
        if (intent?.action == Intent.ACTION_VIEW) {
            val data: Uri? = intent.data
            if (data != null) {
                val url = data.toString()
                print("Deep link received: $url")

                // Flutter 엔진이 준비되면 딥링크 전달
                flutterEngine?.let { engine ->
                    MethodChannel(engine.dartExecutor.binaryMessenger, DEEPLINK_CHANNEL)
                        .invokeMethod("handleDeepLink", url)
                }
            }
        }
    }
}
