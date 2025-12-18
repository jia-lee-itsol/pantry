# TODO 목록

Pantry 앱의 향후 개발 계획 및 미완성 기능 목록입니다.

## 🔴 우선순위 높음 (High Priority)

### 기능 구현

#### 쇼핑 리스트
- [x] **쇼핑 리스트 항목 추가 기능 구현**
  - 위치: `lib/features/home/presentation/pages/list_page.dart:109`
  - 설명: 쇼핑 리스트에 항목을 추가하는 다이얼로그/페이지 구현
  - 관련 파일: `shopping_list_provider.dart`
  - 상태: ✅ 완료 (AddShoppingItemDialog로 구현됨)

#### 데이터 저장 및 동기화
- [x] **쇼핑 리스트 영구 저장 구현**
  - 현재: 앱 재시작 시 초기 데이터로 리셋됨
  - 필요: SharedPreferences 또는 Firestore에 저장
  - 관련 파일: `shopping_list_provider.dart`
  - 상태: ✅ 완료 (SharedPreferences 사용 중)

- [x] **데이터 백업 기능 구현**
  - 위치: `lib/features/settings/presentation/pages/settings_page.dart:76-83`
  - 설명: 클라우드에 데이터 백업하는 기능
  - 현재: "준비 중" 메시지만 표시
  - 상태: ✅ 완료 (BackupService로 Firestore에 백업 구현)

- [x] **데이터 복원 기능 구현**
  - 위치: `lib/features/settings/presentation/pages/settings_page.dart:85-93`
  - 설명: 백업한 데이터를 복원하는 기능
  - 현재: "준비 중" 메시지만 표시
  - 상태: ✅ 완료 (BackupService로 Firestore에서 복원 구현)

#### OCR 기능
- [x] **OCR 스캔 결과 저장 기능 구현**
  - 위치: `lib/features/ocr/data/repositories_impl/ocr_repository_impl.dart:16-18`
  - 설명: 스캔한 레시피 항목을 냉장고/재고에 자동 등록하는 기능
  - 관련: `saveReceiptItems` 메서드 구현 필요
  - 상태: ✅ 완료 (saveReceiptItems 메서드 구현됨)

#### 피난소 지도
- [x] **피난소 데이터 소스 실제 구현**
  - 위치: `lib/core/services/map_service.dart:8-20`
  - 설명: MockMapRemoteDataSource를 실제 API 연동으로 교체
  - 필요: 피난소 데이터 API 연동 (예: 공공데이터포털, Google Places API 등)
  - 상태: ✅ 완료 (MapGooglePlacesDataSource로 Google Places API 연동됨)

## 🟡 우선순위 중간 (Medium Priority)

### 알림 기능
- [x] **유통기한 알림 스케줄링 구현**
  - 설명: flutter_local_notifications를 사용한 실제 알림 스케줄링
  - 기능:
    - 유통기한 3일 전 알림
    - 유통기한 경과 알림
    - 알림 시간 설정 (오전 9시)
  - 관련: `ExpiryDateService`와 연동
  - 상태: ✅ 완료 (NotificationSchedulingService로 구현)

- [x] **재고 부족 알림 구현**
  - 설명: 목표 수량의 50% 미만 시 알림
  - 기능: 재고 상태 모니터링 및 알림 발송
  - 상태: ✅ 완료 (수량 5 미만 시 알림, NotificationSchedulingService로 구현)

- [x] **알림 설정 영구 저장**
  - 현재: UI만 있고 실제 저장되지 않음
  - 필요: SharedPreferences에 알림 설정 저장
  - 상태: ✅ 완료 (NotificationSettingsService로 구현)

### 기능 개선
- [x] **유통기한 임박 항목 복원 기능**
  - 위치: `lib/features/home/presentation/pages/near_expiry_list_page.dart:83`
  - 설명: 소비 완료 처리한 항목을 복원하는 기능 (Undo)
  - 우선순위: 낮음 (선택적 구현)
  - 상태: ✅ 완료 (SnackBar의 Undo 액션으로 구현)

- [x] **할인 상품 정보 섹션 구현**
  - 위치: `lib/features/home/presentation/pages/home_page.dart:361`
  - 설명: 주변 할인 상품 정보를 표시하는 기능
  - 현재: 주석 처리됨
  - 필요: 할인 정보 API 연동 또는 로컬 데이터
  - 상태: ✅ 완료 (플레이스홀더 UI 구현, 실제 API 연동은 향후 계획)

### 검색 및 필터링
- [x] **냉장고 재고 검색 기능**
  - 설명: 재고 목록에서 이름/카테고리로 검색
  - 관련: `fridge_list_page.dart`
  - 상태: ✅ 완료 (이미 구현됨)

- [x] **재고 목록 필터링 기능**
  - 설명: 카테고리, 유통기한, 상태별 필터링
  - 관련: `fridge_list_page.dart`, `stock_list_page.dart`
  - 상태: ✅ 완료 (이미 구현됨 - 유통기한 순, 수량 순 정렬)
  - 추가: StockListPage, ListPage 접근성 개선 완료

