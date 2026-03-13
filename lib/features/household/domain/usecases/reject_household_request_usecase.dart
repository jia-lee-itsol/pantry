import '../repositories/household_request_repository.dart';

/// 공동관리 요청 거절 UseCase
class RejectHouseholdRequestUseCase {
  final HouseholdRequestRepository _requestRepository;

  RejectHouseholdRequestUseCase(this._requestRepository);

  /// 공동관리 요청 거절
  ///
  /// [requestId]: 거절할 요청 ID
  /// [receiverId]: 요청 받은 사용자 ID (현재 로그인 사용자)
  ///
  /// Throws:
  /// - [RequestNotFoundException]: 요청을 찾을 수 없음
  /// - [RequestNotPendingException]: 요청이 대기 상태가 아님
  /// - [UnauthorizedException]: 권한 없음
  Future<void> call({
    required String requestId,
    required String receiverId,
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
      throw UnauthorizedException('이 요청을 거절할 권한이 없습니다');
    }

    // 4. 요청 상태 업데이트
    await _requestRepository.updateRequestStatusToRejected(requestId);
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
