import '../../../auth/domain/entities/user_profile.dart';
import '../entities/household_request.dart';
import '../repositories/household_repository.dart';
import '../repositories/household_request_repository.dart';
import '../repositories/username_repository.dart';
import 'notify_user_usecase.dart';

/// 공동관리 요청 전송 UseCase
class SendHouseholdRequestUseCase {
  final HouseholdRepository _householdRepository;
  final HouseholdRequestRepository _requestRepository;
  final UsernameRepository _usernameRepository;
  final NotifyUserUseCase _notifyUserUseCase;

  SendHouseholdRequestUseCase({
    required HouseholdRepository householdRepository,
    required HouseholdRequestRepository requestRepository,
    required UsernameRepository usernameRepository,
    required NotifyUserUseCase notifyUserUseCase,
  })  : _householdRepository = householdRepository,
        _requestRepository = requestRepository,
        _usernameRepository = usernameRepository,
        _notifyUserUseCase = notifyUserUseCase;

  /// 공동관리 요청 전송
  ///
  /// [senderId]: 요청 보내는 사용자 ID
  /// [senderDisplayName]: 요청 보내는 사용자 표시 이름
  /// [senderPhotoUrl]: 요청 보내는 사용자 프로필 사진
  /// [receiver]: 요청 받는 사용자 프로필
  ///
  /// Returns: 생성된 HouseholdRequest
  ///
  /// Throws:
  /// - [SenderNotRegisteredException]: 발신자 아이디 미등록
  /// - [NoHouseholdException]: 가구 없음
  /// - [AlreadyMemberException]: 이미 멤버임
  /// - [RequestAlreadyExistsException]: 이미 요청 존재
  Future<HouseholdRequest> call({
    required String senderId,
    required String? senderDisplayName,
    required String? senderPhotoUrl,
    required UserProfile receiver,
  }) async {
    // 1. 발신자 아이디 확인
    final senderUsername = await _usernameRepository.getUsernameByUserId(senderId);
    if (senderUsername == null) {
      throw SenderNotRegisteredException('먼저 아이디를 등록해주세요');
    }

    // 2. 발신자 가구 확인
    final householdId = await _householdRepository.getUserHouseholdId(senderId);
    if (householdId == null) {
      throw NoHouseholdException('가구가 없습니다');
    }

    final household = await _householdRepository.getHousehold(householdId);
    if (household == null) {
      throw NoHouseholdException('가구를 찾을 수 없습니다');
    }

    // 3. 이미 멤버인지 확인
    if (household.isMember(receiver.id)) {
      throw AlreadyMemberException('이미 가구 멤버입니다');
    }

    // 4. 중복 요청 확인
    final existingRequest = await _requestRepository.hasExistingPendingRequest(
      senderId: senderId,
      receiverId: receiver.id,
    );
    if (existingRequest) {
      throw RequestAlreadyExistsException('이미 요청을 보냈습니다');
    }

    // 5. 요청 생성
    final request = await _requestRepository.createRequest(
      senderId: senderId,
      senderUsername: senderUsername,
      senderDisplayName: senderDisplayName,
      senderPhotoUrl: senderPhotoUrl,
      receiverId: receiver.id,
      receiverUsername: receiver.username,
      householdId: householdId,
      householdName: household.name,
    );

    // 6. 알림 전송
    await _notifyUserUseCase.notifyHouseholdRequest(
      receiverId: receiver.id,
      senderName: senderDisplayName ?? senderUsername,
      householdName: household.name,
      requestId: request.id,
    );

    return request;
  }
}

class SenderNotRegisteredException implements Exception {
  final String message;
  SenderNotRegisteredException(this.message);
  @override
  String toString() => message;
}

class NoHouseholdException implements Exception {
  final String message;
  NoHouseholdException(this.message);
  @override
  String toString() => message;
}

class AlreadyMemberException implements Exception {
  final String message;
  AlreadyMemberException(this.message);
  @override
  String toString() => message;
}

class RequestAlreadyExistsException implements Exception {
  final String message;
  RequestAlreadyExistsException(this.message);
  @override
  String toString() => message;
}
