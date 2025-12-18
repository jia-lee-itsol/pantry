# API 문서

Pantry 앱의 주요 API 엔드포인트 및 데이터 소스 문서입니다.

## 목차

- [개요](#개요)
- [Repository 인터페이스](#repository-인터페이스)
- [데이터 소스](#데이터-소스)
- [서비스](#서비스)

## 개요

이 앱은 Clean Architecture를 따르며, Repository 패턴을 사용하여 데이터 접근을 추상화합니다. 각 기능 모듈은 Domain 레이어의 Repository 인터페이스를 정의하고, Data 레이어에서 이를 구현합니다.

## Repository 인터페이스

### FridgeRepository

냉장고 아이템 관리를 위한 Repository 인터페이스입니다.

**위치**: `lib/features/fridge/domain/repositories/fridge_repository.dart`

**메서드**:

- `Future<List<FridgeItem>> getFridgeItems()`
  - 모든 냉장고 아이템을 가져옵니다.
  - 반환: FridgeItem 리스트

- `Future<void> addFridgeItem(FridgeItem item)`
  - 새로운 냉장고 아이템을 추가합니다.
  - 파라미터: 추가할 FridgeItem 객체

- `Future<void> updateFridgeItem(FridgeItem item)`
  - 기존 냉장고 아이템을 업데이트합니다.
  - 파라미터: 업데이트할 FridgeItem 객체

- `Future<void> deleteFridgeItem(String id)`
  - 냉장고 아이템을 삭제합니다.
  - 파라미터: 삭제할 아이템의 ID

**구현**: `lib/features/fridge/data/repositories_impl/fridge_repository_impl.dart`

### StockRepository

재해 대비 재고 관리를 위한 Repository 인터페이스입니다.

**위치**: `lib/features/stock/domain/repositories/stock_repository.dart`

**메서드**:

- `Future<List<StockItem>> getStockItems()`
  - 모든 재고 아이템을 가져옵니다.
  - 반환: StockItem 리스트

- `Future<void> addStockItem(StockItem item)`
  - 새로운 재고 아이템을 추가합니다.
  - 파라미터: 추가할 StockItem 객체

- `Future<void> updateStockItem(StockItem item)`
  - 기존 재고 아이템을 업데이트합니다.
  - 파라미터: 업데이트할 StockItem 객체

- `Future<void> deleteStockItem(String id)`
  - 재고 아이템을 삭제합니다.
  - 파라미터: 삭제할 아이템의 ID

**구현**: `lib/features/stock/data/repositories_impl/stock_repository_impl.dart`

### MapRepository

피난소 지도 기능을 위한 Repository 인터페이스입니다.

**위치**: `lib/features/map/domain/repositories/map_repository.dart`

**메서드**:

- `Future<List<Shelter>> getNearbyShelters(double latitude, double longitude)`
  - 주변 피난소 목록을 가져옵니다.
  - 파라미터:
    - `latitude`: 위도
    - `longitude`: 경도
  - 반환: Shelter 리스트

- `Future<List<Shelter>> getAllShelters()`
  - 모든 피난소 목록을 가져옵니다.
  - 반환: Shelter 리스트

**구현**: `lib/features/map/data/repositories_impl/map_repository_impl.dart`

**데이터 소스**: Google Places API를 사용하여 피난소 정보를 가져옵니다.

### OCRRepository

OCR 스캔 기능을 위한 Repository 인터페이스입니다.

**위치**: `lib/features/ocr/domain/repositories/ocr_repository.dart`

**메서드**:

- `Future<List<ReceiptItem>> scanReceipt(String imagePath)`
  - 레시피 이미지를 스캔하여 아이템 목록을 추출합니다.
  - 파라미터: 이미지 파일 경로
  - 반환: 추출된 ReceiptItem 리스트

- `Future<void> saveReceiptItems(List<ReceiptItem> items)`
  - 스캔한 아이템들을 냉장고/재고에 저장합니다.
  - 파라미터: 저장할 ReceiptItem 리스트

**구현**: `lib/features/ocr/data/repositories_impl/ocr_repository_impl.dart`

**데이터 소스**: Google ML Kit을 사용하여 텍스트 인식을 수행합니다.

### CategoryRepository

카테고리 관리를 위한 Repository 인터페이스입니다.

**위치**: `lib/features/settings/domain/repositories/category_repository.dart`

**메서드**:

- `Future<List<Category>> getCategories()`
  - 모든 카테고리를 가져옵니다.
  - 반환: Category 리스트

- `Future<void> addCategory(Category category)`
  - 새로운 카테고리를 추가합니다.

- `Future<void> updateCategory(Category category)`
  - 기존 카테고리를 업데이트합니다.

- `Future<void> deleteCategory(String id)`
  - 카테고리를 삭제합니다.

- `Future<void> reorderCategories(List<Category> categories)`
  - 카테고리 순서를 재정렬합니다.

**구현**: `lib/features/settings/data/repositories_impl/category_repository_impl.dart`

**데이터 소스**: SharedPreferences를 사용하여 로컬에 저장합니다.

## 데이터 소스

### Firestore 데이터 소스

Firebase Firestore를 사용하는 데이터 소스들입니다.

#### StockFirestoreDataSource

**위치**: `lib/features/stock/data/datasources/stock_firestore_datasource.dart`

**특징**:
- 오프라인 우선 읽기: 캐시에서 먼저 읽기를 시도하고, 캐시가 비어있으면 서버에서 가져옵니다.
- SyncService를 통한 재시도 로직 및 충돌 해결
- 페이지네이션 지원 (`getStockItemsPaginated`)

**주요 메서드**:
- `getStockItems()`: 모든 재고 아이템 가져오기
- `getStockItemsPaginated()`: 페이지네이션을 사용한 아이템 가져오기
- `addStockItem()`: 재고 아이템 추가
- `updateStockItem()`: 재고 아이템 업데이트
- `deleteStockItem()`: 재고 아이템 삭제

#### FridgeFirestoreDataSource

**위치**: `lib/features/fridge/data/datasources/fridge_firestore_datasource.dart`

**특징**:
- StockFirestoreDataSource와 동일한 오프라인 우선 읽기 전략 사용
- SyncService를 통한 재시도 로직 및 충돌 해결

### 로컬 데이터 소스

#### CategoryLocalDataSource

**위치**: `lib/features/settings/data/datasources/category_local_datasource.dart`

**특징**:
- SharedPreferences를 사용하여 로컬에 카테고리 데이터 저장
- JSON 형식으로 직렬화/역직렬화

#### ShoppingListLocalDataSource

**위치**: `lib/features/home/data/datasources/shopping_list_local_datasource.dart`

**특징**:
- SharedPreferences를 사용하여 쇼핑 리스트 데이터 저장
- JSON 형식으로 직렬화/역직렬화

### 외부 API 데이터 소스

#### MapGooglePlacesDataSource

**위치**: `lib/features/map/data/datasources/map_google_places_datasource.dart`

**특징**:
- Google Places API를 사용하여 피난소 정보를 가져옵니다.
- "shelter" 또는 "evacuation" 키워드로 검색
- 위치 기반 검색 지원

#### OCRMLKitDataSource

**위치**: `lib/features/ocr/data/datasources/ocr_mlkit_datasource.dart`

**특징**:
- Google ML Kit Text Recognition을 사용하여 이미지에서 텍스트 추출
- 일본어 및 영어 지원

## 서비스

### ExpiryDateService

**위치**: `lib/core/services/expiry_date_service.dart`

상품명을 기반으로 유통기한을 계산하는 서비스입니다.

**메서드**:

- `Future<int> getExpiryDaysWithAI(String productName)`
  - Firebase AI (Gemini 2.0 Flash)를 사용하여 상품명으로 유통기한을 검색합니다.
  - AI 호출이 실패하면 `getDefaultExpiryDays`의 기본값을 사용합니다.
  - 반환: 유통기한 일수

- `int getDefaultExpiryDays(String productName)`
  - 하드코딩된 규칙을 사용하여 유통기한을 계산합니다.
  - 다양한 언어(일본어, 한국어, 영어)를 지원합니다.
  - 반환: 유통기한 일수

**카테고리별 기본 유통기한**:
- 유제품: 3-30일
- 계란: 14-21일
- 채소: 3-30일
- 과일: 3-14일
- 콩제품: 3-180일
- 육류: 1-7일
- 생선: 1-3일
- 기타: 7일 (기본값)

### SyncService

**위치**: `lib/core/services/sync_service.dart`

Firestore 작업 시 재시도 로직 및 충돌 해결을 담당하는 서비스입니다.

**메서드**:

- `Future<T> executeWithRetry<T>(Future<T> Function() operation)`
  - Firestore 작업을 재시도 로직과 함께 실행합니다.
  - 네트워크 오류 시 자동 재시도
  - 충돌 발생 시 자동 해결 시도

### BackupService

**위치**: `lib/core/services/backup_service.dart`

데이터 백업 및 복원을 담당하는 서비스입니다.

**메서드**:

- `Future<void> backupData()`
  - 냉장고 아이템, 재고 아이템, 쇼핑 리스트를 Firestore에 백업합니다.

- `Future<void> restoreData()`
  - Firestore에서 백업된 데이터를 복원합니다.

### NotificationSchedulingService

**위치**: `lib/core/services/notification_scheduling_service.dart`

유통기한 알림 및 재고 부족 알림을 스케줄링하는 서비스입니다.

**메서드**:

- `Future<void> scheduleExpiryNotifications(List<FridgeItem> items)`
  - 유통기한 알림을 스케줄링합니다.
  - 유통기한 3일 전 알림
  - 유통기한 경과 알림

- `Future<void> scheduleLowStockNotifications(List<StockItem> items)`
  - 재고 부족 알림을 스케줄링합니다.
  - 수량이 5 미만일 때 알림

### PermissionService

**위치**: `lib/core/services/permission_service.dart`

앱 권한 관리를 담당하는 서비스입니다.

**메서드**:

- `Future<bool> checkLocationPermission()`
  - 위치 권한이 허용되어 있는지 확인합니다.

- `Future<bool> requestLocationPermission()`
  - 위치 권한을 요청합니다.

- `Future<bool> isLocationPermanentlyDenied()`
  - 위치 권한이 영구적으로 거부되었는지 확인합니다.

- `void openSettings()`
  - 앱 설정 화면을 엽니다.

## 데이터 모델

### FridgeItem

냉장고 아이템 엔티티입니다.

**필드**:
- `id`: 아이템 ID
- `name`: 상품명
- `quantity`: 수량
- `expiryDate`: 유통기한
- `category`: 카테고리
- `isFrozen`: 냉동 여부
- `createdAt`: 생성일시
- `updatedAt`: 수정일시

### StockItem

재고 아이템 엔티티입니다.

**필드**:
- `id`: 아이템 ID
- `name`: 상품명
- `quantity`: 수량
- `targetQuantity`: 목표 수량
- `category`: 카테고리
- `expiryDate`: 유통기한 (선택적)
- `lastUpdated`: 마지막 업데이트 일시

### Shelter

피난소 엔티티입니다.

**필드**:
- `id`: 피난소 ID
- `name`: 피난소 이름
- `address`: 주소
- `latitude`: 위도
- `longitude`: 경도
- `phoneNumber`: 전화번호 (선택적)

### ReceiptItem

레시피 아이템 엔티티입니다.

**필드**:
- `name`: 상품명
- `quantity`: 수량 (선택적)
- `price`: 가격 (선택적)

## 에러 처리

모든 Repository 구현은 다음과 같은 에러 처리를 수행합니다:

1. **네트워크 오류**: SyncService를 통한 자동 재시도
2. **권한 오류**: PermissionService를 통한 권한 확인 및 요청
3. **데이터 검증 오류**: 도메인 레이어에서 검증 수행

## 참고사항

- 모든 Firestore 데이터 소스는 오프라인 우선 읽기 전략을 사용합니다.
- 데이터 동기화는 SyncService를 통해 처리됩니다.
- 로컬 데이터 소스는 SharedPreferences를 사용하며, JSON 형식으로 직렬화됩니다.
- 외부 API 사용 시 API 키가 필요합니다. (환경 변수 또는 설정 파일에서 관리)

