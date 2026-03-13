import '../repositories/household_request_repository.dart';

/// 공동관리 요청 취소 UseCase
class CancelHouseholdRequestUseCase {
  final HouseholdRequestRepository _requestRepository;

  CancelHouseholdRequestUseCase(this._requestRepository);

  /// 공동관리 요청 취소 (보낸 요청)
  ///
  /// [requestId]: 취소할 요청 ID
  /// [senderId]: 요청 보낸 사용자 ID (현재 로그인 사용자)
  ///
  /// Throws:
  /// - [RequestNotFoundException]: 요청을 찾을 수 없음
  /// - [RequestNotPendingException]: 요청이 대기 상태가 아님
  /// - [UnauthorizedException]: 권한 없음
  Future<void> call({
    required String requestId,
    required String senderId,
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
    if (request.senderId != senderId) {
      throw UnauthorizedException('이 요청을 취소할 권한이 없습니다');
    }

    // 4. 요청 삭제
    await _requestRepository.deleteRequest(requestId);
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
