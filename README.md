# Flickr Feed Tracker
Sample iOS application to understand how `Flickr Feed Tracker` works.

The project is oriented toward the following patterns: 

✅ MVVM Architecture

✅ Protocol Oriented

✅ Functional Programming

✅ Clean Code

✅ Dependency Injection

✅ Unit Tests

It's based on a `GET` API request, fired by GPS location updates, and built over a `UITableViewController`.
Core network services are implemented using `Concurrency Async/Await`, handling and throwing errors if needed.

## HOW IT WORKS

The main controller is built by 4 files
1. Coordinator (routing layer)
2. Model (model)
3. ViewModel (business logic for a use case)
4. View (display data)


### CONFIGURATION

The coordinator layer performs the injection:

🔸 Model

🔸 ViewModel

    let viewModel = ListViewModel(service: service,
                                  imageDownloader: imageDownloader)


... building the main services of the application:

🔸 Cache and Image services
    
    let imageDownloader = MImageDownloader(configuration: KomootSession.imgsConfiguration,
                                           cache: MCacheService())
    

🔸 Network Service

```
struct MURLConfiguration {
    let service: MURLService
    let baseUrl: String
    let apiKey: String

    init(service: MURLService,
         baseUrl: String,
         apiKey: String) {
        self.service = service
        self.baseUrl = baseUrl
        self.apiKey = apiKey
    }
}
    
let service = MServicePerformer(configuration: configuration)
```  

### MVVM FLOW

1. View calls ViewModel

```
func startTracking() {
    locationModel.requestAuthorization()
    locationModel.onAuthorization = { [weak self] in
        self?.locationModel.startTrack()
    }
    locationModel.onDeny = {
        self.error = NSError.deny
    }
    locationModel.onLocationUpdate = { [weak self] _ in
        self?.loadData()
    }
}
```

2. ViewModewl performs the business logic

```
extension ListViewModel {
@MainActor
func fetch(success: @escaping ([ListCellViewModel]) -> Void,
            failure: @escaping (Error) -> Void) {
    Task {
        do { success(onSuccess(recent: try await service.recentPhotos(page: 1, perPage: 1))) }
        catch { failure(error) }
    }
}
```
```
struct Recent: Codable {
let photo: Photos

private enum CodingKeys : String, CodingKey {
    case photo = "photos"
    }
}

struct Photos: Codable {
    let photos: [Photo]

    private enum CodingKeys : String, CodingKey {
        case photos = "photo"
    }
}
```


3. View updates the UI

```
private var dataSource: [ListCellViewModel] {
    didSet { tableView.reloadData() }
}
```

### CORE SERVICES

1. `MServicePerformer` makes the requests

```
struct MServicePerformer {
    private let configuration: MURLConfiguration

    init(configuration: MURLConfiguration) {
        self.configuration = configuration
    }

    var baseUrl: URL? {
        URL(string: configuration.baseUrl)
    }

    private var apiKey: String {
        configuration.apiKey
    }

    func makeRequest<T: Decodable>(_ request: MURLRequest,
                                   map: T.Type) async throws -> T {
        let (data, response) = try await configuration
            .service
            .performTask(with: request
                .appendQuery(name: MConstants.URL.Query.Keys.apiKey,
                             value: apiKey)
                .build())
        return try makeDecode(response: data, urlResponse: response, map: map)
    }
    
    [...]
}
```

2. `MURLService` is a concrete implementation of `MURLServiceProtocol`: manages the `performTask` and dispatches the response

```
extension MURLService: MURLServiceProtocol {
    @MainActor
    func performTask(with request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.dataTask(with: request)
    }

    @MainActor
    func performTask(with url: URL) async throws -> (Data, URLResponse) {
        try await session.dataTask(with: url)
    }
}
```

3. `MURLSession` implements the `MURLSessionProtocol`, creating network tasks

```
func dataTask(with request: URLRequest) async throws -> (Data, URLResponse) {
    try await session.data(for: request)
}

func dataTask(with url: URL) async throws -> (Data, URLResponse) {
    try await session.data(from: url)
}
```

4. `MServicePerformer` also makes the deconding and mapping, based on generic `Decodable` objects

```
private func makeDecode<T: Decodable>(response: Data,
                                      urlResponse: URLResponse,
                                      map: T.Type) throws -> T {

let statusCode = urlResponse.httpResponse?.statusCode ?? MConstants.URL.statusCodeOk

guard statusCode.inRange(MConstants.URL.statusCode2xx) else {
        throw MServiceError.generic(error: statusCode)
}

    return try decode(response: response, map: map)
}
    
private func decode<T: Decodable>(response: Data,
                                  map: T.Type) throws -> T {
    try JSONDecoder().decode(map, from: response)
}
```

