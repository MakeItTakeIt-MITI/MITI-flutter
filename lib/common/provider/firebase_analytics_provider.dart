import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});

final analyticsObserverProvider = Provider<FirebaseAnalyticsObserver>((ref) {
  final analytics = ref.watch(firebaseAnalyticsProvider);

  return FirebaseAnalyticsObserver(analytics: analytics);
});
