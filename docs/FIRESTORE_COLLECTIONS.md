# Firestore 컬렉션 구조

이 문서는 Pantry 앱에서 사용하는 Firestore 컬렉션 구조를 설명합니다.

## 컬렉션 목록

> **참고**: 모든 컬렉션은 사용자별 서브컬렉션 구조를 사용합니다.
> 경로 형식: `/users/{userId}/{collection}/{itemId}`

### 1. `fridge_items` (냉장고 아이템)

**경로**: `/users/{userId}/fridge_items/{itemId}`

**구조**:
```json
{
  "id": "string",
  "name": "string",
  "quantity": "number",
  "category": "string | null",
  "expiryDate": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "userId": "string"
}
```

**필드 설명**:
- `id`: 아이템 고유 ID
- `name`: 상품명
- `quantity`: 수량
- `category`: 카테고리명 (선택사항)
- `expiryDate`: 유통기한
- `createdAt`: 생성일시
- `updatedAt`: 수정일시
- `userId`: 사용자 ID (Firebase Auth UID)

**인덱스**:
- `userId` + `createdAt` (descending)
- `userId` + `expiryDate` (ascending)

---

### 2. `stock_items` (재고 아이템)

**경로**: `/users/{userId}/stock_items/{itemId}`

**구조**:
```json
{
  "id": "string",
  "name": "string",
  "quantity": "number",
  "category": "string | null",
  "minQuantity": "number",
  "lastUpdated": "timestamp",
  "createdAt": "timestamp",
  "userId": "string"
}
```

**필드 설명**:
- `id`: 아이템 고유 ID
- `name`: 상품명
- `quantity`: 현재 수량
- `category`: 카테고리명 (선택사항)
- `minQuantity`: 최소 수량 (알림 기준)
- `lastUpdated`: 마지막 업데이트 시간
- `createdAt`: 생성일시
- `userId`: 사용자 ID (Firebase Auth UID)

**인덱스**:
- `userId` + `lastUpdated` (descending)
- `userId` + `name` (ascending)

---

### 3. `alerts` (알림)

**경로**: `/users/{userId}/alerts/{alertId}`

**구조**:
```json
{
  "id": "string",
  "type": "string", // "expiry" | "stock"
  "title": "string",
  "message": "string",
  "isRead": "boolean",
  "createdAt": "timestamp",
  "userId": "string"
}
```

**필드 설명**:
- `id`: 알림 고유 ID
- `type`: 알림 타입 ("expiry" 또는 "stock")
- `title`: 알림 제목
- `message`: 알림 메시지
- `isRead`: 읽음 여부
- `createdAt`: 생성일시
- `userId`: 사용자 ID (Firebase Auth UID)

**인덱스**:
- `userId` + `createdAt` (descending)
- `userId` + `isRead` + `createdAt` (descending)

---

### 4. `receipts` (영수증)

**경로**: `/users/{userId}/receipts/{receiptId}`

**구조**:
```json
{
  "id": "string",
  "imageUrl": "string",
  "items": [
    {
      "name": "string",
      "price": "number",
      "quantity": "number"
    }
  ],
  "totalAmount": "number",
  "purchaseDate": "timestamp",
  "createdAt": "timestamp",
  "userId": "string"
}
```

**필드 설명**:
- `id`: 영수증 고유 ID
- `imageUrl`: 영수증 이미지 URL
- `items`: 영수증 아이템 목록
- `totalAmount`: 총 금액
- `purchaseDate`: 구매일시
- `createdAt`: 생성일시
- `userId`: 사용자 ID (Firebase Auth UID)

**인덱스**:
- `userId` + `purchaseDate` (descending)

---

### 5. `backups` (사용자 백업)

**경로**: `/users/{userId}/backups/{backupId}`

**구조**:
```json
{
  "userId": "string",
  "fridgeItems": "array",
  "stockItems": "array",
  "categories": "array",
  "shoppingList": "array",
  "backupDate": "timestamp",
  "version": "string"
}
```

