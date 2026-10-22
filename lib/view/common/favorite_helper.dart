// lib/view/common/favorite_helper.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class FavoriteHelper {
  /// Handles adding/removing a favorite and showing session expired dialogs.
  /// Returns `true` if the action was successful, `false` otherwise.
  static Future<bool> toggleFavorite(
    BuildContext context, {
    required int productId,
    required bool isCurrentlyFavorite,
  }) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // 1) Check if logged in
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog(context);
      return false;
    }

    // 2) Try to add or remove
    bool success = false;
    if (isCurrentlyFavorite) {
      success = await authService.removeFavorite(productId);
    } else {
      success = await authService.addFavorite(productId);
    }

    // 3) Handle result
    if (!context.mounted) return false;

    if (success) {
      // Refresh the global favorites list to sync hearts
      await authService.getUserFavorites();
      
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCurrentlyFavorite ? 'Removed from favourites' : 'Added to favourites ❤️'),
          duration: const Duration(seconds: 1),
        ),
      );
      return true;
    } else {
      //  Handle Session Timeout (401)
      final error = authService.errorMessage?.toLowerCase() ?? '';
      if (error.contains('401') || error.contains('unauthorized') || error.contains('session has expired')) {
        _showSessionExpiredDialog(context);
      } else {
        // Show standard error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Could not update favourite'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  static void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFFC77C2E), size: 28),
            SizedBox(width: 10),
            Text('Login Required', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Please sign in to save favourites or access this feature.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog first
              context.go('/login'); // Then navigate
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B6E3B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static void _showSessionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock, color: Color(0xFFC77C2E), size: 28),
            SizedBox(width: 10),
            Text("Session Expired", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Your session has expired or you are not logged in.\n\n"
          "Please log in to continue.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC77C2E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push('/login');
            },
            child: const Text("Log In", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}