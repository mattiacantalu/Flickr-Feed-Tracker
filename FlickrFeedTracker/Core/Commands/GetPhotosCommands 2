import Foundation

extension MServicePerformerProtocol {
    func recentPhotos(page: Int = MConstants.URL.Query.Values.perPage,
                      perPage: Int = MConstants.URL.Query.Values.perPage) async throws -> Recent {
        return try await recentPhotos(page: page, perPage: perPage)
    }
}

extension MServicePerformer: MServicePerformerProtocol {
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
}

private extension Int {
    var stringValue: String {
        String(self)
    }
}
