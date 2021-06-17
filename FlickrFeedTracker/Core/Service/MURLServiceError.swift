import Foundation

enum MServiceError: Error {
    case noData
    case couldNotCreate(url: String?)
    case noImageData
    case generic(error: Int)
}
