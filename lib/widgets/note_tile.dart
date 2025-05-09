import 'package:flutter/material.dart';

class NoteTile extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onTap;
  // Added an optional color parameter to allow different note background colors
  // You would need to add a color property to your Note model and pass it here.
  // For demonstration, we'll use a default color.
  final Color? noteColor;
  // Keep isGridView if you plan to support grid view on the home screen later
  final bool isGridView;

  const NoteTile({
    super.key,
    required this.title,
    required this.content,
    required this.onTap,
    this.noteColor, // Optional color
    this.isGridView = false, // Keep this for future grid layout
  });

  // Helper function to get a default Keep-like color if none is provided
  Color _getDefaultNoteColor(BuildContext context) {
    final theme = Theme.of(context);
    // Use a light yellow/beige for light theme, a subtle dark grey for dark theme
    return theme.brightness == Brightness.light
        ? const Color(0xFFFFF7C6) // Keep-like light yellow
        : const Color(0xFF3B3B3B); // Subtle dark grey for dark mode
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use the provided color or the default color
    final tileColor = noteColor ?? _getDefaultNoteColor(context);

    return Card(
      // Using Card provides built-in elevation and shape
      color: tileColor,
      elevation: 2.0, // Subtle elevation for a card look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          12,
        ), // Slightly less rounded than 20
      ),
      // Wrap in InkWell for tap effect
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12), // Match Card's border radius
        splashFactory: InkRipple.splashFactory, // Use default ripple effect
        child: Padding(
          padding: const EdgeInsets.all(
            16.0,
          ), // Consistent padding inside the card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Column takes minimum space
            children: [
              // Title
              if (title.isNotEmpty) // Only show title if not empty
                Column(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        // Adjust color based on background brightness for readability
                        color:
                            tileColor.computeLuminance() > 0.5
                                ? Colors.black87
                                : Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 8,
                    ), // Space between title and content
                  ],
                ),

              // Content Snippet
              if (content.isNotEmpty) // Only show content if not empty
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    // Adjust color based on background brightness for readability
                    color:
                        tileColor.computeLuminance() > 0.5
                            ? Colors
                                .black54 // Darker text for light backgrounds
                            : Colors
                                .white60, // Lighter text for dark backgrounds
                    height: 1.4, // Line height for readability
                  ),
                  maxLines: isGridView ? 6 : 3, // More lines in grid view
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
