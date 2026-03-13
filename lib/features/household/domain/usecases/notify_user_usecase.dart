import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// 사용자 알림 전송 UseCase
class NotifyUserUseCase {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  static const String _usersCollection = 'users';
  static const String _alertsCollection = 'alerts';

  NotifyUserUseCase({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 공동관리 요청 알림 전송
  Future<void> notifyHouseholdRequest({
    required String receiverId,
    required String senderName,
    required String householdName,
    required String requestId,
  }) async {
    await _createAlert(
      userId: receiverId,
      type: 'householdRequest',
      title: '공동관리 초대가 도착했습니다',
      message: '$senderNameさんが「$householdName」への参加を招待しています。',
      metadata: {
        'requestId': requestId,
        'action': 'view_request',
      },
    );
  }

  /// 요청 수락 알림 전송
  Future<void> notifyRequestAccepted({
    required String senderId,
    required String receiverName,
  }) async {
    await _createAlert(
      userId: senderId,
      type: 'member',
      title: '초대가 수락되었습니다',
      message: '$receiverNameさんが招待を承諾しました。',
    );
  }

  /// 새 멤버 참여 알림 전송
  Future<void> notifyNewMember({
    required String ownerId,
    required String newMemberName,
  }) async {
    await _createAlert(
      userId: ownerId,
      type: 'member',
      title: '新しいメンバーが参加しました',
      message: '$newMemberNameさんが冷蔵庫の共有メンバーに参加しました。メンバー管理で権限を変更できます。',
    );
  }

  /// 멤버 탈퇴 알림 전송
  Future<void> notifyMemberLeft({
    required String ownerId,
    required String memberName,
  }) async {
    await _createAlert(
      userId: ownerId,
      type: 'member',
      title: 'メンバーが退出しました',
      message: '$memberNameさんが冷蔵庫の共有から退出しました。',
    );
  }

  Future<void> _createAlert({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    final alertId = _uuid.v4();
    final now = DateTime.now();

    final alertData = {
      'id': alertId,
      'type': type,
      'title': title,
      'message': message,
      'createdAt': now.toIso8601String(),
      'isRead': false,
    };

    if (metadata != null) {
      alertData['metadata'] = metadata;
    }

    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_alertsCollection)
        .doc(alertId)
        .set(alertData);
  }
}
