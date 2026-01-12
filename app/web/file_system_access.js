/**
 * File System Access API wrapper for Butterfly web app
 * Provides functions to interact with the local file system on supported browsers
 */

// Store the directory handle globally
let directoryHandle = null;

/**
 * Request access to a directory from the user
 * @returns {Promise<boolean>} True if access was granted, false otherwise
 */
async function requestDirectoryAccess() {
  try {
    // Check if File System Access API is supported
    if (!('showDirectoryPicker' in window)) {
      console.error('File System Access API is not supported in this browser');
      return false;
    }

    // Show directory picker
    directoryHandle = await window.showDirectoryPicker({
      mode: 'readwrite',
      startIn: 'documents'
    });

    // Verify we have permission
    const permission = await directoryHandle.requestPermission({ mode: 'readwrite' });
    return permission === 'granted';
  } catch (error) {
    console.error('Error requesting directory access:', error);
    return false;
  }
}

/**
 * Check if we have a directory handle
 * @returns {boolean} True if directory handle exists
 */
function hasDirectoryAccess() {
  return directoryHandle !== null;
}

/**
 * Get the name of the currently selected directory
 * @returns {string|null} Directory name or null if not set
 */
function getDirectoryName() {
  return directoryHandle ? directoryHandle.name : null;
}

/**
 * Save a file to the selected directory
 * @param {string} path - The relative path within the directory (e.g., "notes/document.bfly")
 * @param {Uint8Array} data - The file data to save
 * @returns {Promise<boolean>} True if save was successful, false otherwise
 */
async function saveFile(path, data) {
  try {
    if (!directoryHandle) {
      console.error('No directory handle available');
      return false;
    }

    // Split path into directory parts and filename
    const pathParts = path.split('/').filter(p => p.length > 0);
    const fileName = pathParts.pop();
    
    // Navigate to or create subdirectories
    let currentDir = directoryHandle;
    for (const dirName of pathParts) {
      currentDir = await currentDir.getDirectoryHandle(dirName, { create: true });
    }

    // Create or get file handle
    const fileHandle = await currentDir.getFileHandle(fileName, { create: true });

    // Check if we still have permission
    const permission = await fileHandle.requestPermission({ mode: 'readwrite' });
    if (permission !== 'granted') {
      console.error('Permission not granted to write file');
      return false;
    }

    // Write the file
    const writable = await fileHandle.createWritable();
    await writable.write(data);
    await writable.close();

    return true;
  } catch (error) {
    console.error('Error saving file:', error);
    return false;
  }
}

/**
 * Read a file from the selected directory
 * @param {string} path - The relative path within the directory
 * @returns {Promise<Uint8Array|null>} The file data or null if read failed
 */
async function readFile(path) {
  try {
    if (!directoryHandle) {
      console.error('No directory handle available');
      return null;
    }

    // Split path into directory parts and filename
    const pathParts = path.split('/').filter(p => p.length > 0);
    const fileName = pathParts.pop();
    
    // Navigate to subdirectories
    let currentDir = directoryHandle;
    for (const dirName of pathParts) {
      try {
        currentDir = await currentDir.getDirectoryHandle(dirName);
      } catch (error) {
        console.error(`Directory not found: ${dirName}`);
        return null;
      }
    }

    // Get file handle
    const fileHandle = await currentDir.getFileHandle(fileName);
    const file = await fileHandle.getFile();
    const arrayBuffer = await file.arrayBuffer();
    return new Uint8Array(arrayBuffer);
  } catch (error) {
    console.error('Error reading file:', error);
    return null;
  }
}

/**
 * List files in a directory
 * @param {string} path - The relative path within the directory (empty string for root)
 * @returns {Promise<Array<{name: string, isDirectory: boolean}>>} List of entries
 */
async function listDirectory(path) {
  try {
    if (!directoryHandle) {
      console.error('No directory handle available');
      return [];
    }

    // Navigate to the target directory
    let currentDir = directoryHandle;
    if (path && path.length > 0) {
      const pathParts = path.split('/').filter(p => p.length > 0);
      for (const dirName of pathParts) {
        try {
          currentDir = await currentDir.getDirectoryHandle(dirName);
        } catch (error) {
          console.error(`Directory not found: ${dirName}`);
          return [];
        }
      }
    }

    // List entries
    const entries = [];
    for await (const entry of currentDir.values()) {
      entries.push({
        name: entry.name,
        isDirectory: entry.kind === 'directory'
      });
    }

    return entries;
  } catch (error) {
    console.error('Error listing directory:', error);
    return [];
  }
}

/**
 * Delete a file from the selected directory
 * @param {string} path - The relative path within the directory
 * @returns {Promise<boolean>} True if deletion was successful
 */
async function deleteFile(path) {
  try {
    if (!directoryHandle) {
      console.error('No directory handle available');
      return false;
    }

    // Split path into directory parts and filename
    const pathParts = path.split('/').filter(p => p.length > 0);
    const fileName = pathParts.pop();
    
    // Navigate to parent directory
    let currentDir = directoryHandle;
    for (const dirName of pathParts) {
      currentDir = await currentDir.getDirectoryHandle(dirName);
    }

    // Remove the file
    await currentDir.removeEntry(fileName);
    return true;
  } catch (error) {
    console.error('Error deleting file:', error);
    return false;
  }
}

/**
 * Check if File System Access API is supported
 * @returns {boolean} True if supported
 */
function isFileSystemAccessSupported() {
  return 'showDirectoryPicker' in window;
}

/**
 * Clear the stored directory handle
 */
function clearDirectoryAccess() {
  directoryHandle = null;
}

// Expose functions to Flutter
window.fileSystemAccess = {
  requestDirectoryAccess,
  hasDirectoryAccess,
  getDirectoryName,
  saveFile,
  readFile,
  listDirectory,
  deleteFile,
  isFileSystemAccessSupported,
  clearDirectoryAccess
};
