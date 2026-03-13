import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/household_request.dart';
import '../models/household_request_model.dart';

/// 공동관리 요청 Firestore 데이터소스
/// 순수 데이터 접근만 담당 (비즈니스 로직 없음)
class HouseholdRequestFirestoreDataSource {
  final FirebaseFirestore _firestore;

  static const String _householdRequestsCollection = 'household_requests';

  HouseholdRequestFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _requestsRef =>
      _firestore.collection(_householdRequestsCollection);

  /// 요청 생성
  Future<HouseholdRequest> createRequest({
    required String senderId,
    required String senderUsername,
    required String? senderDisplayName,
    required String? senderPhotoUrl,
    required String receiverId,
    required String receiverUsername,
    required String householdId,
    required String householdName,
  }) async {
    final docRef = _requestsRef.doc();
    final now = DateTime.now();

    final request = HouseholdRequestModel(
      id: docRef.id,
      senderId: senderId,
      senderUsername: senderUsername,
      senderDisplayName: senderDisplayName,
      senderPhotoUrl: senderPhotoUrl,
      receiverId: receiverId,
      receiverUsername: receiverUsername,
      householdId: householdId,
      householdName: householdName,
      status: HouseholdRequestStatus.pending,
      createdAt: now,
    );

    await docRef.set(request.toMap());
    return request;
  }

  /// 요청 ID로 요청 조회
  Future<HouseholdRequest?> getRequest(String requestId) async {
    final doc = await _requestsRef.doc(requestId).get();
    if (!doc.exists) return null;
    return HouseholdRequestModel.fromFirestore(doc);
  }

  /// 받은 요청 목록 조회
  Future<List<HouseholdRequest>> getReceivedRequests(String userId) async {
    final snapshot = await _requestsRef
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HouseholdRequestModel.fromFirestore(doc))
        .toList();
  }

  /// 받은 요청 실시간 감시
  Stream<List<HouseholdRequest>> watchReceivedRequests(String userId) {
    return _requestsRef
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HouseholdRequestModel.fromFirestore(doc))
            .toList());
  }

  /// 보낸 요청 목록 조회
  Future<List<HouseholdRequest>> getSentRequests(String userId) async {
    final snapshot = await _requestsRef
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HouseholdRequestModel.fromFirestore(doc))
        .toList();
  }

  /// 보낸 요청 실시간 감시
  Stream<List<HouseholdRequest>> watchSentRequests(String userId) {
    return _requestsRef
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HouseholdRequestModel.fromFirestore(doc))
            .toList());
  }

  /// 요청 상태를 수락으로 업데이트
  Future<void> updateRequestStatusToAccepted(String requestId) async {
    final now = DateTime.now();
    await _requestsRef.doc(requestId).update({
      'status': 'accepted',
      'respondedAt': Timestamp.fromDate(now),
    });
  }

  /// 요청 상태를 거절로 업데이트
  Future<void> updateRequestStatusToRejected(String requestId) async {
    final now = DateTime.now();
    await _requestsRef.doc(requestId).update({
      'status': 'rejected',
      'respondedAt': Timestamp.fromDate(now),
    });
  }

  /// 요청 삭제
  Future<void> deleteRequest(String requestId) async {
    await _requestsRef.doc(requestId).delete();
  }

  /// 중복 요청 확인
  Future<bool> hasExistingPendingRequest({
    required String senderId,
    required String receiverId,
  }) async {
    final snapshot = await _requestsRef
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
