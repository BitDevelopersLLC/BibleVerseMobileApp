import 'package:flutter/material.dart';

/// A numbered list of instructions.
class NumberedSteps extends StatelessWidget {
  /// Creates a list from [steps], numbered from 1.
  const NumberedSteps({required this.steps, super.key});

  /// The instructions, in order.
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final (index, step) in steps.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 13, child: Text('${index + 1}', style: textTheme.labelMedium)),
                const SizedBox(width: 12),
                Expanded(child: Text(step, style: textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}
