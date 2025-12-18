# 설치 및 설정 가이드

## 사전 요구사항

### 필수 도구

- **Flutter SDK**: 3.10.3 이상
- **Dart SDK**: 3.10.3 이상
- **Android Studio** 또는 **VS Code** (Flutter 확장 포함)
- **Xcode** (iOS 개발 시, macOS만)
- **Git**

### 플랫폼별 요구사항

#### Android
- Android Studio
- Android SDK (API 21 이상)
- Java Development Kit (JDK) 17 이상

#### iOS (macOS만)
- Xcode 14 이상
- CocoaPods
- macOS 12.0 이상

## 프로젝트 설정

### 1. 저장소 클론

```bash
git clone <repository-url>
cd pantry
```

### 2. 의존성 설치

```bash
flutter pub get
```

### 3. Firebase 설정

#### Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. 다음 서비스 활성화:
   - Cloud Firestore
   - Firebase Authentication (필요한 경우)
   - Firebase AI (Gemini API)
     - [Google AI Studio](https://makersuite.google.com/app/apikey)에서 API 키 생성 필요
     - Firebase Console에서 Firebase AI 활성화

#### Android 설정

1. Firebase Console에서 Android 앱 추가
2. `google-services.json` 파일 다운로드
3. `android/app/google-services.json`에 파일 복사

#### iOS 설정

1. Firebase Console에서 iOS 앱 추가
2. `GoogleService-Info.plist` 파일 다운로드
3. `ios/Runner/GoogleService-Info.plist`에 파일 복사

#### macOS 설정

1. Firebase Console에서 macOS 앱 추가
2. `GoogleService-Info.plist` 파일 다운로드
3. `macos/Runner/GoogleService-Info.plist`에 파일 복사

### 4. Firebase 초기화 확인

`lib/core/firebase/firebase_options.dart` 파일이 올바르게 생성되었는지 확인합니다.

```bash
# Firebase CLI를 사용하여 생성 (선택사항)
flutterfire configure
```

### 5. iOS CocoaPods 설치 (iOS/macOS만)

```bash
cd ios
pod install
cd ..
```

또는

```bash
cd macos
pod install
cd ..
```

## 권한 설정

### Android

`android/app/src/main/AndroidManifest.xml`에 다음 권한이 설정되어 있는지 확인:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS

`ios/Runner/Info.plist`에 다음 권한 설명이 설정되어 있는지 확인:

```xml
<key>NSCameraUsageDescription</key>
<string>레시피를 스캔하기 위해 카메라 권한이 필요합니다.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>주변 피난소를 찾기 위해 위치 권한이 필요합니다.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>이미지를 선택하기 위해 사진 라이브러리 권한이 필요합니다.</string>
```

### macOS

`macos/Runner/DebugProfile.entitlements` 및 `macos/Runner/Release.entitlements`에 필요한 권한이 설정되어 있는지 확인합니다.

## Google Maps API 키 설정

### Android

1. [Google Cloud Console](https://console.cloud.google.com/)에서 API 키 생성
2. `android/app/src/main/AndroidManifest.xml`에 추가:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### iOS

1. [Google Cloud Console](https://console.cloud.google.com/)에서 API 키 생성
2. `ios/Runner/AppDelegate.swift`에 추가:

```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

### macOS

1. [Google Cloud Console](https://console.cloud.google.com/)에서 API 키 생성
2. `macos/Runner/AppDelegate.swift`에 추가:

```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

## 환경 변수 설정 (선택사항)

프로젝트 루트에 `.env` 파일을 생성하여 환경 변수를 관리할 수 있습니다:

```env
FIREBASE_API_KEY=your_api_key
GOOGLE_MAPS_API_KEY=your_maps_key
FIREBASE_AI_API_KEY=your_firebase_ai_key
```

### Firebase AI 설정

1. [Google AI Studio](https://makersuite.google.com/app/apikey)에서 API 키 생성
2. Firebase Console에서 Firebase AI 활성화
3. `firebase_options.dart`에 API 키가 포함되어 있는지 확인

## 앱 실행

### 디바이스/에뮬레이터 확인

```bash
flutter devices
```

### 앱 실행

```bash
# 기본 실행
flutter run

# 특정 디바이스에서 실행
flutter run -d <device-id>

# 릴리스 모드로 실행
flutter run --release

# 프로파일 모드로 실행
flutter run --profile
```

### 플랫폼별 실행

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# macOS
flutter run -d macos

# Web
flutter run -d chrome
```

## 빌드

### Android APK 빌드

```bash
flutter build apk

# 분할 APK
flutter build apk --split-per-abi
```

### Android App Bundle 빌드

```bash
flutter build appbundle
```

### iOS 빌드

```bash
flutter build ios
```

### macOS 빌드

```bash
flutter build macos
```

## 문제 해결

### 일반적인 문제

#### 1. 의존성 충돌

```bash
flutter clean
flutter pub get
```

#### 2. iOS CocoaPods 문제

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

#### 3. 빌드 캐시 문제

```bash
flutter clean
flutter pub get
flutter run
```

#### 4. Firebase 초기화 오류

- `google-services.json` 및 `GoogleService-Info.plist` 파일이 올바른 위치에 있는지 확인
- Firebase 프로젝트 설정이 올바른지 확인
- `firebase_options.dart` 파일이 최신인지 확인

#### 5. 권한 오류

- Android: `AndroidManifest.xml`에 권한이 추가되어 있는지 확인
- iOS: `Info.plist`에 권한 설명이 추가되어 있는지 확인
- 앱을 완전히 종료하고 다시 실행

#### 6. Google Maps 오류

- API 키가 올바르게 설정되었는지 확인
- Google Cloud Console에서 Maps SDK가 활성화되어 있는지 확인
- API 키에 올바른 제한이 설정되어 있는지 확인

### 디버깅

#### 로그 확인

```bash
flutter logs
```

#### 디버그 모드 실행

```bash
flutter run --debug
```

#### 성능 프로파일링

```bash
flutter run --profile
```

## 개발 환경 권장사항

### IDE 설정

#### VS Code

필수 확장:
- Flutter
- Dart
- Flutter Widget Snippets

#### Android Studio

필수 플러그인:
- Flutter
- Dart

### 코드 포맷팅

```bash
# 코드 포맷팅
dart format .

# 또는
flutter format .
```

### 코드 분석

```bash
# 정적 분석
flutter analyze
```

### 테스트 실행

```bash
# 모든 테스트 실행
flutter test

# 특정 테스트 실행
flutter test test/features/fridge/domain/usecases/get_fridge_items_usecase_test.dart
```

## 추가 리소스

- [Flutter 공식 문서](https://flutter.dev/docs)
- [Firebase Flutter 문서](https://firebase.flutter.dev/)
- [Riverpod 문서](https://riverpod.dev/)
- [go_router 문서](https://pub.dev/packages/go_router)

