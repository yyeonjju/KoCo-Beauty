
# KoCo | 한국 코스메틱 앱

![KoCo_En_1](https://github.com/user-attachments/assets/0a1f5473-9fd5-498f-9dc6-7cce7d4ebf9f) |![KoCo_En_2](https://github.com/user-attachments/assets/4ea1a0bd-d490-4dbb-8025-e5d9ea6e85f5) |![KoCo_En_3](https://github.com/user-attachments/assets/f04a665d-f289-4bb1-936a-2ca2926f355f) |![KoCo_En_4](https://github.com/user-attachments/assets/e5b688ae-4fb8-43fa-baaf-2258e7add4f8)
--- | --- | --- | --- |



<br/><br/>

## 🪗 KoCo (Korea Cosmetic) 
- 앱 소개 : K뷰티에 관심있는 외국인 관광객들을 위한 코스메틱 매장/상품 기록 앱
- 개발 인원 : 1인
- 개발 기간 : 약 3주
- 최소 버전 : 16.0


<br/><br/>

## 📎 기술 스택
- UI : SwiftUI
- Reactive : Combine
- Network : URLSession
- Architecture : MVVM
- Local DB : Realm
- ETC. : KakaoMapSDK, CoreLocation


<br/><br/>



## 📝 핵심 기능
- 위치 기반 주변 코스메틱 매장 검색
- 기기에 저장된 언어 우선순위 기반 언어 현지화(한국어, 영어, 중국어)
- 특정 매장에 대한 메타데이터 제공
- 매장에 대한 리뷰 작성 및 플래그 기능


<br/><br/>


## ✅ 핵심 기술 구현 사항
- ETag(Entity tag) 기반 이미지 캐싱 도입으로 서버와 이미지 리소스 버전 동기화 및 이미지 로드 시간/서버 부하 감축
- 데이터 소스에 대한 의존성을 줄이기 위해 Repository Pattern을 사용하여 데이터 접근 로직을 추상화
- UI에 관한 input을 viewModel에 명시적으로 전달하기 위해 viewModel 내 열거형으로 Action 정의
- 이벤트에 따라 ViewModel의 action메서드에 Action열거형을 인자로 전달하여 단뱡향 데이터 바인딩 지향적인 구조 설계
- 매장 리뷰에 업로드한 사진을 영구적으로 저장하고 조회하기 위해 FileManager 사용하여 저장/조회 로직 구현
- UIKit 기반 코드를 SwiftUI 프로젝트에 사용하기 위해 UIViewRepresentable, Coordinator을 기반으로 래핑
- CoreLocation을 사용해 위치 권한 및 사용자의 위치 정보 획득
- String Catalog와 LocalizedStringKey를 통한 다국어 지원


<img width="800" alt="Architecture(KoCo)" src="https://github.com/user-attachments/assets/33b06824-205d-4752-8dc0-ea7275171e3e" />
<img width="1127" alt="imageCache(etag)" src="https://github.com/user-attachments/assets/45f59867-69e2-4b00-845a-2b799591f64b" />


<br/><br/>
