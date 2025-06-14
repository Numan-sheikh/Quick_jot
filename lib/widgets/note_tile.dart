// widgets/note_tile.dart
import 'package:flutter/material.dart';

class NoteTile extends StatelessWidget {
  final String title;
  final String content;
  final Widget? trailing; // Existing trailing widget (e.g., date)
  final VoidCallback? onTap;
  final VoidCallback? onLongPress; // New: Callback for long press
  final List<String> labels;
  final bool isPinned;
  final bool isSelected; // New: Indicates if the note is selected
  final Color noteColor; // New: Background color for the note card

  const NoteTile({
    super.key,
    required this.title,
    required this.content,
    this.trailing,
    this.onTap,
    this.onLongPress, // Initialize long press
    this.labels = const [],
    this.isPinned = false,
    this.isSelected = false, // Default to false
    this.noteColor = Colors.white, // Default to white
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine the card's background color
    final cardColor =
        isSelected
            ? theme.colorScheme.primaryContainer.withAlpha(
              128,
            ) // Highlight color when selected
            : noteColor.withAlpha(51); // Use provided note color with opacity

    return Card(
      elevation: isSelected ? 4.0 : 2.0, // Higher elevation when selected
      color: cardColor, // Apply calculated color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side:
            isSelected
                ? BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2.0,
                ) // Border when selected
                : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        onLongPress: onLongPress, // Use the new long press callback
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show pin icon if pinned
                  if (isPinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.push_pin,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title.isEmpty
                          ? 'Untitled'
                          : title, // Show 'Untitled' if title is empty
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing != null) trailing!,
                  if (isSelected) // Show a checkmark when selected
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(179),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              // Display Labels
              if (labels.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Wrap(
                    spacing: 8.0, // Space between chips
                    runSpacing: 4.0, // Space between lines of chips
                    children:
                        labels
                            .map(
                              (label) => Chip(
                                label: Text(label),
                                labelStyle: theme.textTheme.labelSmall,
                                backgroundColor: theme
                                    .colorScheme
                                    .secondaryContainer
                                    .withAlpha(102),
                                side: BorderSide.none, // No border
                                padding: EdgeInsets.zero, // No internal padding
                                visualDensity:
                                    VisualDensity.compact, // Compact size
                              ),
                            )
                            .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
