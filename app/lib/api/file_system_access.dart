/// File System Access API service
/// This provides access to the browser's File System Access API on web platforms
/// and a stub implementation for non-web platforms
export 'file_system_access_stub.dart'
    if (dart.library.js_interop) 'file_system_access_web.dart';
