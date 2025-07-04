## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Play Core 관련 클래스들을 완전히 무시
-dontwarn com.google.android.play.core.**
-ignorewarnings

# Flutter Play Store Split Application 관련 클래스 무시
-dontwarn io.flutter.app.FlutterPlayStoreSplitApplication
-keep class io.flutter.app.FlutterPlayStoreSplitApplication { *; }

# Flutter deferred components 관련 클래스들 무시
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Split 관련 클래스들을 빈 구현으로 처리
-keep,allowobfuscation,allowoptimization class com.google.android.play.core.splitcompat.SplitCompatApplication {
    public <init>();
}
