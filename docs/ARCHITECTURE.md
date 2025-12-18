# 아키텍처 가이드

## 개요

Pantry 앱은 Clean Architecture 원칙을 따르는 Flutter 프로젝트입니다. 계층화된 아키텍처를 통해 관심사의 분리, 테스트 용이성, 유지보수성을 확보합니다.

## 아키텍처 원칙

### 1. Clean Architecture

프로젝트는 다음과 같은 3계층 구조를 가집니다:

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (UI, Widgets, Providers)           │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        Domain Layer                 │
│  (Entities, Use Cases, Interfaces)  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Data Layer                  │
│  (Repositories, Data Sources)       │
└─────────────────────────────────────┘
```

### 2. 의존성 규칙

- **Presentation → Domain**: Presentation 레이어는 Domain 레이어에 의존
- **Data → Domain**: Data 레이어는 Domain 레이어에 의존
- **Domain**: 다른 레이어에 의존하지 않음 (순수 비즈니스 로직)

### 3. 단방향 데이터 흐름

```
User Action → Provider → UseCase → Repository → DataSource
                ↓
            State Update
                ↓
            UI Rebuild
```

## 레이어 상세 설명

### Presentation Layer

UI와 사용자 상호작용을 담당하는 레이어입니다.

#### 구조

```
presentation/
├── pages/          # 화면 페이지
├── providers/      # Riverpod 상태 관리
└── widgets/        # 재사용 가능한 위젯
```

#### 책임

- UI 렌더링
- 사용자 입력 처리
- 상태 관리 (Riverpod)
- 네비게이션

#### 예시

```dart
// Provider 예시
final fridgeItemsProvider = FutureProvider<List<FridgeItem>>((ref) {
  final useCase = ref.watch(getFridgeItemsUseCaseProvider);
  return useCase();
});

// Page 예시
class FridgeListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(fridgeItemsProvider);
    // UI 구현
  }
}
```

### Domain Layer

비즈니스 로직의 핵심을 담당하는 레이어입니다.

#### 구조

```
domain/
├── entities/       # 비즈니스 엔티티
├── repositories/   # 리포지토리 인터페이스
└── usecases/       # 유스케이스 (비즈니스 로직)
```

#### 책임

- 비즈니스 규칙 정의
- 엔티티 정의
- 유스케이스 구현
- 리포지토리 인터페이스 정의

#### 예시

```dart
// Entity 예시
class FridgeItem {
  final String id;
  final String name;
  final DateTime expiryDate;
  // ...
}

// UseCase 예시
class GetFridgeItemsUseCase {
  final FridgeRepository repository;
  
  Future<List<FridgeItem>> call() {
    return repository.getFridgeItems();
  }
}

// Repository Interface 예시
abstract class FridgeRepository {
  Future<List<FridgeItem>> getFridgeItems();
  Future<void> addFridgeItem(FridgeItem item);
  // ...
}
```

### Data Layer

데이터 소스와의 통신을 담당하는 레이어입니다.

#### 구조

```
data/
├── datasources/         # 데이터 소스 (Firestore, Local)
├── models/              # 데이터 모델 (JSON 직렬화)
└── repositories_impl/   # 리포지토리 구현
```

#### 책임

- 외부 데이터 소스와 통신 (Firestore, Local Storage)
- 데이터 모델 변환 (Model ↔ Entity)
- 리포지토리 인터페이스 구현

#### 예시

```dart
// Model 예시
class FridgeItemModel {
  final String id;
  final String name;
  final String expiryDate;
  
  FridgeItemModel.fromJson(Map<String, dynamic> json) { /* ... */ }
  Map<String, dynamic> toJson() { /* ... */ }
  
  FridgeItem toEntity() {
    return FridgeItem(
      id: id,
      name: name,
      expiryDate: DateTime.parse(expiryDate),
    );
  }
}

// Repository Implementation 예시
class FridgeRepositoryImpl implements FridgeRepository {
  final FridgeFirestoreDataSource firestoreDataSource;
  final FridgeLocalDataSource localDataSource;
  
