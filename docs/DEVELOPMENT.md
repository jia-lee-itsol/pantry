# 개발 가이드

Pantry 프로젝트의 개발 가이드라인 및 모범 사례입니다.

## 코드 스타일

### 명명 규칙

#### 파일명

- **snake_case** 사용
- 예: `fridge_item.dart`, `get_fridge_items_usecase.dart`

#### 클래스명

- **PascalCase** 사용
- 예: `FridgeItem`, `GetFridgeItemsUseCase`

#### 변수/함수명

- **camelCase** 사용
- 예: `getFridgeItems()`, `fridgeItemList`

#### 상수

- **camelCase** 사용 (클래스 내부)
- 예: `static const String appName = 'Pantry';`

### 코드 포맷팅

```bash
# 코드 포맷팅 실행
dart format .

# 또는
flutter format .
```

### Import 순서

1. Dart SDK imports
2. Flutter imports
3. 패키지 imports
4. 프로젝트 imports (절대 경로 사용)

```dart
// 예시
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/app_theme.dart';
import '../../features/fridge/domain/entities/fridge_item.dart';
```

## 아키텍처 가이드

### Clean Architecture 준수

각 기능 모듈은 다음 구조를 따라야 합니다:

```
feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories_impl/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── providers/
    └── widgets/
```

### 레이어 간 의존성

- **Presentation → Domain**: Presentation은 Domain에만 의존
- **Data → Domain**: Data는 Domain에만 의존
- **Domain**: 다른 레이어에 의존하지 않음

### Entity vs Model

#### Entity (Domain Layer)

- 비즈니스 로직을 포함하는 순수 Dart 클래스
- JSON 직렬화 없음
- 데이터베이스 구조와 독립적

```dart
class FridgeItem {
  final String id;
  final String name;
  final DateTime expiryDate;
  
  FridgeItem({
    required this.id,
    required this.name,
    required this.expiryDate,
  });
}
```

#### Model (Data Layer)

- JSON 직렬화를 포함하는 데이터 모델
- Entity로 변환하는 메서드 포함

```dart
class FridgeItemModel {
  final String id;
  final String name;
  final String expiryDate;
  
  FridgeItemModel({
    required this.id,
    required this.name,
    required this.expiryDate,
  });
  
  factory FridgeItemModel.fromJson(Map<String, dynamic> json) {
    return FridgeItemModel(
      id: json['id'],
      name: json['name'],
      expiryDate: json['expiryDate'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expiryDate': expiryDate,
    };
  }
  
  FridgeItem toEntity() {
    return FridgeItem(
      id: id,
      name: name,
      expiryDate: DateTime.parse(expiryDate),
    );
  }
}
```

## 상태 관리

### Riverpod 사용 규칙

#### Provider 타입 선택

- **FutureProvider**: 비동기 데이터 로딩
- **StateProvider**: 간단한 상태 (예: 선택된 항목)
- **StateNotifierProvider**: 복잡한 상태 관리

#### Provider 명명

- Provider 이름은 `[name]Provider` 형식
- 예: `fridgeItemsProvider`, `fridgeNotifierProvider`

#### Provider 위치

- 각 기능의 `presentation/providers/` 폴더에 위치
- 공통 Provider는 `core/providers/`에 위치

### 예시

```dart
// FutureProvider 예시
final fridgeItemsProvider = FutureProvider<List<FridgeItem>>((ref) {
  final useCase = ref.watch(getFridgeItemsUseCaseProvider);
  return useCase();
});

// StateNotifierProvider 예시
final fridgeNotifierProvider = 
    StateNotifierProvider<FridgeNotifier, FridgeState>((ref) {
  return FridgeNotifier(ref.watch(fridgeRepositoryProvider));
});

class FridgeNotifier extends StateNotifier<FridgeState> {
  final FridgeRepository repository;
  
  FridgeNotifier(this.repository) : super(FridgeState.initial());
  
  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await repository.getFridgeItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

## 에러 처리

### 에러 타입 정의

```dart
// Domain Layer
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}
```

### 에러 처리 패턴

```dart
// Repository에서 에러 처리
Future<Either<Failure, List<FridgeItem>>> getFridgeItems() async {
  try {
    final items = await firestoreDataSource.getFridgeItems();
    return Right(items.map((model) => model.toEntity()).toList());
  } on FirebaseException catch (e) {
    return Left(ServerFailure(e.message ?? '서버 오류가 발생했습니다.'));
  } catch (e) {
    return Left(ServerFailure('알 수 없는 오류가 발생했습니다.'));
  }
}
```

### UI에서 에러 표시

```dart
final itemsAsync = ref.watch(fridgeItemsProvider);

