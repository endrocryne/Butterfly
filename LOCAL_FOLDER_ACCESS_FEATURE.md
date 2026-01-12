# Local Folder Access Feature for Web

## Overview

This feature enables the Butterfly web app to save notes directly to a folder on the user's device using the File System Access API. This allows for better integration with the local file system and provides a way to keep files synchronized between the app and a local directory.

## Browser Support

The File System Access API is supported in:
- Chrome/Edge 86+
- Opera 72+

Not supported in:
- Firefox (as of 2026)
- Safari (as of 2026)

## How to Use

1. Open the Butterfly web app in a supported browser
2. Navigate to the Files view
3. Click on the folder icon button next to the "Source" dropdown (only visible when "Local" is selected as the source)
4. Click "Select folder" in the dialog that appears
5. Choose a folder on your device where you want to save your notes
6. Grant permission when prompted by the browser
7. Your notes will now be automatically saved to both IndexedDB (for the app) and the selected local folder

## Implementation Details

### Files Added

- `app/web/file_system_access.js` - JavaScript wrapper for the File System Access API
- `app/lib/api/file_system_access.dart` - Main export file
- `app/lib/api/file_system_access_web.dart` - Web implementation using dart:js_interop
- `app/lib/api/file_system_access_stub.dart` - Stub implementation for non-web platforms
- `app/lib/dialogs/local_folder_access.dart` - Dialog UI for selecting and managing folder access

### Files Modified

- `app/web/index.html` - Added script tag to include file_system_access.js
- `app/lib/cubits/current_index.dart` - Added logic to save to local folder after saving to IndexedDB
- `app/lib/views/files/view.dart` - Added button to access local folder dialog
- `app/lib/l10n/app_en.arb` - Added localization strings

## Technical Details

### How It Works

1. When the user clicks the folder icon, a dialog appears
2. The user can select a folder using the browser's native folder picker
3. The browser stores a handle to the selected folder
4. When saving a note, the app:
   - First saves to IndexedDB (existing behavior)
   - Then saves to the selected local folder (new behavior)
5. Files are saved with their full path structure (e.g., `/Documents/MyNote.bfly`)

### Security

- The File System Access API requires explicit user permission for each folder
- The browser will prompt the user to confirm access
- The handle is only valid for the current browser session
- Users can disconnect at any time using the dialog

### Limitations

- The folder handle is not persisted across browser sessions
- Users need to re-select the folder after closing and reopening the browser
- Only works on supported browsers
- Requires user interaction to grant permissions

## Testing

### Manual Testing Steps

To test this feature manually:

1. **Build the web app**
   ```bash
   cd app
   flutter build web --release
   ```

2. **Serve the web app locally**
   ```bash
   # Using Python
   cd build/web
   python -m http.server 8000
   
   # Or using the Flutter development server
   flutter run -d chrome
   ```

3. **Test the feature**
   - Open the app in Chrome or Edge
   - Navigate to the Files view (sidebar)
   - Ensure "Local" is selected as the source in the dropdown
   - Look for the folder icon button (should appear next to the sync button area)
   - Click the folder icon
   - In the dialog, click "Select folder"
   - Choose a folder on your device (e.g., Documents/ButterflyNotes)
   - Grant permission when prompted by the browser
   - Dialog should show "Connected to: [folder name]"
   - Click outside to close the dialog

4. **Verify saving**
   - Create a new note or edit an existing one
   - Make some changes
   - Save the note (Ctrl+S or auto-save)
   - Check the selected folder on your device
   - The .bfly file should appear in the folder

5. **Test folder structure**
   - Create notes in subdirectories within the app
   - Verify the folder structure is preserved in the local folder

6. **Test disconnection**
   - Click the folder icon again
   - Click "Disconnect"
   - Verify the icon changes back to outlined folder
   - Save a note - it should only save to IndexedDB, not the local folder

### Expected Behaviors

- ✅ Folder button only appears on web when Local source is selected
- ✅ Button is hidden on unsupported browsers (Firefox, Safari)
- ✅ Clicking button opens a dialog with clear instructions
- ✅ Browser's native folder picker appears when selecting folder
- ✅ Dialog shows connection status after folder selection
- ✅ Files are saved to both IndexedDB and local folder
- ✅ Folder structure is preserved (subdirectories are created)
- ✅ Icon changes between outlined and filled states
- ✅ Tooltip shows folder name when connected

### Browser-Specific Testing

**Chrome/Edge (Supported)**
- All features should work
- Native folder picker appears
- Files save successfully to local folder

**Firefox (Not Supported)**
- Folder button should not appear
- App functions normally with IndexedDB only

**Safari (Not Supported)**
- Folder button should not appear
- App functions normally with IndexedDB only

### Error Scenarios to Test

1. **Permission Denied**
   - Select folder but deny permission
   - Should show error message in dialog
   - Should not crash the app

2. **Folder Deleted**
   - Select a folder
   - Delete the folder from file system
   - Try to save
   - Should log error but not crash

3. **Permission Lost**
   - Select a folder
   - Browser session continues
   - Permission might be re-requested on next save

## Future Enhancements

Potential improvements for this feature:

- Persist folder selection using IndexedDB or browser storage
- Add option to restore from local folder on startup
- Implement bi-directional sync (read from folder)
- Add conflict resolution for when files differ
- Support for multiple folder mappings
