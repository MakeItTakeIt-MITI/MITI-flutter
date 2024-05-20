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
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppUrl" -> {
                    try {
                        print(message = "메소드 출력")

                        val url: String = call.argument("url")!!
                        val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
                        result.success(intent.dataString)

                    }
//                    catch (e: URISyntaxException) {
//                        result.notImplemented()
//                    }
                    catch (e: ActivityNotFoundException) {
                        result.notImplemented()
                    }
                }
            }
        }
    }
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        MethodChannel(
//                flutterEngine.dartExecutor.binaryMessenger,
//                CHANNEL
//        ).setMethodCallHandler { call, result ->
//            when (call.method) {
//                "convertUri" -> try {
//                    val intent: Intent =
//                            Intent.parseUri(call.argument<String>("uri"), Intent.URI_INTENT_SCHEME)
//                    // 실제로 사용가능한 URL로 변환되는 과정
//                    result.success(intent.getDataString()) // 반환
//                } catch (e: URISyntaxException) {
//                    result.notImplemented()
//                } catch (e: ActivityNotFoundException) {
//                    result.notImplemented()
//                }
//            }
//        }
//    }
}
