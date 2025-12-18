# Pantry 문서

Pantry 앱의 문서 모음입니다.

## 문서 목록

- [아키텍처 가이드](./ARCHITECTURE.md) - 프로젝트의 아키텍처 구조 및 설계 원칙
- [설치 및 설정 가이드](./SETUP.md) - 개발 환경 설정 및 프로젝트 실행 방법
- [기능 설명](./FEATURES.md) - 앱의 주요 기능 상세 설명
- [개발 가이드](./DEVELOPMENT.md) - 코드 작성 규칙 및 개발 가이드라인

## 프로젝트 개요

Pantry는 냉장고 재고 관리 및 재해 대비 재고 관리를 위한 Flutter 앱입니다.

### 주요 기능

- 🏠 **홈 화면**: 대시보드 및 요약 정보
- 🥶 **냉장고 관리**: 냉장고 내 재고 관리 및 유통기한 추적
- 📦 **재해 대비 재고**: 재해 대비 재고 관리
- 🛒 **쇼핑 리스트**: 냉장고/재고용 쇼핑 리스트 관리
- 📸 **OCR 스캔**: 레시피 스캔을 통한 자동 재고 등록 (Firebase AI 활용)
- 🗺️ **피난소 지도**: 주변 피난소 위치 확인 및 비상 상품 목록
- 🔔 **알림**: 유통기한 및 재고 알림
- ⚙️ **설정**: 카테고리 관리 및 앱 설정

### 기술 스택

- **프레임워크**: Flutter 3.10.3+
- **상태 관리**: Riverpod 3.0.3
- **라우팅**: go_router 17.0.1
- **백엔드**: Firebase (Firestore, Firebase AI - Gemini 2.0 Flash)
- **ML**: Google ML Kit (텍스트 인식)
- **지도**: Google Maps Flutter
- **알림**: flutter_local_notifications
- **권한**: permission_handler
- **로컬 저장소**: shared_preferences

### 아키텍처

이 프로젝트는 Clean Architecture 원칙을 따릅니다.

```
lib/
├── app/              # 앱 초기화 및 라우팅
├── core/             # 공통 기능
│   ├── constants/    # 상수 정의
│   ├── design/       # 디자인 시스템 (테마, 색상, 타이포그래피)
│   ├── firebase/     # Firebase 초기화
│   ├── services/     # 공통 서비스 (ExpiryDateService, PermissionService 등)
│   ├── utils/        # 유틸리티 (Logger, DateUtils, Result 타입)
│   └── widgets/      # 공통 위젯
├── features/         # 기능별 모듈
│   ├── alert/        # 알림 기능
│   ├── fridge/       # 냉장고 관리
│   ├── home/         # 홈 화면 (쇼핑 리스트 포함)
│   ├── map/          # 지도 기능
│   ├── ocr/          # OCR 기능
│   ├── settings/     # 설정
│   └── stock/        # 재고 관리
└── shared/           # 공유 리소스
    └── mock_data/    # Mock 데이터 서비스
```

각 기능 모듈은 다음과 같은 구조를 가집니다:

```
feature/
├── data/             # 데이터 레이어
│   ├── datasources/  # 데이터 소스 (Firestore, Local)
│   ├── models/       # 데이터 모델
│   └── repositories_impl/  # 리포지토리 구현
├── domain/           # 도메인 레이어
│   ├── entities/     # 엔티티
│   ├── repositories/ # 리포지토리 인터페이스
│   └── usecases/     # 유스케이스
└── presentation/     # 프레젠테이션 레이어
    ├── pages/        # 페이지
    ├── providers/    # Riverpod 프로바이더
    └── widgets/      # 위젯
```

## 빠른 시작

자세한 설치 및 설정 방법은 [SETUP.md](./SETUP.md)를 참고하세요.

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

## 라이선스

이 프로젝트는 비공개 프로젝트입니다.

