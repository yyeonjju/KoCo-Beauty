
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
- ETC. : KakaoMapSDK, CoreLocation, GitHub Actions


<br/><br/>



## 📝 핵심 기능
- 위치 기반 주변 코스메틱 매장 검색
- 기기에 저장된 언어 우선순위 기반 언어 현지화(한국어, 영어, 중국어)
- 특정 매장에 대한 메타데이터 제공
- 매장에 대한 리뷰 작성 및 플래그 기능


<br/><br/>


## ✅ 핵심 기술 구현 사항
- Github Submodule과 Lokalise를 결합해 사용하여 다국어 리소스를 Project Repository와 분리하여 효율적으로 관리
- Github Actions를 활용하여 다국어 리소스 업데이트로 인한 Submodule Repository의 PR 생성 시점부터 Project Repository에 Submodule을 최신화 하는 과정까지 자동화된 파이프라인으로 관리
- ETag(Entity tag) 기반 이미지 캐싱 도입으로 서버와 이미지 리소스 버전 동기화 및 이미지 로드 시간/서버 부하 감축
- 데이터 소스에 대한 의존성을 줄이기 위해 Repository Pattern을 사용하여 데이터 접근 로직을 추상화
- UI에 관한 input을 viewModel에 명시적으로 전달하기 위해 viewModel 내 열거형으로 Action 정의
- 이벤트에 따라 ViewModel의 action메서드에 Action열거형을 인자로 전달하여 단뱡향 데이터 바인딩 지향적인 구조 설계
- 매장 리뷰에 업로드한 사진을 영구적으로 저장하고 조회하기 위해 FileManager 사용하여 저장/조회 로직 구현
- UIKit 기반 코드를 SwiftUI 프로젝트에 사용하기 위해 UIViewRepresentable, Coordinator을 기반으로 래핑
- CoreLocation을 사용해 위치 권한 및 사용자의 위치 정보 획득


<img width="800" alt="Architecture(KoCo)" src="https://github.com/user-attachments/assets/33b06824-205d-4752-8dc0-ea7275171e3e" />


<br/><br/>


## 💎 주요 구현 내용
### 1. ETag 기반 Image Cache 전략 수립 및 이미지 로딩 성능 4배 향상

#### ETag(Entity tag)기반 이미지 캐시 도입 이유
1. 네트워크 부하 감소 : remoteDB에 저장된 이미지 데이터를 불러오는 네트워킹에 대한 리소스 사용을 최소화
2. 로드 시간 단축 : 이미지 로드 시간을 단축으로 사용자 경험 개선
3. 리소스 변경 여부 서버와 동기화 : ETag 기반의 이미지 캐싱 으로 이미지 리소스 변경에 대해 서버와 동기화

#### 이미지 캐싱 플로우
- 메모리 캐시 Hit -> 디스크 캐시 Hit
- -> 메모리 혹은 디스크에 저장해 놓은 데이터(etag, 이미지 url 등)가 있다면 헤더에 'If-None-Match'를 넣어서 서버에 요청
- -> 304(Not Modified)에러의 경우 기존에 캐싱해 둔 데이터 리턴 / 상태코드가 200일 경우에는 새로 받은 데이터 리턴

<img width="1127" alt="imageCache(etag)" src="https://github.com/user-attachments/assets/45f59867-69e2-4b00-845a-2b799591f64b" />


#### 이미지 캐시 매니저
- Combine Operator를 활용한 Stream 관리
- ImageCachPolicy Enum을 통해 캐싱 정책 관리

