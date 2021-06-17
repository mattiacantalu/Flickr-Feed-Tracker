import Foundation

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
