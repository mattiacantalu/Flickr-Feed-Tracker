import Foundation

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

struct Photo: Codable {
    let serverId: String
    let id: String
    let secret: String

    private enum CodingKeys : String, CodingKey {
        case serverId = "server", id = "id", secret = "secret"
    }
}

struct MError: Codable {}