  @override
  Future<List<FridgeItem>> getFridgeItems() async {
    try {
      final models = await firestoreDataSource.getFridgeItems();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      // 오프라인 폴백
      final models = await localDataSource.getFridgeItems();
      return models.map((model) => model.toEntity()).toList();
    }
  }
}
```

## Core 모듈

공통 기능을 제공하는 모듈입니다.

```
core/
├── constants/      # 상수 정의
│   ├── app_constants.dart    # 앱 상수
│   ├── app_keys.dart         # 키 상수
│   └── app_strings.dart      # 문자열 상수
├── design/         # 테마 및 디자인 시스템
│   ├── app_theme.dart        # 앱 테마
│   ├── color_schemes.dart    # 색상 스킴
│   ├── spacing.dart          # 간격 상수
│   ├── typography.dart       # 타이포그래피
│   └── widgets/              # 디자인 위젯
│       ├── app_scaffold.dart
│       ├── compact_card.dart
│       ├── primary_button.dart
│       └── section_card.dart
├── firebase/       # Firebase 초기화
│   ├── firebase_initializer.dart
│   └── firebase_options.dart
├── services/       # 공통 서비스
│   ├── alert_service.dart
│   ├── expiry_date_service.dart
│   ├── fridge_service.dart
│   ├── map_service.dart
│   ├── ocr_service.dart
│   ├── permission_service.dart
│   └── stock_service.dart
├── storage/        # 로컬 스토리지
├── utils/          # 유틸리티 함수
│   ├── date_utils.dart
│   ├── logger.dart
│   └── result.dart
└── widgets/        # 공통 위젯
    ├── error_widget.dart
    ├── loading_widget.dart
    └── main_navigation.dart
