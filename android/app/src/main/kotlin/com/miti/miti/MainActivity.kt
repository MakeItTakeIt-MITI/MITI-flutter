package com.miti.miti

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
//    private var CHANNEL = "fcm_default_channel"
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        GeneratedPluginRegistrant.registerWith(flutterEngine)
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            when (call.method) {
//                "getAppUrl" -> {
//                    try {
//                        print(message = "메소드 출력")
//
//                        val url: String = call.argument("url")!!
//                        val intent = Intent.parseUri(url, URI_INTENT_SCHEME)
//                        result.success(intent.dataString)
//
//                    } catch (e: URISyntaxException) {
//                        result.notImplemented()
//                    } catch (e: ActivityNotFoundException) {
//                        result.notImplemented()
//                    }
//                }
//            }
//        }
//    }
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