## 🟢 우선순위 낮음 (Low Priority)

### UI/UX 개선
- [ ] **다크 모드 지원**
  - 설명: Material Design 3 다크 테마 구현
  - 관련: `app_theme.dart`, `color_schemes.dart`
  - 참고: 사용자 메모리에 따르면 다크 모드는 지원하지 않기로 결정됨

- [ ] **다국어 지원 (i18n)**
  - 현재: 일본어만 지원
  - 필요: 한국어, 영어 등 추가 언어 지원
  - 참고: 사용자 메모리에 따르면 다국어는 지원하지 않기로 결정됨

- [x] **애니메이션 및 전환 효과 개선**
  - 설명: 페이지 전환, 리스트 업데이트 애니메이션 추가
  - 상태: ✅ 완료 (GoRouter에 커스텀 페이지 전환 애니메이션 추가, AnimatedListItem 위젯 생성)

- [x] **접근성 개선**
  - 설명: 스크린 리더 지원, 키보드 네비게이션 등
  - 상태: ✅ 완료 (주요 UI 요소에 Semantics 위젯 추가, 스크린 리더 지원)

### 성능 최적화
- [x] **이미지 캐싱 최적화**
  - 설명: OCR 스캔 이미지 캐싱 전략 개선
  - 상태: ✅ 완료 (ImageCacheService로 구현, 최대 50MB, 7일 보관)

- [x] **데이터 로딩 최적화**
  - 설명: 지연 로딩, 페이지네이션 구현
  - 관련: 대량 데이터 처리 시 성능 개선
  - 상태: ✅ 완료 (페이지네이션 메서드 추가, 오프라인 우선 읽기)

- [x] **오프라인 동기화 개선**
  - 설명: Firestore 오프라인 지속성 최적화
  - 기능: 충돌 해결, 자동 재시도 로직
  - 상태: ✅ 완료 (Firestore 오프라인 지속성 활성화, SyncService로 재시도 및 충돌 해결 구현)

### 테스트
- [ ] **단위 테스트 작성**
  - UseCase 테스트
  - Repository 테스트
  - Service 테스트

- [ ] **위젯 테스트 작성**
  - 주요 페이지 위젯 테스트
  - 공통 위젯 테스트

- [ ] **통합 테스트 작성**
  - 전체 기능 플로우 테스트
  - E2E 테스트

### 문서화
- [x] **API 문서 작성**
  - 설명: 주요 API 엔드포인트 문서화
  - 상태: ✅ 완료 (docs/API.md에 작성됨)

- [x] **코드 주석 보완**
  - 설명: 복잡한 로직에 대한 주석 추가
  - 상태: ✅ 완료 (주요 서비스 및 데이터 소스에 주석 추가)

## 🔵 향후 계획 (Future Plans)

### 소셜 기능
- [ ] **소셜 로그인 구현**
  - Google, Apple 로그인 지원
  - 사용자 인증 및 데이터 분리

- [ ] **가족/그룹 공유 기능**
  - 설명: 여러 사용자가 같은 냉장고/재고를 공유
  - 기능: 실시간 동기화, 권한 관리

### 고급 기능
- [x] **레시피 추천 기능**
  - 설명: 냉장고 재고를 기반으로 레시피 추천
  - 필요: 레시피 데이터베이스 또는 API 연동
  - 상태: ✅ 완료 (Firebase AI (Gemini)를 사용하여 현재 재고 기반 레시피 추천 구현)

- [ ] **음성 입력 지원**
  - 설명: 음성으로 재고 항목 추가
  - 필요: 음성 인식 API 연동

- [ ] **바코드 스캔 기능**
  - 설명: 바코드를 스캔하여 상품 정보 자동 입력
  - 필요: 바코드 스캐너 라이브러리

- [ ] **통계 및 분석 기능**
  - 설명: 재고 소비 패턴, 유통기한 통계 등
  - 기능: 차트, 그래프로 시각화

### 데이터 관리
- [ ] **데이터 내보내기/가져오기**
  - 설명: CSV, JSON 형식으로 데이터 내보내기/가져오기
  - 기능: 백업 및 복원의 대안

- [ ] **자동 정리 기능**
  - 설명: 만료된 항목 자동 삭제 또는 아카이브
  - 기능: 정리 규칙 설정

## 📝 참고사항

### 우선순위 기준
- **높음**: 핵심 기능, 사용자 경험에 직접적인 영향
- **중간**: 기능 개선, 사용성 향상
- **낮음**: 선택적 기능, 장기 계획
- **향후 계획**: 로드맵에 포함된 기능

### 진행 상황 업데이트
- 작업 시작 시 `[ ]`를 `[진행중]`으로 변경
- 완료 시 `[x]`로 체크
- 취소된 항목은 `[취소]`로 표시하고 이유를 주석으로 추가

### 관련 문서
- [아키텍처 가이드](./docs/ARCHITECTURE.md)
- [기능 설명](./docs/FEATURES.md)
- [개발 가이드](./docs/DEVELOPMENT.md)