itemsAsync.when(
  data: (items) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

## 테스트 작성

### 단위 테스트

#### UseCase 테스트

```dart
void main() {
  group('GetFridgeItemsUseCase', () {
    late MockFridgeRepository mockRepository;
    late GetFridgeItemsUseCase useCase;
    
    setUp(() {
      mockRepository = MockFridgeRepository();
      useCase = GetFridgeItemsUseCase(mockRepository);
    });
    
    test('should return list of fridge items', () async {
      // Arrange
      final items = [FridgeItem(...), FridgeItem(...)];
      when(mockRepository.getFridgeItems())
          .thenAnswer((_) async => items);
      
      // Act
      final result = await useCase();
      
      // Assert
      expect(result, items);
      verify(mockRepository.getFridgeItems()).called(1);
    });
  });
}
```

#### Repository 테스트

```dart
void main() {
  group('FridgeRepositoryImpl', () {
    late MockFridgeFirestoreDataSource mockFirestore;
    late MockFridgeLocalDataSource mockLocal;
    late FridgeRepositoryImpl repository;
    
    setUp(() {
      mockFirestore = MockFridgeFirestoreDataSource();
      mockLocal = MockFridgeLocalDataSource();
      repository = FridgeRepositoryImpl(mockFirestore, mockLocal);
    });
    
    test('should return items from firestore when successful', () async {
      // Arrange
      final models = [FridgeItemModel(...)];
      when(mockFirestore.getFridgeItems())
          .thenAnswer((_) async => models);
      
      // Act
      final result = await repository.getFridgeItems();
      
      // Assert
      expect(result.length, 1);
      verify(mockFirestore.getFridgeItems()).called(1);
    });
  });
}
```

### 위젯 테스트

```dart
void main() {
  testWidgets('FridgeListPage displays items', (tester) async {
    // Arrange
    final items = [FridgeItem(...)];
    
    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fridgeItemsProvider.overrideWithValue(
            AsyncValue.data(items),
          ),
        ],
        child: MaterialApp(home: FridgeListPage()),
      ),
    );
    
    // Assert
    expect(find.text('Item Name'), findsOneWidget);
  });
}
```

## 모범 사례

### 1. DRY 원칙

중복 코드를 제거하고 공통 로직은 서비스나 유틸리티로 추출합니다.

```dart
// 나쁜 예
void showError1() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('에러가 발생했습니다.')),
  );
}

void showError2() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('에러가 발생했습니다.')),
  );
}

// 좋은 예
class SnackBarService {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

### 2. 단일 책임 원칙

각 클래스는 하나의 책임만 가져야 합니다.

```dart
// 나쁜 예
class FridgeService {
  Future<List<FridgeItem>> getItems() { ... }
  Future<void> saveItem(FridgeItem item) { ... }
  DateTime calculateExpiryDate(DateTime date) { ... }
  void sendNotification() { ... }
}

// 좋은 예
class FridgeRepository {
  Future<List<FridgeItem>> getItems() { ... }
  Future<void> saveItem(FridgeItem item) { ... }
}

class ExpiryDateService {
  DateTime calculateExpiryDate(DateTime date) { ... }
}

class NotificationService {
  void sendNotification() { ... }
}
```

### 3. 의존성 주입

Riverpod을 통한 의존성 주입을 사용합니다.

```dart
// Provider 정의
final fridgeRepositoryProvider = Provider<FridgeRepository>((ref) {
  return FridgeRepositoryImpl(
    ref.watch(fridgeFirestoreDataSourceProvider),
    ref.watch(fridgeLocalDataSourceProvider),
  );
});

// 사용
final useCase = GetFridgeItemsUseCase(
  ref.watch(fridgeRepositoryProvider),
);
```

### 4. 비동기 처리

비동기 작업은 명확하게 처리하고 에러를 적절히 처리합니다.

```dart
// 좋은 예
Future<void> loadItems() async {
  try {
    state = state.copyWith(isLoading: true);
    final items = await repository.getFridgeItems();
    state = state.copyWith(items: items, isLoading: false);
  } catch (e) {
    state = state.copyWith(
      error: e.toString(),
      isLoading: false,
    );
  }
}
```

## 코드 리뷰 체크리스트

### 기능 구현

- [ ] 요구사항을 정확히 구현했는가?
- [ ] 에러 처리가 적절한가?
- [ ] 오프라인 상황을 고려했는가?

### 코드 품질

- [ ] Clean Architecture 원칙을 따르는가?
- [ ] DRY 원칙을 준수하는가?
- [ ] 명명 규칙을 따르는가?
- [ ] 주석이 적절한가?

### 테스트

- [ ] 단위 테스트가 작성되었는가?
- [ ] 테스트가 통과하는가?
- [ ] 테스트 커버리지가 적절한가?

### 성능

- [ ] 불필요한 리빌드가 없는가?
- [ ] 메모리 누수가 없는가?
- [ ] 비동기 처리가 적절한가?

## Git 커밋 메시지 규칙

### 형식

```
<type>: <subject>

<body>

<footer>
```

### Type

- `feat`: 새로운 기능
- `fix`: 버그 수정
- `docs`: 문서 수정
- `style`: 코드 포맷팅
- `refactor`: 리팩토링
- `test`: 테스트 추가/수정
- `chore`: 빌드 설정 등

### 예시

```
feat: 냉장고 재고 추가 기능 구현

- 재고 추가 페이지 구현
- Firestore 연동
- 로컬 캐시 저장

Closes #123
```

## 디자인 시스템 사용

### 색상 사용

```dart
// 테마 색상 사용
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Primary Color',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  ),
)

