import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

// ============================================
// User Profile Model
// ============================================

/// Data model for UserProfile with Firestore serialization.
///
/// This class extends [UserProfile] entity and provides methods for
/// converting between Firestore documents and domain entities.
///
/// Responsibilities:
/// - Serialize/deserialize UserProfile to/from Firestore
/// - Convert between entity and model representations
/// - Handle Firestore-specific data formats
///
/// Example:
/// ```dart
/// // From Firestore
/// final model = UserProfileModel.fromFirestore(documentSnapshot);
/// final entity = model.toEntity();
///
/// // To Firestore
/// final model = UserProfileModel.fromEntity(userProfile);
/// await firestore.collection('users').doc(id).set(model.toMap());
/// ```
class UserProfileModel extends UserProfile {
  /// Creates a new UserProfileModel.
  ///
  /// Parameters:
  /// - [id]: Required unique user identifier
  /// - [username]: Required unique username
  /// - [displayName]: Optional display name
  /// - [photoUrl]: Optional profile photo URL
  const UserProfileModel({
    required super.id,
    required super.username,
    super.displayName,
    super.photoUrl,
  });

  /// Creates a UserProfileModel from a UserProfile entity.
  ///
  /// Parameters:
  /// - [profile]: The UserProfile entity to convert
  ///
  /// Returns a new [UserProfileModel] with the same properties.
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      username: profile.username,
      displayName: profile.displayName,
      photoUrl: profile.photoUrl,
    );
  }

  /// Creates a UserProfileModel from a Firestore DocumentSnapshot.
  ///
  /// Parameters:
  /// - [doc]: The Firestore document snapshot
  ///
  /// Returns a new [UserProfileModel] populated from the document data.
  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserProfileModel(
      id: doc.id,
      username: data['username'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  /// Creates a UserProfileModel from a Map and document ID.
  ///
  /// Parameters:
  /// - [id]: The document/user ID
  /// - [data]: The map containing user profile data
  ///
  /// Returns a new [UserProfileModel] populated from the map.
  factory UserProfileModel.fromMap(String id, Map<String, dynamic> data) {
    return UserProfileModel(
      id: id,
      username: data['username'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  /// Converts this model to a Map for Firestore storage.
  ///
  /// Returns a [Map<String, dynamic>] containing the profile data.
  /// The ID is not included as it's typically stored as the document ID.
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  /// Converts this model to a UserProfile entity.
  ///
  /// Returns a [UserProfile] entity with the same properties.
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      username: username,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
