import Foundation

class ListViewModel {
    private let service: MServicePerformerProtocol
    private let imageDownloader: MImageProtocol

    private(set) var viewModel: [ListCellViewModel] = []

    init(service: MServicePerformerProtocol,
         imageDownloader: MImageProtocol) {
        self.service = service
        self.imageDownloader = imageDownloader
    }
}

extension ListViewModel {
    @MainActor
    func fetch(success: @escaping ([ListCellViewModel]) -> Void,
               failure: @escaping (Error) -> Void) {
        Task {
            do { success(onSuccess(recent: try await service.recentPhotos(page: 1, perPage: 1))) }
            catch { failure(error) }
        }
    }
}

private extension ListViewModel {
    func onSuccess(recent: Recent) -> [ListCellViewModel] {
        recent
            .photo
            .photos
            .first
            .map { ListCellViewModel(service: imageDownloader,
                                     photoModel: $0) }
            .map { viewModel.add(model: $0) }
        return viewModel
    }
}

private extension Array where Element == ListCellViewModel {
    mutating func add(model: ListCellViewModel?) {
        model.map { insert($0, at: 0) }
    }
}
