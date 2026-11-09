import 'package:flutter/material.dart';

/// A small, deliberately understated "?" at the bottom of the main screen.
///
/// Tapping it shows a personal dedication from the app's creator.
class DedicationNote extends StatelessWidget {
  /// Creates the dedication button.
  const DedicationNote({super.key});

  /// The message shown when the button is tapped.
  static const message =
      "This app was my wife Nisha's idea. God bless her and her heart. I love you!";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: IconButton(
        // Keeps a normal-size tap target while the icon itself stays small and faint.
        icon: const Icon(Icons.help_outline, size: 16),
        color: theme.colorScheme.outline.withValues(alpha: 0.45),
        tooltip: 'A note',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(message, style: theme.textTheme.bodyLarge),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          ),
        ),
      ),
    );
  }
}