**필드 설명**:
- `userId`: 사용자 ID (Firebase Auth UID)
- `fridgeItems`: 냉장고 아이템 백업 데이터
- `stockItems`: 재고 아이템 백업 데이터
- `categories`: 카테고리 백업 데이터
- `shoppingList`: 쇼핑 리스트 백업 데이터
- `backupDate`: 백업 일시 (Timestamp)
- `version`: 백업 버전

**인덱스**:
- `backupDate` (descending) - 사용자별 서브컬렉션이므로 userId 인덱스 불필요

---

## 보안 규칙 (Firestore Security Rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 헬퍼 함수: 인증된 사용자 확인
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // 헬퍼 함수: 사용자 소유 확인
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // 냉장고 아이템
    match /fridge_items/{itemId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update: if isOwner(resource.data.userId);
      allow delete: if isOwner(resource.data.userId);
    }
    
    // 재고 아이템
    match /stock_items/{itemId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update: if isOwner(resource.data.userId);
      allow delete: if isOwner(resource.data.userId);
    }
    
    // 알림
    match /alerts/{alertId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update: if isOwner(resource.data.userId);
      allow delete: if isOwner(resource.data.userId);
    }
    
    // 영수증
    match /receipts/{receiptId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update: if isOwner(resource.data.userId);
      allow delete: if isOwner(resource.data.userId);
    }
    
    // 사용자 백업
    match /user_backups/{userId} {
      allow read: if isOwner(userId);
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId);
    }
  }
}
```

---

## 인덱스 설정

Firebase Console에서 다음 복합 인덱스를 생성해야 합니다:

### `fridge_items` 컬렉션
1. `userId` (Ascending) + `createdAt` (Descending)
2. `userId` (Ascending) + `expiryDate` (Ascending)

### `stock_items` 컬렉션
1. `userId` (Ascending) + `lastUpdated` (Descending)
2. `userId` (Ascending) + `name` (Ascending)

### `alerts` 컬렉션
1. `userId` (Ascending) + `createdAt` (Descending)
2. `userId` (Ascending) + `isRead` (Ascending) + `createdAt` (Descending)

### `receipts` 컬렉션
1. `userId` (Ascending) + `purchaseDate` (Descending)

### `user_backups` 컬렉션
1. `userId` (Ascending) + `backupDate` (Descending)

---

## 초기 설정 방법

1. **Firebase Console 접속**
   - https://console.firebase.google.com/

2. **Firestore Database 생성**
   - 프로젝트 선택 → Firestore Database → 데이터베이스 만들기
   - 프로덕션 모드로 시작 (나중에 보안 규칙 적용)

3. **보안 규칙 적용**
   - Firestore Database → 규칙 탭
   - 위의 보안 규칙 코드를 복사하여 붙여넣기
   - 게시 버튼 클릭

4. **인덱스 생성**
   - Firestore Database → 인덱스 탭
   - 위의 인덱스 목록에 따라 복합 인덱스 생성
   - 또는 쿼리 실행 시 자동으로 인덱스 생성 링크가 표시되면 클릭

5. **테스트 데이터 추가 (선택사항)**
   - 컬렉션 → 컬렉션 추가
   - 컬렉션 ID 입력 (예: `fridge_items`)
   - 문서 추가하여 테스트

---

## 주의사항

1. **사용자별 데이터 분리**: 모든 컬렉션에 `userId` 필드를 포함하여 사용자별로 데이터를 분리합니다.

2. **타임스탬프 필드**: `createdAt`, `updatedAt` 등의 타임스탬프는 Firestore의 `Timestamp` 타입을 사용합니다.

3. **오프라인 지원**: Firestore의 오프라인 지속성을 활성화하여 오프라인에서도 데이터를 읽고 쓸 수 있습니다.

4. **인덱스 관리**: 복합 쿼리를 사용하는 경우 반드시 해당 인덱스를 생성해야 합니다.

