# MVVM/Rx를 적용한 오픈마켓 프로젝트

## 목차
- [🛒 프로젝트 소개](#-프로젝트-소개)
- [🛒 Architecture](#-architecture)
- [🛒 Foldering](#-foldering)
- [🛒 Feature-1. 네트워크 구현](#-feature-1-네트워크-구현)
    + [고민한 점](#1-1-고민한-점) 
    + [Trouble Shooting](#1-2-trouble-shooting)
    + [키워드](#1-3-키워드)
- [🛒 Feature-2. 상품 목록 화면 구현](#-feature-2-상품-목록화면-구현)
    + [고민한 점](#2-1-고민한-점)
    + [Trouble Shooting](#2-2-trouble-shooting)
    + [키워드](#2-3-키워드)
- [🛒 Feature-3. 상품 상세화면 구현](#-feature-3-상품-상세화면-구현)
    + [고민한 점](#3-1-고민한-점) 
    + [Trouble Shooting](#3-2-trouble-shooting)
    + [키워드](#3-3-키워드)

## 🛒 프로젝트 소개
`Network` 통신으로 서버에서 데이터를 받아 `CollectionView`로 상품의 목록화면 및 상세화면을 보여줍니다.   
`MVVM-C` 및 `RxSwift`를 적용했습니다.
   
- 참여자 : 호댕 @yanghojoon, 애플사이다 @just1103 (2명)
- 진행 기간 : 2022.04.20 - 2022.05.17 (총 4주)   
<br/>
   
|1. MenuBar|2. 목록 스크롤|3. 다음 목록 업데이트|4. 신상품 추가 알림|5. 상품 상세|
|-|-|-|-|-|
|<img width="200" src="https://user-images.githubusercontent.com/90880660/168954925-72b87ded-3bde-48f9-b8ca-d1912f77cdc1.gif">|<img width="200" src="https://user-images.githubusercontent.com/90880660/168954948-93e03109-6721-42dc-b6ca-2fb40548795c.gif">|<img width="200" src="https://user-images.githubusercontent.com/90880660/168954930-64d8a698-a983-496b-85b7-3803b60d1869.gif">|<img width="200" src="https://i.imgur.com/ej6Iw9R.gif">|<img width="200" src="https://user-images.githubusercontent.com/90880660/168954936-fdc34d74-6d4f-4d40-86f0-5b20861f2c75.gif">|

## 🛒 Architecture
![image](https://user-images.githubusercontent.com/70856586/168956710-3186bbf6-7521-433b-a184-fb83dd3e25bb.png)

## 🛒 Foldering
```
├── OpenMarket
│   ├── App
│   ├── Presentation
│   │   ├── ProductListView
│   │   │   ├── View
│   │   │   ├── ViewModel
│   │   ├── ProductDetailView
│   │   │   ├── View
│   │   │   ├── ViewModel
│   ├── Network
│   ├── Model
│   ├── Utility
│   ├── Protocol
│   ├── Extension
│   └── Resource
└── OpenMarket-Tests
    └──Mock
```

## 🛒 Feature-1. 네트워크 구현
### 1-1 고민한 점
#### 1️⃣ MockURLSession을 통한 테스트
아래의 목적을 위해 `MockURLSession`을 구현했습니다.
- 실제 서버와 통신할 경우 테스트의 속도가 느려짐
- 인터넷 연결상태에 따라 테스트 결과가 달라지므로 테스트 신뢰도가 떨어짐
- 실제 서버와 통신을 하며 서버에 테스트 데이터가 불필요하게 업로드되는 Side-Effect가 발생함

또한 향후 테스트 대상 파일이 늘어날 것에 대비하여 Mock 데이터로 JSON 파일을 추가하고, `Bundle(for: type(of: self))`로 데이터에 접근했습니다.

#### 2️⃣ API 추상화
API를 열거형으로 관리하는 경우, API를 추가할 때마다 새로운 case를 생성하여 열거형이 비대해지고, 열거형 관련 switch문을 매번 수정해야 하는 번거로움이 있었습니다.
따라서 API마다 독립적인 구조체 타입으로 관리되도록 변경하고, URL 프로퍼티 외에도 HttpMethod 프로퍼티를 추가한 `APIProtocol` 타입을 채택하도록 개선했습니다. 이로써 코드유지 보수가 용이하며, 협업 시 각자 담당한 API 구조체 타입만 관리하면 되기 때문에 충돌을 방지할 수 있습니다.

### 1-2 Trouble Shooting
#### 1️⃣ Mock 데이터 접근 시 Bundle에 접근하지 못하는 문제
- 문제점 : `JSON Decoding` 테스트를 할 때, `Bundle.main.path`를 통해 Mock 데이터에 접근하도록 했는데, path에 nil이 반환되는 문제가 발생했습니다. LLDB 확인 결과 Mock 데이터 파일이 포함된 Bundle은 `OpenMarketTests.xctest`이며, 테스트 코드를 실행하는 주체는 `OpenMarket App Bundle`임을 파악했습니다. 
- 해결방법 : 현재 executable의 Bundle 개체를 반환하는 `Bundle.main` (즉, App Bundle)이 아니라, 테스트 코드를 실행하는 주체를 가르키는 `Bundle(for: type(of: self))` (즉, XCTests Bundle)로 path를 수정하여 문제를 해결했습니다.
이외에도 테스트 코드 내부에서 옵셔널 바인딩을 하는 경우 else문에 `XCTFail()`을 추가하여 예상 결과값이 반환되지 않았음에도 테스트를 Pass하는 오류를 방지했습니다.

#### 2️⃣ Rx를 사용한 네트워크 처리 시 불필요한 Subscribe 삭제
- 문제점 : 기존에는 `loadData()`, `request(api:)`, `fetchData(api:decodingType:)`으로 나누어 해당 메서드에서 전부 Observable을 create하고 순차적으로 `subscribe`를 하여 네트워크를 처리하는 방법을 사용했습니다. 이때 `subscribe`를 최소화하는 방향으로 개선하려 했으나, 단순히 `map`을 사용해 데이터를 가공하고 넘겨주는 경우 `onError`를 통해 발생하는 에러를 처리하지 못하는 문제가 존재했습니다.
- 해결방법 : 서버에서 데이터를 받아오는 `fetchData(api:decodingType:)`와 데이터를 요청하는 `request(api:)`메서드로 분리하고, `dataTask(api:emitter:)`메서드에서 `URLSession`의 `dataTask` 메서드를 실행시켜 에러를 던지도록 개선했습니다.

### 1-3 키워드
- Network : 비동기 처리, URLSession, MultipartFormData, REST-ful API
- TDD : MockURLSession, MockData
- SPM : RxSwift/RxCocoa, SwiftLint
- JSON Parsing, Generics
- Cache, Notification, Alert

## 🛒 Feature-2. 상품 목록화면 구현
### 2-1 고민한 점 
#### 1️⃣ DiffableDataSource 및 Snapshot 활용
상품 목록은 크게 `Banner Section` 및 `List Section`으로 구분했습니다. `DiffableDataSource`를 활용하여 `CollectionView`에 나타낼 데이터 타입 (UniqueProduct)은 `Hashable`을 채택하도록 했습니다. 또한 `HeaderView`를 통해 각 Section의 타이틀을 나타냈고, `Banner Section`의 `FooterView`를 통해 배너 이미지의 `PageControl`을 보여주도록 했습니다.
또한 RxSwift를 통해 ViewModel과 ViewController를 Binding 시켜서 역할을 분리했습니다. 예를 들어 상품 목록화면에서 스크롤을 최하단으로 내리면, ViewModel은 서버를 통해 상품 목록을 업데이트하고, ViewController는 Snapshot을 apply하여 화면을 다시 그리도록 했습니다.

#### 2️⃣ CompositionalLayout 활용
`CompositionalLayout`을 활용하여 Item/Group/Section 요소를 반응성 있게 배열했습니다. 또한 높이는 `estimatedHeight`, 너비는 `fractionalWidth`를 활용하여 Cell의 크기가 Device에 따라 유동적으로 조절됩니다. 특히 `estimatedHeight`를 사용하여 Cell의 높이를 고정하지 않고, Cell의 내부 구성에 따라 자동으로 산정하도록 했습니다.
또한 현재 Layout 스타일이 Grid인지, Table인지에 따라 `CollectionView`의 `columnCount`를 바뀌도록 구현했습니다.

#### 3️⃣ Observable Subscribe 최소화 
Stream이 발생하는 경우, Observable을 최종 사용하는 위치에서만 `Subscribe`하여 Stream이 끊기지 않도록 구현했습니다. 따라서 Observable을 생성하고 이를 처리하는 중간 단계에서는 `flatmap`, `map`, `filter` 등을 사용하여 필요한 형태로 변경만 해준 뒤 Observable 타입을 반환하도록 구현했습니다.

#### 4️⃣ Flow Coordinator 활용
Coordinator에서 모든 화면의 ViewController 및 ViewModel을 초기화하여 의존성을 관리하고, 화면 전환을 담당하도록 구현했습니다. 이때 화면 전환에 필요한 작업은 Coordinator에서 정의하여 클로저 타입의 변수로 구성된 action에 저장해두고, ViewModel에서 해당 action에 접근하여 클로저를 실행하도록 했습니다.

#### 5️⃣ UnderlinedMenuBar 구현
최근 상용앱에서 흔히 사용하는 Custom MenuBar를 구현했습니다. Custom Component이므로 `SegmentedControl` 보다는 `Button`을 활용하여 자유롭게 기능을 구현할 수 있도록 했습니다.
Grid 및 Table의 2개 `Button`으로 구성하고, 각 버튼을 탭하면 CollectionView의 Layout이 변경되도록 했습니다. 또한 UIView로 Button 하단에 Underline을 표현하고, animate 메서드를 통해 Underline이 이동하는 애니메이션 효과를 적용했습니다. 이때 Underline의 위치를 변경하기 위해 기존 constraint를 deactivate하고, frame origin을 각 Button의 frame origin으로 할당했습니다.
UnderlinedMenuBar 위치는 기존에는 NavigationBar의 `titleView`로 배치했지만, 화면 전환 시 시스템이 `titleView`의 크기를 재조정하는 문제가 발생하여 NavigationBar 대신 SafeArea 상단에 위치하도록 개선했습니다.

#### 6️⃣ 새로운 상품이 등록되는 경우 Banner 변경
앱을 사용하던 도중 새로운 할인상품이 등록되는 경우 Banner의 Item도 변경을 해야 할 지에 대해 고민했습니다. 대부분의 상용앱은 배너가 자주 변경되지 않기 때문에, 앱을 사용하는 도중에 배너가 바뀌지 않도록 구현했습니다.

### 2-2 Trouble Shooting
#### 1️⃣ UniqueProduct 타입을 추가하여 Hashable Item 생성
- 문제점 : `Banner`에 `List`의 전체 상품 중에서 할인이 적용된 최근 5개 상품이 나타나도록 구현했습니다. 그 과정에서 `Banner` 및`List`에 동일한 ID의 상품을 적용해야 했는데, DiffableDataSource의 Item이 Unique하지 않아서 일부 상품이 화면에 그려지지 않았습니다.
- 해결방법 : 기존 `Product` 타입에 UUID 타입의 프로퍼티를 추가한 `UniqueProduct` 타입을 추가하고, 서버에서 받은 상품 정보를 `Banner`와 `List`에 전달하기 전에 UniqueProduct 타입으로 변환시켜서 Item이 충돌하지 않도록 개선했습니다.

#### 2️⃣ CollectionView Layout을 Table 및 Grid 스타일로 변경
- 문제점 : `UnderlinedMenuBar`를 탭해서 CollectionView의 Layout을 변경할 때, 기존에 화면에 보이던 Cell은 스타일이 변하지 않고 유지되는 문제가 있었습니다. 
- 해결방법 : MenuBar를 탭할 경우 각 스타일에 해당하는 Layout을 생성 및 적용하고, `reloadData` 메서드를 호출했습니다.

### 2-3 키워드
- CollectionView : DiffableDataSource, CompositionalLayout/estimatedHeight, Header/Footer
- Architecture : MVVM-C, FlowCoordinator
- UI : Build UI Programmatically, Deactivate Layout, Custom MenuBar

## 🛒 Feature-3. 상품 상세화면 구현
### 3-1 고민한 점 
#### 1️⃣ orthogonalScrollingBehavior를 활용한 Pagination
Section 마다 Scroll Direction을 다르게 지정하기 위해 고민했습니다. CollectionView의 main layout axis와 반대 방향으로 Scroll 되도록 설정할 수 있는 `orthogonalScrollingBehavior`을 활용했습니다.
또한 상품 이미지를 나타낼 때, Pagination을 구현하여 화면 양 끝에 다른 이미지들의 일부가 보이도록 했습니다. 

### 3-2 Trouble Shooting
#### 1️⃣ Horizontal Scroll 시 현재 페이지를 PageControl에 반영
- 문제점 : 상품 이미지를 CollectionView Pagination으로 나타내고, Horizontal Scroll을 할 때마다 현재 페이지가 PageControl에 반영되도록 구현했습니다. 기존에는 `collectionView(:willDisplay:forItemAt:)`와 `collectionView(:didEndDisplaying:forItemAt:`의 indexPath.row를 비교하여 둘이 다른 경우에 스크롤이 되었다고 판단하여 현재 페이지를 계산하는 로직을 사용했습니다. 하지만 이 경우 Horizontal Scroll을 부정확하게 인식하는 문제가 있었습니다. 
- 해결방법 : section의 `visibleItemsInvalidationHandler` 클로저를 활용해 현재 페이지를 파악하도록 개선했습니다.

```swift
section.visibleItemsInvalidationHandler = { [weak self] _, contentOffset, environment in
    let bannerIndex = Int(max(0, round(contentOffset.x / environment.container.contentSize.width)))
    self?.imagePageControl.currentPage = bannerIndex
}
```

### 3-3 키워드
- CollectionView : Pagination, OrthogonalScrollingBehavior
- PageControl
- AttributedString
