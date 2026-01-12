import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Check if a JS value is null or undefined
bool _isNullOrUndefined(JSAny? value) {
  return value == null;
}

/// Get the File System Access API instance
JSObject? get _fileSystemAccess {
  if (!kIsWeb) return null;
  try {
    final jsObject = web.window.getProperty('fileSystemAccess'.toJS);
    // Check if the property exists and is not null/undefined
    if (jsObject == null) {
      return null;
    }
    return jsObject as JSObject?;
  } catch (e) {
    debugPrint('Error accessing fileSystemAccess: $e');
    return null;
  }
}

/// Service to interact with the File System Access API on web
class FileSystemAccessService {
  static FileSystemAccessService? _instance;
  
  FileSystemAccessService._();
  
  factory FileSystemAccessService() {
    _instance ??= FileSystemAccessService._();
    return _instance!;
  }

  /// Check if the File System Access API is supported in the current browser
  bool isSupported() {
    if (!kIsWeb) return false;
    final api = _fileSystemAccess;
    if (api == null) return false;
    try {
      final result = api.callMethod('isFileSystemAccessSupported'.toJS);
      if (_isNullOrUndefined(result)) return false;
      return (result as JSBoolean).toDart;
    } catch (e) {
      debugPrint('Error checking File System Access API support: $e');
      return false;
    }
  }

  /// Request access to a directory from the user
  /// Returns true if access was granted
  Future<bool> requestDirectoryAccess() async {
    if (!kIsWeb) return false;
    final api = _fileSystemAccess;
    if (api == null) return false;
    
    try {
      final promise = api.callMethod('requestDirectoryAccess'.toJS) as JSPromise;
      final result = await promise.toDart;
      if (_isNullOrUndefined(result)) return false;
      return (result as JSBoolean).toDart;
    } catch (e) {
      debugPrint('Error requesting directory access: $e');
      return false;
    }
  }

  /// Check if we currently have access to a directory
  bool hasDirectoryAccess() {
    if (!kIsWeb) return false;
    final api = _fileSystemAccess;
    if (api == null) return false;
    try {
      final result = api.callMethod('hasDirectoryAccess'.toJS);
      if (_isNullOrUndefined(result)) return false;
      return (result as JSBoolean).toDart;
    } catch (e) {
      debugPrint('Error checking directory access: $e');
      return false;
    }
  }

  /// Get the name of the currently selected directory
  String? getDirectoryName() {
    if (!kIsWeb) return null;
    final api = _fileSystemAccess;
    if (api == null) return null;
    try {
      final result = api.callMethod('getDirectoryName'.toJS);
      if (_isNullOrUndefined(result)) return null;
      return (result as JSString).toDart;
    } catch (e) {
      debugPrint('Error getting directory name: $e');
      return null;
    }
  }

  /// Save a file to the selected directory
  /// [path] is the relative path within the directory (e.g., "notes/document.bfly")
  /// [data] is the file data to save
  /// Returns true if save was successful
  Future<bool> saveFile(String path, Uint8List data) async {
    if (!kIsWeb) return false;
    final api = _fileSystemAccess;
    if (api == null) return false;
    
    try {
      final jsData = data.toJS;
      final promise = api.callMethod('saveFile'.toJS, path.toJS, jsData) as JSPromise;
      final result = await promise.toDart;
      if (_isNullOrUndefined(result)) return false;
      return (result as JSBoolean).toDart;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return false;
    }
  }

  /// Read a file from the selected directory
  /// Returns the file data or null if read failed
  Future<Uint8List?> readFile(String path) async {
    if (!kIsWeb) return null;
    final api = _fileSystemAccess;
    if (api == null) return null;
    
    try {
      final promise = api.callMethod('readFile'.toJS, path.toJS) as JSPromise;
      final result = await promise.toDart;
      if (_isNullOrUndefined(result)) {
        return null;
      }
      final jsArray = result as JSUint8Array;
      return jsArray.toDart;
    } catch (e) {
      debugPrint('Error reading file: $e');
      return null;
    }
  }

  /// List files and directories in a path
  /// Returns a list of entries with name and type
  Future<List<FileSystemEntry>> listDirectory(String path) async {
    if (!kIsWeb) return [];
    final api = _fileSystemAccess;
    if (api == null) return [];
    
    try {
      final promise = api.callMethod('listDirectory'.toJS, path.toJS) as JSPromise;
      final result = await promise.toDart;
      if (_isNullOrUndefined(result)) return [];
      
      final jsArray = result as JSArray;
      final entries = <FileSystemEntry>[];
      
      final length = jsArray.length;
      for (var i = 0; i < length; i++) {
        final entry = jsArray[i];
        if (_isNullOrUndefined(entry)) continue;
        
        final jsEntry = entry as JSObject;
        final name = jsEntry.getProperty('name'.toJS);
        final isDirectory = jsEntry.getProperty('isDirectory'.toJS);
        
        if (!_isNullOrUndefined(name) && !_isNullOrUndefined(isDirectory)) {
          entries.add(FileSystemEntry(
            name: (name as JSString).toDart,
            isDirectory: (isDirectory as JSBoolean).toDart,
          ));
        }
      }
      
      return entries;
    } catch (e) {
      debugPrint('Error listing directory: $e');
      return [];
    }
  }

  /// Delete a file from the selected directory
  /// Returns true if deletion was successful
  Future<bool> deleteFile(String path) async {
    if (!kIsWeb) return false;
    final api = _fileSystemAccess;
    if (api == null) return false;
    
    try {
      final promise = api.callMethod('deleteFile'.toJS, path.toJS) as JSPromise;
      final result = await promise.toDart;
      if (_isNullOrUndefined(result)) return false;
      return (result as JSBoolean).toDart;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  /// Clear the stored directory handle
  void clearDirectoryAccess() {
    if (!kIsWeb) return;
    final api = _fileSystemAccess;
    if (api == null) return;
    try {
      api.callMethod('clearDirectoryAccess'.toJS);
    } catch (e) {
      debugPrint('Error clearing directory access: $e');
    }
  }
}

/// Represents a file system entry
class FileSystemEntry {
  final String name;
  final bool isDirectory;

  FileSystemEntry({
    required this.name,
    required this.isDirectory,
  });

  @override
  String toString() => 'FileSystemEntry(name: $name, isDirectory: $isDirectory)';
}
