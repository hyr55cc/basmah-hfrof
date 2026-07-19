import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Firebase storage service for uploading/downloading files
class StorageService {
  StorageService();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a file
  Future<String> uploadFile({
    required String path,
    required File file,
    String? contentType,
  }) async {
    try {
      final ref = _storage.ref(path);
      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: contentType),
      );
      return await task.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Upload file error: $e');
      }
      rethrow;
    }
  }

  /// Upload bytes
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    try {
      final ref = _storage.ref(path);
      final task = await ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );
      return await task.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Upload bytes error: $e');
      }
      rethrow;
    }
  }

  /// Get download URL
  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Get download URL error: $e');
      }
      rethrow;
    }
  }

  /// Delete a file
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Delete file error: $e');
      }
    }
  }

  /// Get file as bytes
  Future<Uint8List> getFileBytes(String path) async {
    try {
      return await _storage.ref(path).getData();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Get file bytes error: $e');
      }
      rethrow;
    }
  }
}
