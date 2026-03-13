import '../entities/household_member.dart';
import '../entities/household_role.dart';
import '../repositories/household_repository.dart';
import '../repositories/household_request_repository.dart';
import 'notify_user_usecase.dart';

/// 공동관리 요청 수락 UseCase
class AcceptHouseholdRequestUseCase {
  final HouseholdRepository _householdRepository;
  final HouseholdRequestRepository _requestRepository;
  final NotifyUserUseCase _notifyUserUseCase;

  AcceptHouseholdRequestUseCase({
    required HouseholdRepository householdRepository,
    required HouseholdRequestRepository requestRepository,
    required NotifyUserUseCase notifyUserUseCase,
  })  : _householdRepository = householdRepository,
        _requestRepository = requestRepository,
        _notifyUserUseCase = notifyUserUseCase;

  /// 공동관리 요청 수락
  ///
  /// [requestId]: 수락할 요청 ID
  /// [receiverId]: 요청 받은 사용자 ID (현재 로그인 사용자)
  /// [receiverDisplayName]: 수락하는 사용자 표시 이름
  /// [receiverPhotoUrl]: 수락하는 사용자 프로필 사진
  /// [receiverEmail]: 수락하는 사용자 이메일
  ///
  /// Throws:
  /// - [RequestNotFoundException]: 요청을 찾을 수 없음
  /// - [RequestNotPendingException]: 요청이 대기 상태가 아님
  /// - [UnauthorizedException]: 권한 없음
  Future<void> call({
    required String requestId,
    required String receiverId,
    required String? receiverDisplayName,
    required String? receiverPhotoUrl,
    required String? receiverEmail,
  }) async {
    // 1. 요청 조회
    final request = await _requestRepository.getRequest(requestId);
    if (request == null) {
      throw RequestNotFoundException('요청을 찾을 수 없습니다');
    }

    // 2. 상태 확인
    if (!request.isPending) {
      throw RequestNotPendingException('이미 처리된 요청입니다');
    }

    // 3. 권한 확인
    if (request.receiverId != receiverId) {
      throw UnauthorizedException('이 요청을 수락할 권한이 없습니다');
    }

    // 4. 가구 확인
    final household = await _householdRepository.getHousehold(request.householdId);
    if (household == null) {
      throw RequestNotFoundException('가구를 찾을 수 없습니다');
    }

    // 5. 멤버 생성
    final member = HouseholdMember(
      id: receiverId,
      role: HouseholdRole.viewer,
      joinedAt: DateTime.now(),
      displayName: receiverDisplayName,
      photoUrl: receiverPhotoUrl,
      email: receiverEmail,
    );

    // 6. 요청 상태 업데이트
    await _requestRepository.updateRequestStatusToAccepted(requestId);

    // 7. 멤버 추가
    await _householdRepository.addMember(request.householdId, member);

    // 8. 사용자 householdId 업데이트
    await _householdRepository.setUserHouseholdId(receiverId, request.householdId);

    // 9. 알림 전송 (발신자에게)
    await _notifyUserUseCase.notifyRequestAccepted(
      senderId: request.senderId,
      receiverName: receiverDisplayName ?? request.receiverUsername,
    );

    // 10. 알림 전송 (소유자에게, 발신자와 소유자가 다른 경우)
    if (request.senderId != household.ownerId) {
      await _notifyUserUseCase.notifyNewMember(
        ownerId: household.ownerId,
        newMemberName: receiverDisplayName ?? request.receiverUsername,
      );
    }
  }
}

class RequestNotFoundException implements Exception {
  final String message;
  RequestNotFoundException(this.message);
  @override
  String toString() => message;
}

class RequestNotPendingException implements Exception {
  final String message;
  RequestNotPendingException(this.message);
  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}
