# Firestore 보안 규칙 설정 가이드

## 권한 오류 해결 방법

`permission-denied` 오류가 발생하는 경우, Firebase Console에 보안 규칙을 배포해야 합니다.

## Firebase Console에서 규칙 배포하기

### 1. Firebase Console 접속
1. https://console.firebase.google.com/ 접속
2. 프로젝트 선택: `pantry-ae10e`

### 2. Firestore Database로 이동
1. 왼쪽 메뉴에서 **"Firestore Database"** 클릭
2. 상단 탭에서 **"규칙"** (Rules) 탭 클릭

### 3. 보안 규칙 복사 및 붙여넣기
1. 아래 규칙을 복사합니다:

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
    
    // 사용자별 서브컬렉션 구조
    // 경로: /users/{userId}/fridge_items/{itemId}
    match /users/{userId}/fridge_items/{itemId} {
      allow read, write: if isOwner(userId);
    }
    
    // 경로: /users/{userId}/stock_items/{itemId}
    match /users/{userId}/stock_items/{itemId} {
      allow read, write: if isOwner(userId);
    }
    
    // 경로: /users/{userId}/alerts/{alertId}
    match /users/{userId}/alerts/{alertId} {
      allow read, write: if isOwner(userId);
    }
    
    // 경로: /users/{userId}/receipts/{receiptId}
    match /users/{userId}/receipts/{receiptId} {
      allow read, write: if isOwner(userId);
    }
    
    // 경로: /users/{userId}/backups/{backupId}
    match /users/{userId}/backups/{backupId} {
      allow read, write: if isOwner(userId);
    }
    
    // 모든 사용자 서브컬렉션에 대한 일반 규칙
    match /users/{userId}/{document=**} {
      allow read, write: if isOwner(userId);
    }
  }
}
```

2. Firebase Console의 규칙 편집기에 붙여넣기
3. **"게시"** (Publish) 버튼 클릭

### 4. 규칙 배포 확인
- 배포가 완료되면 "규칙이 성공적으로 게시되었습니다" 메시지가 표시됩니다.
- 배포에는 몇 초에서 몇 분이 걸릴 수 있습니다.

## Firebase CLI로 배포하기 (선택사항)

터미널에서 다음 명령어를 실행할 수도 있습니다:

```bash
# Firebase CLI 로그인 (처음 한 번만)
firebase login

# 프로젝트 디렉토리로 이동
cd /Users/charlotteyi/Documents/Github/pantry

# 규칙 배포
firebase deploy --only firestore:rules

# 인덱스 배포
firebase deploy --only firestore:indexes
```

## 문제 해결

### 여전히 권한 오류가 발생하는 경우

1. **사용자 로그인 확인**
   - 앱에서 로그인되어 있는지 확인
   - Firebase Console → Authentication에서 사용자가 등록되어 있는지 확인

2. **규칙 배포 확인**
   - Firebase Console → Firestore Database → 규칙 탭
   - 최근 배포 시간 확인
   - 규칙이 올바르게 저장되어 있는지 확인

3. **앱 재시작**
   - 규칙 배포 후 앱을 완전히 종료하고 다시 실행

4. **Firebase Auth 토큰 확인**
   - 디버그 로그에서 `[FridgeFirestoreDataSource]` 로그 확인
   - `userId`가 올바르게 표시되는지 확인

## 개발 중 임시 규칙 (주의: 프로덕션에서는 사용하지 마세요)

개발 중에만 사용할 수 있는 임시 규칙:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 개발 중: 인증된 사용자만 접근 가능
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

⚠️ **경고**: 이 규칙은 모든 인증된 사용자가 모든 사용자의 데이터에 접근할 수 있으므로, 개발 중에만 사용하세요.

