import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

/// Firebase Initializer
///
/// Handles Firebase initialization and configuration for the application.
/// This must be called before any Firebase services are used.
///
/// Features:
/// - Platform-specific Firebase initialization
/// - Firestore offline persistence enabled
/// - Unlimited cache size for offline functionality
///
/// All methods are static and do not require instantiation.
class FirebaseInitializer {
  /// Initializes Firebase and configures Firestore
  ///
  /// This method should be called once during app startup, typically
  /// in the main() function before runApp().
  ///
  /// Configuration:
  /// - Uses platform-specific Firebase options
  /// - Enables Firestore offline persistence
  /// - Sets unlimited cache size for better offline experience
  ///
  /// Throws: Exception if Firebase initialization fails
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable Firestore offline persistence
    try {
      final firestore = FirebaseFirestore.instance;
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      // Ignore persistence setup failures (e.g., already configured)
    }
  }
}