```

### 주요 서비스

#### ExpiryDateService

유통기한 계산 및 AI 기반 유통기한 추정을 제공하는 서비스입니다.

**주요 기능:**
- `getExpiryDaysWithAI(String productName)`: Firebase AI (Gemini)를 사용하여 상품명 기반 유통기한 일수 추정
- `getDefaultExpiryDays(String productName)`: 하드코딩된 규칙 기반 기본 유통기한 일수 반환
- `getExpiryDateWithAI(String productName)`: AI를 사용하여 유통기한 날짜 반환
- `getDefaultExpiryDate(String productName)`: 기본 유통기한 날짜 반환

**지원 상품 카테고리:**
- 유제품 (우유, 요구르트, 치즈 등)
- 계란
- 채소 (상추, 양파, 감자 등)
- 과일 (사과, 바나나, 딸기 등)
- 콩제품 (두부, 낫토, 된장 등)
- 육류 (닭고기, 돼지고기, 소고기 등)
- 생선/해산물
- 빵/면류

#### PermissionService

앱에서 필요한 권한을 관리하는 서비스입니다.

**주요 기능:**
- `requestAllPermissions()`: 모든 권한 일괄 요청 (위치, 카메라, 사진 라이브러리)
- `checkLocationPermission()`: 위치 권한 확인
- `checkCameraPermission()`: 카메라 권한 확인
- `requestLocationPermission()`: 위치 권한 요청
- `requestCameraPermission()`: 카메라 권한 요청
- `requestPhotoLibraryPermission()`: 사진 라이브러리 권한 요청
- `isLocationPermanentlyDenied()`: 위치 권한 영구 거부 확인
- `isCameraPermanentlyDenied()`: 카메라 권한 영구 거부 확인
- `openSettings()`: 설정 앱 열기

#### 기타 서비스

- **AlertService**: 알림 리포지토리 프로바이더
- **FridgeService**: 냉장고 리포지토리 프로바이더
- **StockService**: 재고 리포지토리 프로바이더
- **OCRService**: OCR 리포지토리 프로바이더
- **MapService**: 지도 리포지토리 프로바이더

### 디자인 시스템

#### Color Schemes

Material Design 3 기반의 색상 스킴을 사용합니다.

```dart
AppColorSchemes.light
- primary: 파스텔 그린 (#6B8E5A)
- secondary: 세컨더리 그린 (#9BB5A0)
- tertiary: 베이지 (#B5A58F)
- surface: 흰색 (#FFFFFF)
- error: 빨간색 (#D32F2F)
```

#### Typography

일관된 타이포그래피 시스템을 제공합니다.

- **Headlines**: 24-32px, Bold
- **Titles**: 16-22px, Semi-Bold
- **Body**: 12-16px, Regular
- **Labels**: 11-14px, Medium

#### Spacing

표준 간격 시스템을 사용합니다.

```dart
AppSpacing.xs = 4.0
AppSpacing.sm = 8.0
AppSpacing.md = 16.0
AppSpacing.lg = 24.0
AppSpacing.xl = 32.0
AppSpacing.xxl = 48.0
```

#### 디자인 위젯

- **AppScaffold**: 표준 앱 스캐폴드 (AppBar, SafeArea 포함)
- **CompactCard**: 컴팩트한 카드 위젯
- **PrimaryButton**: 기본 버튼 스타일
- **SectionCard**: 섹션 카드 위젯

### 유틸리티

#### Result 타입

성공/실패를 표현하는 sealed class입니다.

```dart
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, [this.error]);
}
```

#### Logger

앱 전체에서 사용하는 로깅 유틸리티입니다.

```dart
AppLogger.debug(String message, [String? tag])
AppLogger.info(String message, [String? tag])
AppLogger.warning(String message, [String? tag])
AppLogger.error(String message, [Object? error, String? tag])
```

#### DateUtils

날짜 포맷팅 유틸리티입니다.

```dart
DateUtils.formatDate(DateTime date)        // yyyy-MM-dd
DateUtils.formatDateTime(DateTime date)    // yyyy-MM-dd HH:mm
```

## 상태 관리

### Riverpod 사용

프로젝트는 Riverpod을 상태 관리 라이브러리로 사용합니다.

#### Provider 타입

- **FutureProvider**: 비동기 데이터 로딩
- **StateProvider**: 간단한 상태 관리
- **StateNotifierProvider**: 복잡한 상태 관리

#### 예시

```dart
// FutureProvider
final fridgeItemsProvider = FutureProvider<List<FridgeItem>>((ref) {
  final useCase = ref.watch(getFridgeItemsUseCaseProvider);
  return useCase();
});

// StateNotifierProvider
final fridgeNotifierProvider = 
    StateNotifierProvider<FridgeNotifier, FridgeState>((ref) {
  return FridgeNotifier(ref.watch(fridgeRepositoryProvider));
});
```

## 라우팅

### go_router 사용

프로젝트는 go_router를 사용하여 선언적 라우팅을 구현합니다.

#### 라우트 구조

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          GoRoute(path: '/', name: 'home', ...),
          GoRoute(path: '/fridge', name: 'fridge', ...),
          // ...
        ],
      ),
      // 네비게이션 바 없이 표시될 페이지들
      GoRoute(path: '/ocr', name: 'ocr', ...),
      GoRoute(path: '/map', name: 'map', ...),
    ],
  );
});
```

## 데이터 소스 전략

### 온라인 우선 (Online First)

1. Firestore에서 데이터 조회 시도
2. 실패 시 로컬 데이터 소스로 폴백
3. 성공 시 로컬에 캐시 저장

### 오프라인 지원

- SharedPreferences를 통한 로컬 데이터 저장
- Firestore의 오프라인 지속성 활용

## 테스트 전략

### 단위 테스트

- Domain 레이어: UseCase, Entity 테스트
- Data 레이어: Repository, DataSource 테스트

### 위젯 테스트

- Presentation 레이어: Widget 테스트

### 통합 테스트

- 전체 기능 플로우 테스트

## 코드 구조 규칙

### 1. 파일 명명 규칙

- 클래스: `PascalCase` (예: `FridgeItem`)
- 파일: `snake_case` (예: `fridge_item.dart`)
- 변수/함수: `camelCase` (예: `getFridgeItems`)

### 2. 폴더 구조

- 기능별로 모듈화
- 각 모듈은 Clean Architecture 계층 구조 유지

### 3. Import 규칙

- Barrel 파일 사용 (`@lib/shared.dart`)
- 상대 경로보다 절대 경로 선호

## 모범 사례

### 1. DRY 원칙

- 중복 코드 제거
- 공통 로직은 서비스나 유틸리티로 추출

### 2. 단일 책임 원칙

- 각 클래스는 하나의 책임만 가짐
- UseCase는 하나의 비즈니스 로직만 처리

### 3. 의존성 주입

- Riverpod을 통한 의존성 주입
- 테스트 용이성 확보

### 4. 에러 처리

- 명확한 에러 타입 정의
- 사용자 친화적인 에러 메시지

## 참고 자료

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)
- [Riverpod Documentation](https://riverpod.dev/)