```swift 

final class ImageCacheManager {
    // ...
    
    enum ImageCachPolicy {
        case both
        case memoryOnly
        case diskOnly
    }
    
    // ...

    func getImageData(urlString : String, policy : ImageCachPolicy = .both) -> AnyPublisher<Data?, ImageLoadError> {
        let subject = PassthroughSubject<CacheImage?, ImageLoadError>()
        
        switch policy {
        case .both:
            hitMemoryCache(urlString: urlString)
                .catch { [weak self] imageLoadError  in //메모리에 캐싱되어 있지 않을 때
                    guard let self else{
                        return Just<CacheImage?>(nil)
                            .setFailureType(to: ImageLoadError.self)
                            .eraseToAnyPublisher()
                    }
                    //디스크 캐시 조회
                    return self.hitDiskCache(urlString: urlString)
                }
                .subscribe(subject)
                .store(in: &cancellables)
            
        case .memoryOnly:
            // ...
 
        case .diskOnly:
            // ...
        }

        return subject
            .catch { imageLoadError  in
                
                //메모리&디스크에 캐싱되지 않았다는 에러를 받은 경우 -> 기본값으로 내려보냄
                return Just(CacheImage(imageData: Data(), etag: "-"))
                
            }
            .flatMap{[weak self] resultImage -> AnyPublisher<(Data,String?), ImageLoadError> in
                guard let self, let resultImage else {
                    return Fail(error: ImageLoadError.undefinedError).eraseToAnyPublisher()
                }
                let cachedEtag = resultImage.etag
                let cachedImageData = resultImage.imageData
                return self.synchronizeWithServer(urlString : urlString, etag: cachedEtag, cachedImageData : cachedImageData, policy: policy)
                    
            }
            .tryMap {[weak self] (imageData, etag) in
                guard let self else {return imageData}
                return imageData
            }
            .mapError{$0 as! ImageLoadError}
            .eraseToAnyPublisher()

    }
    
    // ...

}

```

#### 서버 데이터 일치 여부 확인 및 304(Not Modified)에러 분기처리
- If-None-Match 헤더를 추가한 http 요청으로 리소스 일치 여부 확인
- 응답의 statusCode를 통해 304에러 분기 처리


```swift 

    func synchronizeWithServer(urlString: String, etag : String, cachedImageData : Data, policy : ImageCachPolicy) -> AnyPublisher<(Data, String?), ImageLoadError> {

        guard let url = URL(string: urlString) else {
            return Fail<(Data, String?), ImageLoadError>(error: ImageLoadError.invalidUrlString).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(etag, forHTTPHeaderField: "If-None-Match")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { [weak self] result -> (Data, String?) in
                guard let self, let httpResponse = result.response as? HTTPURLResponse else {
                    throw ImageLoadError.noResponse
                }
                
                switch httpResponse.statusCode {
                case 200: // 저장된 etag랑 값이 다름 -> 응답으로 받은 데이터 리턴
                    guard let newETag = httpResponse.allHeaderFields["Etag"] as? String else {
                        return (result.data, nil)
                    }
                    
                    //etag 가 있을 경우 캐싱 정책대로 캐싱
                    self.cacheImage(urlString: urlString, imageData: result.data, etag: newETag, policy: policy)
                    return (result.data, newETag)
                    
                case 304: // 저장된 etag랑 같음 -> 저장되어있던 이미지 반환
                    return (cachedImageData, etag)
                default:
                    throw ImageLoadError.undefinedStatusCode
                }

            }
            .mapError { error -> ImageLoadError in
                if let error = error as? ImageLoadError {
                    return error
                } else {
                    return ImageLoadError.unknownError
                }
            }
            .eraseToAnyPublisher()

    }

```

#### OSLog와 instrument를 사용한 이미지 로드 속도 분석
- OSLog의 os_signpost 메서드를 사용하여 캐싱 전후의 이미지 로드 속도 기록
- instrument의 System Trace를 활용해 로드 속도 분석

📍 이미지 로드 시간 75% 단축

> Before : 캐싱 적용 전 이미지 로드 속도 
<img width="450" alt="before_imageCache" src="https://github.com/user-attachments/assets/0d91ff16-3e88-46c9-b904-a65c43673a33" />

> After : 캐싱 적용 후 이미지 로드 속도
<img width="450" alt="after_imageCache" src="https://github.com/user-attachments/assets/1975089d-ea8b-4f7a-b020-705111152646" />


<br/><br/>

### 2. Github Actions를 통해 프로젝트의 다국어 리소스를 자동화된 파이프라인으로 관리

#### 자동화를 위해 활용한 도구
- Github Actions
- Github Submodule
- Lokalise

#### 다국어 리소스 관리 단계
1. 클라우드 기반 다국어 관리 시스템인 Lokalise를 사용해서 다국어 리소스 작업
2. Lokalise를 통해 Github Submodule에 PR 생성
3. PR 생성을 감지해 Submodule의 Workflow(localization.yml) 실행 
4. SwiftGen을 통해 다국어 리소스를 선언적으로 사용가능한 코드로 변환 → 작업 commit & merge → 슬랙 Webhook을 통해 완료 메시지 전달 → 프로젝트 메인 레포지토리에서 Submodule 최신화를 위해 워크플로우 실행할 수 있도록 트리거 발동
5. Submodule이 실행한 트리거 감지해서 프로젝트 메인 레포지토리의 Workflow(updateSubmodule.yml) 실행 
6. Submodule을 최신상태로 업데이트 후 슬랙 Webhook을 통해 완료 메시지 전달