// 또는 직접 사용
Container(
  color: AppColorSchemes.light.primary,
)
```

### 간격 사용

```dart
Padding(
  padding: const EdgeInsets.all(AppSpacing.md),
  child: Column(
    children: [
      SizedBox(height: AppSpacing.sm),
      // ...
    ],
  ),
)
```

### 타이포그래피 사용

```dart
Text(
  'Title',
  style: Theme.of(context).textTheme.titleLarge,
)

Text(
  'Body',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

### 디자인 위젯 사용

```dart
// AppScaffold 사용
AppScaffold(
  title: Text('Page Title'),
  actions: [
    IconButton(icon: Icon(Icons.settings), onPressed: () {}),
  ],
  body: YourContent(),
)

// PrimaryButton 사용
PrimaryButton(
  onPressed: () {},
  child: Text('Button'),
)
```

## 서비스 사용

### ExpiryDateService

```dart
// AI를 사용한 유통기한 추정
final expiryDate = await ExpiryDateService.getExpiryDateWithAI('牛乳');

// 기본 유통기한 추정
final defaultExpiryDate = ExpiryDateService.getDefaultExpiryDate('牛乳');
```

### PermissionService

```dart
// 모든 권한 요청
final statuses = await PermissionService.requestAllPermissions();

// 특정 권한 확인
final hasLocation = await PermissionService.checkLocationPermission();

// 권한 요청
final granted = await PermissionService.requestLocationPermission();
```

### Logger 사용

```dart
AppLogger.debug('Debug message', 'TagName');
AppLogger.info('Info message');
AppLogger.warning('Warning message');
AppLogger.error('Error message', errorObject);
```

### Result 타입 사용

```dart
Future<Result<List<FridgeItem>>> getItems() async {
  try {
    final items = await repository.getFridgeItems();
    return Success(items);
  } catch (e) {
    return Failure('Failed to load items', e);
  }
}

// 사용
final result = await getItems();
result.when(
  success: (items) => print('Items: $items'),
  failure: (message, error) => print('Error: $message'),
);
```

## 참고 자료

- [Flutter Style Guide](https://flutter.dev/docs/development/ui/widgets-intro)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Best Practices](https://riverpod.dev/docs/concepts/about_riverpod)
- [Material Design 3](https://m3.material.io/)

