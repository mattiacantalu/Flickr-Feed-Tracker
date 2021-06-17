import Foundation

class ListCellViewModel {
    private let service: MImageProtocol
    private let photoModel: Photo

    init(service: MImageProtocol,
         photoModel: Photo) {
        self.service = service
        self.photoModel = photoModel
    }

    func fetchImage() async throws -> Data {
        try await service.downloadImage(from: photoModel.imageUrl)
    }
}

private extension Photo {
    var imageUrl: String {
        "\(serverId)/\(id)_\(secret).\(MConstants.jpg)"
    }
}
