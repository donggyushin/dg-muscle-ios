# dg-muscle-ios

효율적으로 비교하고 기록하여 점진적 과부하를 이루고 근 성장을 이루자는 목적의 프로젝트. 
프로젝트 [이곳](https://github.com/DgMuscle/dg-muscle-ios)으로 이전중입니다. 

### [Introduction](https://judicious-hoof-33e.notion.site/dgmuscle-ios-a7162152c1594a09902d7d6c07da8bdd?pvs=74)

<div>
  <img src="https://github.com/donggyushin/dg-muscle-ios/assets/34573243/45eff686-131d-4a7f-80e3-f0a3af518df5" width=200 />
  <img src="https://github.com/donggyushin/dg-muscle-ios/assets/34573243/90a1b76b-81d5-40bd-842e-c0e8c856cf4c" width=200 />
  <img src="https://github.com/donggyushin/dg-muscle-ios/assets/34573243/388c212b-ecb2-475c-a609-cde14f0dcc45" width=200 />
  <img src="https://github.com/donggyushin/dg-muscle-ios/assets/34573243/02debaa7-9a23-491b-8b9c-e2884ccbcb95" width=200 />
  <img src="https://github.com/donggyushin/dg-muscle-ios/assets/34573243/db2799b9-ea3e-44cf-8063-ae3855d2db4c" width=200 />
  <img src="https://github.com/donggyushin/dg-muscle-ios/assets/34573243/24bf0696-f755-4be1-817b-6ee0356ab227" width=200 />
</div>



![RPReplay_Final1713610744-ezgif com-resize](https://github.com/donggyushin/dg-muscle-ios/assets/34573243/5067705b-f234-47f5-8ca8-df15cbf625ca)


![image](https://github.com/DgMuscle/dg-muscle-ios/assets/34573243/a127df42-9f0c-41e5-b151-aebb86533973)

__프레젠테이션 계층__ 
- 뷰(View)와 뷰모델(ViewModel) 구성요소를 포함합니다.
- 사용자 인터페이스와 애플리케이션과의 상호작용을 관리합니다.
- 도메인 계층으로 요청을 보내고, 응답을 받아 사용자 인터페이스를 업데이트합니다.

__도메인 계층__
- 애플리케이션의 중심으로, 엔티티, 유즈케이스, 리포지토리 인터페이스를 포함합니다.
- 프레젠테이션 계층과 데이터 계층 사이의 매개체 역할을 하며, 비즈니스 로직과 작업을 정의합니다.
- 외부 영향으로부터 독립적으로 비즈니스 규칙과 기능이 올바르게 적용되도록 보장합니다.
 
__데이터 계층__
- 데이터 영속성 및 검색 작업을 관리합니다.
- API 서버로의 네트워크 요청 및 장치 파일 시스템을 통한 로컬 데이터 저장과 같은 외부 리소스와 인터페이스하는 리포지토리를 포함합니다.
- 도메인 계층에서 받은 지시에 따라 데이터를 가져오고, 저장하고, 업데이트하는 역할을 수행합니다.


__의존성 방향__
- 각 계층은 자신 바로 아래에 있는 계층에만 의존하게 하였습니다. 이는 관심사의 명확한 분리를 촉진합니다. 
- 한 계층에서의 변경이 다른 계층에 최소한의 영향만 미치도록 합니다. 


이 아키텍쳐는 각 구성요소간 책임을 명확히 구분함으로써 유지보수성과 테스트 가능성이 높은 애플리케이션을 만드는 데 도움을 주며, 소프트웨어 설계에서 SRP, DIP 원칙들을 준수합니다. 


## Main Model

<img src="https://github.com/donggyushin/dg-muscle-ios/assets/34573243/4bd3b634-8100-4719-8ae7-e1c32389dc38" />

### Exercise

유저가 직접 등록하는 운동 모델. 이름과 운동을 통하여 발전시키고자 하는 타겟 부위를 담고 있음

### History

유저의 운동 기록 모델. Exercise Id 와 여러개의 Set가 모여서 하나의 Record를 이루고, 여러개의 Record가 모여서 그 날의 운동 기록을 구성.

### Concern

| Concern  | Purpose                                                                |
| -------- | ---------------------------------------------------------------------- |
| Auth     | 회원가입 및 로그인의 유저의 인증 관리                                  |
| History  | 유저의 운동일지 기록 추가, 수정, 삭제 및 UI                            |
| Exercise | 유저의 운동종목 추가, 수정, 삭제                                       |
| Setting  | 유저의 프로필 이미지 등록 및 닉네임 설정 등 그 외의 자잘한 기능들 포함 |

## CI

Github Action을 활용하여 메인 branch에 코드가 붙기전 빌드 및 테스트 케이스를 검증

## CD

Fastlane을 이용하여 배포 절차 간소화

1. 배포용 인증서 및 프로비저닝 프로파일을 Private Repository(storage: git)에 저장
2. match를 활용하여 storage로 부터 필요한 프로비저닝 프로파일 다운
3. 다운 받은 프로파일을 이용하여 앱 빌드
4. App Store Connect API 인증
5. 테스트 플라이트 배포
