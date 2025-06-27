import 'dart:developer';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/search_history_item.dart';
import '../repository/search_history_repository.dart';

part 'search_history_provider.g.dart';

typedef OnSearch = void Function(String text);
typedef OnSelect = void Function(int index);


// Repository Provider
@riverpod
SearchHistoryRepository searchHistoryRepository(SearchHistoryRepositoryRef ref) {
  return SearchHistoryRepository();
}

// 검색 기록 Provider (String 리스트)
@riverpod
class SearchHistory extends _$SearchHistory {
  SearchHistoryRepository get _repository => ref.read(searchHistoryRepositoryProvider);

  @override
  List<String> build() {
    // 초기 데이터 로드
    try {
      return _repository.getSearchHistory();
    } catch (e) {
      log('검색 기록 초기 로드 실패: $e');
      return [];
    }
  }

  // 검색어 추가
  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      await _repository.addSearchQuery(query);
      // 상태 업데이트
      state = _repository.getSearchHistory();
    } catch (e) {
      log('검색어 추가 실패: $e');
    }
  }

  // 검색어 삭제
  Future<void> removeSearch(String query) async {
    try {
      await _repository.removeSearchQuery(query);
      // 상태 업데이트
      state = _repository.getSearchHistory();
    } catch (e) {
      log('검색어 삭제 실패: $e');
    }
  }

  // 모든 검색 기록 삭제
  Future<void> clearAll() async {
    try {
      await _repository.clearAllHistory();
      state = [];
    } catch (e) {
      log('전체 검색 기록 삭제 실패: $e');
    }
  }

  // 수동 새로고침
  void refresh() {
    try {
      state = _repository.getSearchHistory();
    } catch (e) {
      log('검색 기록 새로고침 실패: $e');
    }
  }
}

// 날짜 포함 검색 기록 Provider
@riverpod
class SearchHistoryWithDate extends _$SearchHistoryWithDate {
  SearchHistoryRepository get _repository => ref.read(searchHistoryRepositoryProvider);

  @override
  List<SearchHistoryItem> build() {
    try {
      return _repository.getSearchHistoryWithDate();
    } catch (e) {
      log('날짜 포함 검색 기록 초기 로드 실패: $e');
      return [];
    }
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      await _repository.addSearchQuery(query);
      state = _repository.getSearchHistoryWithDate();
    } catch (e) {
      log('검색어 추가 실패: $e');
    }
  }

  Future<void> removeSearch(String query) async {
    try {
      await _repository.removeSearchQuery(query);
      state = _repository.getSearchHistoryWithDate();
    } catch (e) {
      log('검색어 삭제 실패: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _repository.clearAllHistory();
      state = [];
    } catch (e) {
      log('전체 검색 기록 삭제 실패: $e');
    }
  }

  void refresh() {
    try {
      state = _repository.getSearchHistoryWithDate();
    } catch (e) {
      log('검색 기록 새로고침 실패: $e');
    }
  }

  // 오늘 검색한 기록만 가져오기
  List<SearchHistoryItem> getTodaySearches() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return state.where((item) {
      final searchDate = DateTime(
        item.searchedAt.year,
        item.searchedAt.month,
        item.searchedAt.day,
      );
      return searchDate.isAtSameMomentAs(today);
    }).toList();
  }

  // 특정 날짜 범위의 검색 기록 가져오기
  List<SearchHistoryItem> getSearchesByDateRange(DateTime start, DateTime end) {
    return state.where((item) {
      return item.searchedAt.isAfter(start) && item.searchedAt.isBefore(end);
    }).toList();
  }
}

// 최근 검색어 Provider (computed provider)
@riverpod
List<String> recentSearches(RecentSearchesRef ref, {int limit = 10}) {
  final searchHistory = ref.watch(searchHistoryProvider);
  return searchHistory.take(limit).toList();
}

// 검색 필터 상태 Provider
@riverpod
class SearchFilter extends _$SearchFilter {
  @override
  String build() => '';

  void updateFilter(String filter) {
    state = filter;
  }

  void clearFilter() {
    state = '';
  }
}

// 필터링된 검색 기록 Provider
@riverpod
List<String> filteredSearchHistory(FilteredSearchHistoryRef ref) {
  final filter = ref.watch(searchFilterProvider);
  final repository = ref.watch(searchHistoryRepositoryProvider);

  if (filter.isEmpty) {
    return repository.getRecentSearches(limit: 10);
  }

  return repository.searchInHistory(filter);
}

