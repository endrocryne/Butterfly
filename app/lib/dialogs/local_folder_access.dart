import 'package:butterfly/api/file_system_access.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:butterfly/src/generated/i18n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Dialog to configure local folder access using the File System Access API
class LocalFolderAccessDialog extends StatefulWidget {
  const LocalFolderAccessDialog({super.key});

  @override
  State<LocalFolderAccessDialog> createState() =>
      _LocalFolderAccessDialogState();
}

class _LocalFolderAccessDialogState extends State<LocalFolderAccessDialog> {
  final _service = FileSystemAccessService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final hasAccess = _service.hasDirectoryAccess();
    final directoryName = _service.getDirectoryName();

    return AlertDialog(
      title: Row(
        children: [
          PhosphorIcon(PhosphorIconsLight.folder),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).localFolder),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).localFolderDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (hasAccess && directoryName != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).connectedTo,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            directoryName,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
      actions: [
        if (hasAccess) ...[
          TextButton(
            onPressed: () {
              _service.clearDirectoryAccess();
              Navigator.of(context).pop(false);
            },
            child: Text(AppLocalizations.of(context).disconnect),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _requestAccess,
          child: Text(
            hasAccess
                ? AppLocalizations.of(context).changeFolder
                : AppLocalizations.of(context).selectFolder,
          ),
        ),
      ],
    );
  }

  Future<void> _requestAccess() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _service.requestDirectoryAccess();
      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _errorMessage = AppLocalizations.of(context).folderAccessDenied;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }
}

/// Show the local folder access dialog
Future<bool?> showLocalFolderAccessDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => const LocalFolderAccessDialog(),
  );
}
