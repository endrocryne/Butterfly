import 'dart:typed_data';

/// Service to interact with the File System Access API on web
/// This is a stub implementation for non-web platforms
class FileSystemAccessService {
  static FileSystemAccessService? _instance;
  
  FileSystemAccessService._();
  
  factory FileSystemAccessService() {
    _instance ??= FileSystemAccessService._();
    return _instance!;
  }

  /// Check if the File System Access API is supported in the current browser
  /// Always returns false on non-web platforms
  bool isSupported() => false;

  /// Request access to a directory from the user
  /// Always returns false on non-web platforms
  Future<bool> requestDirectoryAccess() async => false;

  /// Check if we currently have access to a directory
  /// Always returns false on non-web platforms
  bool hasDirectoryAccess() => false;

  /// Get the name of the currently selected directory
  /// Always returns null on non-web platforms
  String? getDirectoryName() => null;

  /// Save a file to the selected directory
  /// Always returns false on non-web platforms
  Future<bool> saveFile(String path, Uint8List data) async => false;

  /// Read a file from the selected directory
  /// Always returns null on non-web platforms
  Future<Uint8List?> readFile(String path) async => null;

  /// List files and directories in a path
  /// Always returns empty list on non-web platforms
  Future<List<FileSystemEntry>> listDirectory(String path) async => [];

  /// Delete a file from the selected directory
  /// Always returns false on non-web platforms
  Future<bool> deleteFile(String path) async => false;

  /// Clear the stored directory handle
  /// Does nothing on non-web platforms
  void clearDirectoryAccess() {}
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