5. Images are downloaded by `MImageDownloader`, using `MCacheable` to cache them

```
func downloadImage(from link: String) async throws -> Data {
    guard let imageUrl = baseUrl.url?.appending(path: link) else {
        throw MServiceError.couldNotCreate(url: link)
    }
    return try await makeRequest(with: imageUrl)
}

func makeRequest(with url: URL) async throws -> Data {
    guard let cached = cache.object(for: url.absoluteString) as? Data else {
        return try await perform(url: url)
    }
    return cached
}

func perform(url: URL) async throws -> Data {
    let (data, response) = try await configuration.service.performTask(with: url)
    guard response.succeeded else { throw MServiceError.noImageData }
    cache.set(obj: data, for: url.absoluteString)
    return data
}
```

## Comands (fetch recent photos)

The _fetch recent photos_ request (one of the commands) is implemented inside `RecentPhotosCommands` as an extension of `MServicePerformer`, conformed to `MServicePerformerProtocol`

```
func recentPhotos(page: Int,
                  perPage: Int) async throws -> Recent {

    guard let url = baseUrl else {
        throw MServiceError.couldNotCreate(url: baseUrl?.absoluteString)
    }

    let request = { () -> MURLRequest in
        MURLRequest
            .get(url: url)
            .appendQuery(name: MConstants.URL.Query.Keys.method,
                         value: MConstants.URL.Query.Values.getRecent)
            .appendQuery(name: MConstants.URL.Query.Keys.perPage,
                         value: perPage.stringValue)
            .appendQuery(name: MConstants.URL.Query.Keys.page,
                         value: page.stringValue)
            .appendQuery(name: MConstants.URL.Query.Keys.format,
                         value: MConstants.URL.Query.Values.json)
            .appendQuery(name: MConstants.URL.Query.Keys.jsonCallback,
                         value: "1")
    }

    return try await makeRequest(request(), map: Recent.self)
}
```

### TESTS

Each module is unit tested (mocks oriented): decoding, mapping, services, model, viewModel:

1. viewModel sample test


```
@MainActor
func testFetch_withSucceededService_shouldInsertItem() throws {
    service?.recentPhotoHandler = {
        XCTAssertEqual($0, 1)
        XCTAssertEqual($1, 1)
        return Recent.mock
    }

    XCTAssertEqual(sut?.viewModel.count, 0)

    sut?.fetch(success: {
        XCTAssertEqual($0.count, 1)
        XCTAssertNotNil($0.first)
        self.fetchExpectation?.fulfill()
    }, failure: { XCTFail("Expected success. Got \($0)") })
    wait(for: [try XCTUnwrap(fetchExpectation)], timeout: 5.0)

    XCTAssertEqual(service?.counterRecentPhoto, 1)
    XCTAssertEqual(sut?.viewModel.count, 1)
}
```


2. Comand (decoding and mapping) test

```
func testGetRecentPhotosResponseShouldSuccess() async throws {
    let data = JSONMock.loadJson(fromResource: "valid_get_recent_photos")
    let session = MockedSession(data: try XCTUnwrap(data), response: .init()) { _ in }

    let recent = try await MServicePerformer(configuration: configure(session))
        .recentPhotos(page: 1, perPage: 1)
    XCTAssertEqual(recent.photo.photos.count, 1)
    XCTAssertEqual(recent.photo.photos.first?.id, "52914499467")
    XCTAssertEqual(recent.photo.photos.first?.secret, "60d1f65afa")
    XCTAssertEqual(recent.photo.photos.first?.serverId, "65535")
}
```


3. API Request tests

```
func testGetRecentPhotosRequest() async throws {
    let data = JSONMock.loadJson(fromResource: "valid_get_recent_photos")
    let session = MockedSession(data: try XCTUnwrap(data), response: .init()) {
        XCTAssertEqual($0.url?.absoluteString, "https://www.flickr.com/services/rest?method=flickr.photos.getRecent&per_page=1&page=1&format=json&nojsoncallback=1&api_key=123")
        XCTAssertEqual($0.httpMethod, "GET")
    }

    _ = try await MServicePerformer(configuration: configure(session))
        .recentPhotos(page: 1, perPage: 1)
}
```


## CONTRIBUTORS
Any suggestions are welcome 👨🏻‍💻

## REQUIREMENTS
• Swift 5.7

• Xcode 14.3
