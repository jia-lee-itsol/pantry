import '../entities/household_request.dart';

/// 공동관리 요청 관리를 위한 Repository 인터페이스
abstract class HouseholdRequestRepository {
  /// 공동관리 요청 생성
  Future<HouseholdRequest> createRequest({
    required String senderId,
    required String senderUsername,
    required String? senderDisplayName,
    required String? senderPhotoUrl,
    required String receiverId,
    required String receiverUsername,
    required String householdId,
    required String householdName,
  });

  /// 요청 ID로 요청 조회
  Future<HouseholdRequest?> getRequest(String requestId);

  /// 받은 요청 목록 조회
  Future<List<HouseholdRequest>> getReceivedRequests(String userId);

  /// 받은 요청 실시간 감시
  Stream<List<HouseholdRequest>> watchReceivedRequests(String userId);

  /// 보낸 요청 목록 조회
  Future<List<HouseholdRequest>> getSentRequests(String userId);

  /// 보낸 요청 실시간 감시
  Stream<List<HouseholdRequest>> watchSentRequests(String userId);

  /// 요청 상태를 수락으로 업데이트
  Future<void> updateRequestStatusToAccepted(String requestId);

  /// 요청 상태를 거절로 업데이트
  Future<void> updateRequestStatusToRejected(String requestId);

  /// 요청 삭제 (취소)
  Future<void> deleteRequest(String requestId);

  /// 중복 요청 확인
  Future<bool> hasExistingPendingRequest({
    required String senderId,
    required String receiverId,
  });
}
