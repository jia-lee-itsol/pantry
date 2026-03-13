import '../../domain/entities/household_request.dart';
import '../../domain/repositories/household_request_repository.dart';
import '../datasources/household_request_firestore_datasource.dart';

class HouseholdRequestRepositoryImpl implements HouseholdRequestRepository {
  final HouseholdRequestFirestoreDataSource _dataSource;

  HouseholdRequestRepositoryImpl(this._dataSource);

  @override
  Future<HouseholdRequest> createRequest({
    required String senderId,
    required String senderUsername,
    required String? senderDisplayName,
    required String? senderPhotoUrl,
    required String receiverId,
    required String receiverUsername,
    required String householdId,
    required String householdName,
  }) {
    return _dataSource.createRequest(
      senderId: senderId,
      senderUsername: senderUsername,
      senderDisplayName: senderDisplayName,
      senderPhotoUrl: senderPhotoUrl,
      receiverId: receiverId,
      receiverUsername: receiverUsername,
      householdId: householdId,
      householdName: householdName,
    );
  }

  @override
  Future<HouseholdRequest?> getRequest(String requestId) {
    return _dataSource.getRequest(requestId);
  }

  @override
  Future<List<HouseholdRequest>> getReceivedRequests(String userId) {
    return _dataSource.getReceivedRequests(userId);
  }

  @override
  Stream<List<HouseholdRequest>> watchReceivedRequests(String userId) {
    return _dataSource.watchReceivedRequests(userId);
  }

  @override
  Future<List<HouseholdRequest>> getSentRequests(String userId) {
    return _dataSource.getSentRequests(userId);
  }

  @override
  Stream<List<HouseholdRequest>> watchSentRequests(String userId) {
    return _dataSource.watchSentRequests(userId);
  }

  @override
  Future<void> updateRequestStatusToAccepted(String requestId) {
    return _dataSource.updateRequestStatusToAccepted(requestId);
  }

  @override
  Future<void> updateRequestStatusToRejected(String requestId) {
    return _dataSource.updateRequestStatusToRejected(requestId);
  }

  @override
  Future<void> deleteRequest(String requestId) {
    return _dataSource.deleteRequest(requestId);
  }

  @override
  Future<bool> hasExistingPendingRequest({
    required String senderId,
    required String receiverId,
  }) {
    return _dataSource.hasExistingPendingRequest(
      senderId: senderId,
      receiverId: receiverId,
    );
  }
}
