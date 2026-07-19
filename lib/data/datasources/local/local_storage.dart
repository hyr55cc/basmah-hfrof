import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';

/// Unified local storage with Hive + SharedPreferences + SecureStorage
class LocalStorage {
  LocalStorage();

  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize all storage backends
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();
      _prefs = await SharedPreferences.getInstance();

      // Open Hive boxes
      await Hive.openBox(AppConstants.settingsBox);
      await Hive.openBox(AppConstants.userBox);
      await Hive.openBox(AppConstants.progressBox);
      await Hive.openBox(AppConstants.levelsBox);
      await Hive.openBox(AppConstants.achievementsBox);

      _isInitialized = true;
    } catch (e) {
      throw CacheException('فشل تهيئة التخزين المحلي: $e');
    }
  }

  // ============================================================
  // SharedPreferences helpers
  // ============================================================

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) => _prefs.getString(key);

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) => _prefs.getInt(key);

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) => _prefs.getDouble(key);

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, json.encode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final value = _prefs.getString(key);
    if (value == null) return null;
    try {
      return json.decode(value) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // ============================================================
  // Hive helpers
  // ============================================================

  Box<dynamic> _box(String name) {
    if (!Hive.isBoxOpen(name)) {
      throw CacheException('Box $name not open');
    }
    return Hive.box<dynamic>(name);
  }

  Future<void> setBoxData(String boxName, String key, dynamic value) async {
    final box = Hive.box<dynamic>(boxName);
    await box.put(key, value);
  }

  T? getBoxData<T>(String boxName, String key) {
    final box = Hive.box<dynamic>(boxName);
    return box.get(key) as T?;
  }

  Future<void> deleteBoxData(String boxName, String key) async {
    final box = Hive.box<dynamic>(boxName);
    await box.delete(key);
  }

  Future<void> clearBox(String boxName) async {
    final box = Hive.box<dynamic>(boxName);
    await box.clear();
  }

  Map<dynamic, dynamic> getAllBoxData(String boxName) {
    final box = Hive.box<dynamic>(boxName);
    return box.toMap();
  }

  // ============================================================
  // Secure storage
  // ============================================================

  Future<void> setSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecure(String key) async {
    return _secureStorage.read(key: key);
  }

  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  // ============================================================
  // Specialized cache helpers
  // ============================================================

  Future<void> cacheUserData(Map<String, dynamic> data) async {
    await setBoxData(AppConstants.userBox, 'current_user', data);
  }

  Map<String, dynamic>? getCachedUserData() {
    return getBoxData<Map>(AppConstants.userBox, 'current_user')
        ?.cast<String, dynamic>();
  }

  Future<void> cacheLevel(int levelId, Map<String, dynamic> data) async {
    await setBoxData(AppConstants.levelsBox, 'level_$levelId', data);
  }

  Map<String, dynamic>? getCachedLevel(int levelId) {
    return getBoxData<Map>(AppConstants.levelsBox, 'level_$levelId')
        ?.cast<String, dynamic>();
  }

  Future<void> cacheProgress(int levelId, Map<String, dynamic> data) async {
    await setBoxData(AppConstants.progressBox, 'progress_$levelId', data);
  }

  Map<String, dynamic>? getCachedProgress(int levelId) {
    return getBoxData<Map>(AppConstants.progressBox, 'progress_$levelId')
        ?.cast<String, dynamic>();
  }

  Future<void> clearAllCache() async {
    await clearBox(AppConstants.levelsBox);
    await clearBox(AppConstants.progressBox);
    await clearBox(AppConstants.userBox);
    await clearAll();
  }
}
