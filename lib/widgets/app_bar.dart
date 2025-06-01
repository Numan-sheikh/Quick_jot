import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For consistent text styling

class QuickJotAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;
  final String? userDisplayName; // User's display name
  final String? userEmail; // User's email
  final String? userPhotoUrl; // New: User's profile photo URL

  const QuickJotAppBar({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.onMenuPressed,
    this.onProfilePressed,
    this.userDisplayName,
    this.userEmail,
    this.userPhotoUrl, // Initialize new parameter
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16.0); // Standard app bar height + some padding

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine the background color for the search bar based on theme
    final searchBarBackgroundColor =
        isDark
            ? theme.colorScheme.surface.withAlpha(
              200,
            ) // Slightly transparent dark surface
            : theme.colorScheme.surface.withAlpha(
              240,
            ); // Slightly transparent light surface

    // Determine the text color for the search bar
    final searchBarTextColor =
        isDark
            ? theme
                .colorScheme
                .onSurface // White for dark mode
            : theme.colorScheme.onSurface; // Black for light mode

    return AppBar(
      backgroundColor: Colors.transparent, // Make the AppBar itself transparent
      elevation: 0, // Remove shadow
      automaticallyImplyLeading: false, // We'll handle leading icon manually

      titleSpacing: 0, // Remove default title spacing
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: searchBarBackgroundColor,
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
          child: Row(
            children: [
              // Menu Icon Button
              IconButton(
                icon: const Icon(Icons.menu),
                color: searchBarTextColor,
                onPressed: onMenuPressed,
                tooltip: 'Menu',
              ),
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search your notes',
                    hintStyle: GoogleFonts.poppins(
                      color: searchBarTextColor.withAlpha(
                        150,
                      ), // Lighter hint text
                      fontSize: 16,
                    ),
                    border: InputBorder.none, // Remove default TextField border
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                  style: GoogleFonts.poppins(
                    color: searchBarTextColor,
                    fontSize: 16,
                  ),
                  cursorColor:
                      theme.colorScheme.primary, // Cursor color matches primary
                ),
              ),
              // Profile Button (now only showing picture/initial)
              TextButton(
                // Using TextButton for a clickable area
                onPressed: onProfilePressed,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ), // Adjust padding
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                ),
                child: CircleAvatar(
                  radius: 16, // Smaller avatar
                  backgroundColor: theme.colorScheme.primary.withAlpha(
                    200,
                  ), // Primary color with transparency
                  backgroundImage:
                      userPhotoUrl?.isNotEmpty == true
                          ? NetworkImage(
                            userPhotoUrl!,
                          ) // Use network image if URL is provided
                          : null, // No background image if no URL
                  child:
                      userPhotoUrl?.isEmpty ??
                              true // Only show text if no photo URL
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
                          : null, // No text if photo URL is provided
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// This widget can be used in your main app widget or wherever you need the app bar