<img width="800" alt="githubActions" src="https://github.com/user-attachments/assets/ccf64235-8b64-430c-8dfe-d6e148ca7744" />


> Submodule Reposiitory의 Workflow (localization.yml)

```yaml


on:
  pull_request_target:
    types:
      - opened
      
permissions: write-all

jobs:

  localization:
    if: startsWith(github.head_ref, 'lokalise')
    runs-on: macos-latest
    steps:
      - name: Check out lokalise branch
        uses: actions/checkout@v3
        with:
          ref: ${{ github.head_ref }}
          
      - name: Print current branch
        run: git branch --show-current
      
      - name: Pull
        run: |
          git pull origin
      
      - name: Install Homebrew
        run: |
          echo "Checking Homebrew..."
          if ! command -v brew &> /dev/null; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          else
            echo "Homebrew already installed."
          fi
          
      - name: Install SwiftGen
        run: |
          brew install swiftgen
            
      - name: Run SwiftGen
        run: |
          swiftgen config run --config swiftgen.yml
          
      - name: commit and push
        uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: "[Success] complete localization build"


  review-and-merge:
    needs: localization
    if: ${{ needs.localization.result == 'success' }}
    
    runs-on: ubuntu-latest
    steps:
      - name: Checkout PR branch
        uses: actions/checkout@v3
        with:
          ref: ${{ github.head_ref }}

      - name: Checkout base branch
        uses: actions/checkout@v3
        with:
          path: base_branch
          ref: ${{ github.base_ref }}

      - name: Get First Commit Message
        id: commit
        uses: actions/github-script@v6
        with:
          script: |
            const { data: commits } = await github.rest.pulls.listCommits({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.payload.pull_request.number
            });
            const firstCommit = commits[0];
            core.setOutput('message', firstCommit.commit.message);
      
      - name: Merge PR
        id: merge
        uses: actions/github-script@v6
        with:
          script: |
            await github.rest.pulls.merge({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: ${{ github.event.pull_request.number }},
              merge_method: 'squash'
            });
        continue-on-error: true
        
      - name: Notify Slack on Merge Success
        if: steps.merge.outcome == 'success'
        uses: slackapi/slack-github-action@v2.0.0
        with:
          webhook: ${{ secrets.SLACK_WEBHOOK_URL }}
          webhook-type: webhook-trigger
          payload: |
            {
            "text": "🎉 PR Merge Success\n\nPR: ${{ github.event.pull_request.html_url }}\nBranch: `${{ github.head_ref }}`\nCommit: ${{ steps.commit.outputs.message }}"
            }
            
  dispatch-main-repo:
    needs: review-and-merge
    if: ${{ needs.review-and-merge.result == 'success' }}
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Main Repository Workflow
        uses: actions/github-script@v6
        with:
          github-token: ${{ secrets.KOCO_GITHUB_TOKEN }}
          script: |
            await github.rest.actions.createWorkflowDispatch({
              owner: 'yyeonjju',
              repo: 'KoCo-Beauty',
              workflow_id: 'updateSubmodule.yml',
              ref: 'develop',
              inputs: {
                name: 'KoCo Main Repository'
              }
            });


```

> Project Repository의 Workflow (updateSubmodule.yml)


```yaml

on:
  workflow_dispatch:
    inputs:
      name:
        description: 'Input name'
        required: true
        type: string
  
permissions: write-all

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true
          token: ${{ secrets.KOCO_GITHUB_TOKEN }}
      
      - name: Pull & update submodules recursively
        run: |
          git submodule update --init --recursive
          git submodule update --recursive --remote
            
      - name: Commit & push
        id: commit
        uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: "[Success] complete update submodule"

      - name: Notify Slack on Submodule Update Success
        if: steps.commit.outcome == 'success'
        uses: slackapi/slack-github-action@v2.0.0
        with:
          webhook: ${{ secrets.SLACK_WEBHOOK_URL }}
          webhook-type: webhook-trigger
          payload: |
            {
            "text": "💎 SubModule Update Success"
            }

```

