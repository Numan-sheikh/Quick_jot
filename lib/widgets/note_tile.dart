import 'package:flutter/material.dart';

class NoteTile extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onTap;
  final Widget? trailing; // Added for the date or any other trailing widget

  const NoteTile({
    super.key,
    required this.title,
    required this.content,
    required this.onTap,
    this.trailing, // Accept the trailing widget from the HomeScreen
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      // By NOT setting 'color', 'elevation', 'shape', or 'shadowColor' here,
      // the Card will now automatically use the values defined in AppTheme's CardTheme.
      child: InkWell(
        onTap: onTap,
        // Match the border radius defined in AppTheme's CardTheme for InkWell splash effect
        borderRadius: BorderRadius.circular(
          12,
        ), // Assumes your CardTheme has 12 radius
        splashFactory: InkRipple.splashFactory,
        child: Padding(
          padding: const EdgeInsets.all(
            16.0,
          ), // Consistent padding inside the card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Column takes minimum space
            children: [
              Row(
                // Use a Row to place title and trailing widget side-by-side
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        // Use theme's onSurface color for text on the card
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing !=
                      null) // Display trailing widget if provided (e.g., date)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: trailing!,
                    ),
                ],
              ),
              const SizedBox(height: 8), // Space between title and content
              // Content Snippet
              if (content.isNotEmpty) // Only show content if not empty
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    // Use theme's onSurface color with an opacity for content text
                    // FIX: Replaced .withOpacity(0.7) with .withAlpha(179)
                    color: theme.colorScheme.onSurface.withAlpha(
                      179,
                    ), // 70% opaque (255 * 0.7 = 178.5)
                    height: 1.4, // Line height for readability
                  ),
                  maxLines: 3, // Keep maxLines for list view
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
