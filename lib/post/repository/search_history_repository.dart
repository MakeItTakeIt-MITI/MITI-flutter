import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../model/search_history_item.dart';
class SearchHistoryRepository {
  static const String _boxName = 'search_history';
  static const int _maxHistoryCount = 50;

  late final Box<String> _box; // JSON String으로 저장

  static final SearchHistoryRepository _instance = SearchHistoryRepository._internal();
  factory SearchHistoryRepository() => _instance;
  SearchHistoryRepository._internal();

  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<String>(_boxName);
        log('검색 기록 Box 초기화 완료');
      } else {
        _box = Hive.box<String>(_boxName);
      }
    } catch (e) {
      log('검색 기록 Box 초기화 실패: $e');
      rethrow;
    }
  }

  // 검색어 추가 (새로운 방식)
  Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final trimmedQuery = query.trim();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 고유한 키로 저장 (타임스탬프 사용)
      final key = '${timestamp}_${trimmedQuery.hashCode}';

      final item = SearchHistoryItem(
        query: trimmedQuery,
        searchedAt: DateTime.now(),
      );

      // 기존 같은 검색어 삭제 (중복 제거)
      await _removeExistingQuery(trimmedQuery);

      // 새 검색어 추가
      await _box.put(key, _itemToJsonString(item));

      // 최대 개수 초과 시 오래된 항목 삭제
      await _cleanupOldItems();

      log('검색어 추가 완료: $trimmedQuery');
    } catch (e) {
      log('검색어 추가 실패: $e');
    }
  }

  // 기존 같은 검색어 삭제
  Future<void> _removeExistingQuery(String query) async {
    final keysToDelete = <String>[];

    for (final key in _box.keys) {
      final itemString = _box.get(key);
      if (itemString != null) {
        final item = _itemFromJsonString(itemString);
        if (item?.query == query) {
          keysToDelete.add(key);
        }
      }
    }

    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }

  // 오래된 항목 정리
  Future<void> _cleanupOldItems() async {
    if (_box.length <= _maxHistoryCount) return;

    // 모든 항목을 날짜순으로 정렬
    final allItems = <MapEntry<String, SearchHistoryItem>>[];

    for (final key in _box.keys) {
      final itemString = _box.get(key);
      if (itemString != null) {
        final item = _itemFromJsonString(itemString);
        if (item != null) {
          allItems.add(MapEntry(key, item));
        }
      }
    }

    // 날짜 내림차순 정렬 (최신순)
    allItems.sort((a, b) => b.value.searchedAt.compareTo(a.value.searchedAt));

    // 최대 개수 초과 항목 삭제
    if (allItems.length > _maxHistoryCount) {
      final itemsToDelete = allItems.skip(_maxHistoryCount);
      for (final item in itemsToDelete) {
        await _box.delete(item.key);
      }
    }
  }

  // 특정 검색어 삭제
  Future<void> removeSearchQuery(String query) async {
    await _removeExistingQuery(query);
    log('검색어 삭제 완료: $query');
  }

  // 모든 검색 기록 가져오기 (최신순)
  List<String> getSearchHistory() {
    try {
      final items = <SearchHistoryItem>[];

      for (final key in _box.keys) {
        final itemString = _box.get(key);
        if (itemString != null) {
          final item = _itemFromJsonString(itemString);
          if (item != null) {
            items.add(item);
          }
        }
      }

      // 날짜 내림차순 정렬 (최신순)
      items.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));

      return items.map((item) => item.query).toList();
    } catch (e) {
      log('검색 기록 조회 실패: $e');
      return [];
    }
  }

  // 최근 검색어 N개 가져오기
  List<String> getRecentSearches({int limit = 10}) {
    final allHistory = getSearchHistory();
    return allHistory.take(limit).toList();
  }

  // 검색어로 필터링 (자동완성용)
  List<String> searchInHistory(String partialQuery) {
    if (partialQuery.trim().isEmpty) return getRecentSearches();

    try {
      final allHistory = getSearchHistory();
      return allHistory
          .where((query) => query.toLowerCase().contains(partialQuery.toLowerCase()))
          .toList();
    } catch (e) {
      log('검색 기록 필터링 실패: $e');
      return [];
    }
  }

  // 검색 기록과 날짜 함께 가져오기 (필요한 경우)
  List<SearchHistoryItem> getSearchHistoryWithDate() {
    try {
      final items = <SearchHistoryItem>[];

      for (final key in _box.keys) {
        final itemString = _box.get(key);
        if (itemString != null) {
          final item = _itemFromJsonString(itemString);
          if (item != null) {
            items.add(item);
          }
        }
      }

      // 날짜 내림차순 정렬 (최신순)
      items.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));

      return items;
    } catch (e) {
      log('검색 기록 조회 실패: $e');
      return [];
    }
  }

  // 모든 검색 기록 삭제
  Future<void> clearAllHistory() async {
    try {
      await _box.clear();
      log('모든 검색 기록 삭제 완료');
    } catch (e) {
      log('검색 기록 삭제 실패: $e');
    }
  }

  // JSON 변환 헬퍼 메서드
  String _itemToJsonString(SearchHistoryItem item) {
    return '${item.query}|${item.searchedAt.millisecondsSinceEpoch}';
  }

  SearchHistoryItem? _itemFromJsonString(String jsonString) {
    try {
      final parts = jsonString.split('|');
      if (parts.length == 2) {
        return SearchHistoryItem(
          query: parts[0],
          searchedAt: DateTime.fromMillisecondsSinceEpoch(int.parse(parts[1])),
        );
      }
    } catch (e) {
      log('JSON 파싱 실패: $e');
    }
    return null;
  }

  // 검색 기록 개수
  int get historyCount => _box.length;

  // 검색 기록이 비어있는지 확인
  bool get isEmpty => _box.isEmpty;

  // Box 리스너 (실시간 업데이트용)
  Listenable get listenable => _box.listenable();

  // Repository 정리
  Future<void> dispose() async {
    if (_box.isOpen) {
      await _box.close();
    }
  }
}