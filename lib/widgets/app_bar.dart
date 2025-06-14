// widgets/app_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For consistent text styling

class QuickJotAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;
  final String? userDisplayName;
  final String? userEmail;
  final String? userPhotoUrl;

  // New properties to manage selection mode
  final bool inSelectionMode; // True if notes are currently selected
  final int selectedNotesCount; // Number of notes currently selected
  final VoidCallback
  onCancelSelection; // Callback when 'X' or back arrow in selection mode is pressed

  // Callbacks for actions when notes are selected
  final VoidCallback? onSelectedNotesDelete;
  final VoidCallback? onSelectedNotesCopy;
  final VoidCallback? onSelectedNotesLabels;
  final VoidCallback? onSelectedNotesColor;
  final VoidCallback? onSelectedNotesPin; // Will handle both pin and unpin

  const QuickJotAppBar({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.onMenuPressed,
    this.onProfilePressed,
    this.userDisplayName,
    this.userEmail,
    this.userPhotoUrl,
    // Initialize new parameters with default values
    this.inSelectionMode = false,
    this.selectedNotesCount = 0,
    required this.onCancelSelection, // This must always be provided
    this.onSelectedNotesDelete,
    this.onSelectedNotesCopy,
    this.onSelectedNotesLabels,
    this.onSelectedNotesColor,
    this.onSelectedNotesPin,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16.0); // Consistent app bar height

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine the background color for the search bar (or selection bar)
    final barBackgroundColor =
        inSelectionMode
            ? theme.colorScheme.primaryContainer.withAlpha(
              188,
            ) // Highlight color for selection mode
            : isDark
            ? theme.colorScheme.surface.withAlpha(200)
            : theme.colorScheme.surface.withAlpha(240);

    // Determine the text/icon color for the bar
    final barForegroundColor =
        inSelectionMode
            ? theme
                .colorScheme
                .onPrimaryContainer // Contrast color for selection mode
            : isDark
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurface;

    return AppBar(
      backgroundColor:
          Colors
              .transparent, // Make the AppBar itself transparent for custom background
      elevation: 0, // Remove shadow
      automaticallyImplyLeading: false, // We handle leading icon manually
      titleSpacing: 0, // Remove default title spacing
      // The leading icon changes based on selection mode
      leading: IconButton(
        // If in selection mode, show a back arrow to cancel selection
        // Otherwise, show the menu icon to open the drawer
        icon:
            inSelectionMode
                ? const Icon(Icons.arrow_back)
                : const Icon(Icons.menu),
        color: barForegroundColor,
        // The onPressed action also changes based on the mode
        onPressed: inSelectionMode ? onCancelSelection : onMenuPressed,
        tooltip: inSelectionMode ? 'Cancel Selection' : 'Open Navigation Menu',
      ),

      // The title section changes based on selection mode
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: barBackgroundColor, // Apply dynamic background color
            borderRadius: BorderRadius.circular(32.0), // Fully rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(
                  isDark ? 80 : 20,
                ), // Subtle shadow
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              inSelectionMode
                  ?
                  // Display selected notes count when in selection mode
                  Align(
                    alignment: Alignment.centerLeft, // Align text to the left
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                      ), // Add some padding
                      child: Text(
                        '$selectedNotesCount Selected',
                        style: GoogleFonts.poppins(
                          color: barForegroundColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  :
                  // Display the search bar in normal mode
                  Row(
                    children: [
                      // The leading menu icon is now part of the AppBar's `leading` property
                      // so we remove it from here.
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search your notes',
                            hintStyle: GoogleFonts.poppins(
                              color: barForegroundColor.withAlpha(
                                150,
                              ), // Lighter hint text
                              fontSize: 16,
                            ),
                            border:
                                InputBorder
                                    .none, // Remove default TextField border
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                          ),
                          style: GoogleFonts.poppins(
                            color: barForegroundColor,
                            fontSize: 16,
                          ),
                          cursorColor:
                              theme
                                  .colorScheme
                                  .primary, // Cursor color matches primary
                        ),
                      ),
                      // The profile button is now part of the AppBar's `actions` property
                      // so we remove it from here.
                    ],
                  ),
        ),
      ),

      // The actions (buttons on the right) change based on selection mode
      actions:
          inSelectionMode
              ? [
                // Actions when notes are selected
                // Pin/Unpin Icon
                if (onSelectedNotesPin != null)
                  IconButton(
                    icon: const Icon(
                      Icons.push_pin_outlined,
                    ), // Will show filled/outlined based on logic in HomeScreen
                    color: barForegroundColor,
                    onPressed: onSelectedNotesPin,
                    tooltip: 'Pin/Unpin Note(s)',
                  ),
                // Set Color Icon
                if (onSelectedNotesColor != null)
                  IconButton(
                    icon: const Icon(Icons.palette_outlined),
                    color: barForegroundColor,
                    onPressed: onSelectedNotesColor,
                    tooltip: 'Set Note Color',
                  ),
                // Labels Icon
                if (onSelectedNotesLabels != null)
                  IconButton(
                    icon: const Icon(Icons.label_outline),
                    color: barForegroundColor,
                    onPressed: onSelectedNotesLabels,
                    tooltip: 'Assign Label(s)',
                  ),
                // More Options (3 dots)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete' && onSelectedNotesDelete != null) {
                      onSelectedNotesDelete!();
                    } else if (value == 'copy' && onSelectedNotesCopy != null) {
                      onSelectedNotesCopy!();
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete Note(s)'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'copy',
                          child: Text('Make a Copy'),
                        ),
                      ],
                  icon: Icon(Icons.more_vert, color: barForegroundColor),
                  tooltip: 'More Options',
                ),
                // Cross icon to cancel selection (always available in selection mode)
                IconButton(
                  icon: const Icon(Icons.close),
                  color: barForegroundColor,
                  onPressed: onCancelSelection,
                  tooltip: 'Cancel Selection',
                ),
              ]
              : [
                // Normal actions (when no notes are selected)
                // Profile Button
                TextButton(
                  onPressed: onProfilePressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.primary.withAlpha(200),
                    backgroundImage:
                        userPhotoUrl?.isNotEmpty == true
                            ? NetworkImage(userPhotoUrl!)
                            : null,
                    child:
                        userPhotoUrl?.isEmpty ?? true
                            ? Text(
                              userDisplayName?.isNotEmpty == true
                                  ? userDisplayName![0].toUpperCase()
                                  : (userEmail?.isNotEmpty == true
                                      ? userEmail![0].toUpperCase()
                                      : 'U'),
                              style: GoogleFonts.poppins(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                ),
              ],
    );
  }
}
