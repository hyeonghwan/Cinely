# Cinely

영화 정보 탐색 및 관리 iOS 애플리케이션

## 프로젝트 소개

Cinely는 TMDB API를 활용하여 트렌딩 영화, 영화 검색, 상세 정보 조회 기능을 제공하는 iOS 앱입니다.
사용자는 영화를 검색하고, 상세 정보를 확인하며, 선호하는 영화를 저장할 수 있습니다.

### 주요 기능

- **영화 탐색**: TMDB API를 통한 트렌딩 영화 조회
- **영화 검색**: 영화 제목 검색 및 최근 검색 이력 관리
- **영화 상세 정보**: 포스터, 시놉시스, 장르, 평점, 출시일, 출연진 정보 제공
- **선호 영화 관리**: 영화 찜하기/해제 기능
- **프로필 관리**: 닉네임 설정 및 변경
- **온보딩**: 초기 사용자 설정

## 기술 스택 및 아키텍처

### 개발 환경
- **언어**: Swift 5.9+
- **최소 지원 버전**: iOS 16.2+
- **UI 프레임워크**: UIKit
- **의존성 관리**: Swift Package Manager

### 아키텍처 패턴
- **MVVM-C (Model-View-ViewModel-Coordinator)**
  - ViewModel: 비즈니스 로직 처리 및 Input/Output 구조
  - Coordinator: 화면 전환 및 네비게이션 플로우 관리
  - Reactive State Management: 전역 상태 관리

### 주요 라이브러리

| 라이브러리 | 버전 | 용도 |
|-----------|------|------|
| RxSwift | 5.0+ | 리액티브 프로그래밍, Observable/Subject 구현 |
| RxCocoa | 5.0+ | UIKit 컴포넌트와 RxSwift 바인딩 |
| RxRelay | 5.0+ | BehaviorRelay, PublishRelay를 통한 상태 관리 |
| Alamofire | 5.0+ | HTTP 네트워킹, 자동 재시도 정책 |
| Kingfisher | 7.0+ | 이미지 다운로드 및 캐싱, 프리페칭 |

### 디자인 패턴
- **Dependency Injection**: AppDependencyFactory를 통한 의존성 주입
- **Protocol-Oriented Design**: Provider, Coordinator, ViewModel 프로토콜 기반
- **DTO Pattern**: NetworkManager와 ViewModel 간 데이터 전환
- **Property Wrapper**: KeyValueStore, CodableStore를 통한 저장소 추상화

## 프로젝트 구조

```
Cinely/
├── App/                                # 앱 진입점
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
│
├── Sources/
│   ├── CinemaFeature/                  # 영화 탐색, 검색, 상세 정보
│   │   ├── Model/                      # 영화 데이터 모델
│   │   ├── View/
│   │   │   ├── ViewControllers/        # 메인, 상세, 검색 화면
│   │   │   ├── ViewModel/              # 비즈니스 로직
│   │   │   ├── Components/             # 재사용 UI 컴포넌트
│   │   │   └── Provider/               # 데이터 제공자
│   │
│   ├── OnboardingFeature/              # 초기 설정 및 네비게이션
│   │   ├── Model/                      # 입력 검증 모델
│   │   └── View/
│   │       ├── ViewControllers/        # 온보딩 화면
│   │       ├── ViewModel/
│   │       └── Coordinator/            # 네비게이션 관리
│   │
│   ├── ProfileFeature/                 # 프로필 관리
│   │   ├── View/
│   │   │   └── ViewControllers/        # 프로필 설정 화면
│   │   └── ViewModel/
│   │
│   ├── UpcomingFeature/                # 예정 영화 조회
│   │
│   ├── DesignSystem/                   # 디자인 시스템 및 공용 컴포넌트
│   │   ├── Components/
│   │   │   ├── Button/
│   │   │   ├── Color/                  # 색상 팔레트
│   │   │   ├── Font/                   # 폰트 설정
│   │   │   ├── Image/                  # 아이콘
│   │   │   ├── TextField/
│   │   │   └── Toast/
│   │   └── Extension/
│   │
│   ├── Global/                         # 전역 상태 및 설정
│   │   ├── State/                      # 앱 전역 상태 관리
│   │   ├── Model/                      # 사용자, 에러, 설정 모델
│   │   ├── Provider/                   # 앱 전역 데이터 제공
│   │   └── AppDependency.swift         # DI 컨테이너
│   │
│   └── Network/                        # 네트워킹 계층
│       ├── API/
│       │   ├── Manager/                # HTTP 매니저
│       │   ├── Protocol/               # 네트워크 프로토콜
│       │   ├── Resources/              # API 엔드포인트
│       │   ├── Logger/                 # 요청 로깅
│       │   └── Key/                    # API 설정
│       └── DTO/                        # 데이터 전송 객체
│
└── Resources/                          # 앱 리소스
    ├── Assets.xcassets
    ├── Info.plist
    └── tmdb.xcconfig
```

### 주요 모듈

| 모듈 | 역할 |
|------|------|
| **CinemaFeature** | 영화 탐색, 검색, 상세 정보 표시 |
| **OnboardingFeature** | 초기 설정 및 화면 전환 관리 |
| **ProfileFeature** | 사용자 프로필 관리 |
| **DesignSystem** | 재사용 가능한 UI 컴포넌트 및 스타일 |
| **Global** | 전역 상태, 저장소, DI 컨테이너 |
| **Network** | API 통신 및 데이터 전송 객체 |

## 주요 특징

- **로컬 데이터 지속성**: UserDefaults 기반 사용자 데이터 저장
- **네트워크 최적화**: 자동 재시도 정책 및 에러 처리
- **이미지 최적화**: Kingfisher를 활용한 이미지 캐싱 및 프리페칭
- **반응형 UI**: RxSwift/RxCocoa를 통한 반응형 데이터 바인딩
- **다크 테마**: 일관된 다크 모드 UI