// 검색 기록 통계 Provider
@riverpod
SearchHistoryStats searchHistoryStats(SearchHistoryStatsRef ref) {
  final repository = ref.watch(searchHistoryRepositoryProvider);
  final historyWithDate = repository.getSearchHistoryWithDate();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final todayCount = historyWithDate.where((item) {
    final searchDate = DateTime(
      item.searchedAt.year,
      item.searchedAt.month,
      item.searchedAt.day,
    );
    return searchDate.isAtSameMomentAs(today);
  }).length;

  final yesterdayCount = historyWithDate.where((item) {
    final searchDate = DateTime(
      item.searchedAt.year,
      item.searchedAt.month,
      item.searchedAt.day,
    );
    return searchDate.isAtSameMomentAs(yesterday);
  }).length;

  return SearchHistoryStats(
    totalCount: historyWithDate.length,
    todayCount: todayCount,
    yesterdayCount: yesterdayCount,
  );
}

// 오늘의 검색 기록 Provider
@riverpod
List<SearchHistoryItem> todaySearchHistory(TodaySearchHistoryRef ref) {
  final searchHistoryNotifier = ref.watch(searchHistoryWithDateProvider.notifier);
  return searchHistoryNotifier.getTodaySearches();
}

// 비동기 검색 기록 Provider (AsyncNotifier 사용)
@riverpod
class AsyncSearchHistory extends _$AsyncSearchHistory {
  SearchHistoryRepository get _repository => ref.read(searchHistoryRepositoryProvider);

  @override
  Future<List<String>> build() async {
    // 비동기로 초기 데이터 로드
    try {
      return _repository.getSearchHistory();
    } catch (e) {
      log('비동기 검색 기록 초기 로드 실패: $e');
      rethrow;
    }
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    // 로딩 상태로 변경
    state = const AsyncValue.loading();

    try {
      await _repository.addSearchQuery(query);
      final newHistory = _repository.getSearchHistory();
      state = AsyncValue.data(newHistory);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      log('비동기 검색어 추가 실패: $e');
    }
  }

  Future<void> removeSearch(String query) async {
    state = const AsyncValue.loading();

    try {
      await _repository.removeSearchQuery(query);
      final newHistory = _repository.getSearchHistory();
      state = AsyncValue.data(newHistory);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      log('비동기 검색어 삭제 실패: $e');
    }
  }

  Future<void> clearAll() async {
    state = const AsyncValue.loading();

    try {
      await _repository.clearAllHistory();
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      log('비동기 전체 검색 기록 삭제 실패: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final newHistory = _repository.getSearchHistory();
      state = AsyncValue.data(newHistory);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      log('비동기 검색 기록 새로고침 실패: $e');
    }
  }
}

// 검색 기록이 비어있는지 확인하는 Provider
@riverpod
bool isSearchHistoryEmpty(IsSearchHistoryEmptyRef ref) {
  final searchHistory = ref.watch(searchHistoryProvider);
  return searchHistory.isEmpty;
}

// 검색 기록 개수 Provider
@riverpod
int searchHistoryCount(SearchHistoryCountRef ref) {
  final searchHistory = ref.watch(searchHistoryProvider);
  return searchHistory.length;
}

// 특정 검색어가 기록에 있는지 확인하는 Provider
@riverpod
bool hasSearchQuery(HasSearchQueryRef ref, String query) {
  final searchHistory = ref.watch(searchHistoryProvider);
  return searchHistory.contains(query);
}

// 검색 기록 통계 클래스
class SearchHistoryStats {
  final int totalCount;
  final int todayCount;
  final int yesterdayCount;

  SearchHistoryStats({
    required this.totalCount,
    required this.todayCount,
    required this.yesterdayCount,
  });

  @override
  String toString() {
    return 'SearchHistoryStats(total: $totalCount, today: $todayCount, yesterday: $yesterdayCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchHistoryStats &&
        other.totalCount == totalCount &&
        other.todayCount == todayCount &&
        other.yesterdayCount == yesterdayCount;
  }

  @override
  int get hashCode {
    return totalCount.hashCode ^ todayCount.hashCode ^ yesterdayCount.hashCode;
  }
}