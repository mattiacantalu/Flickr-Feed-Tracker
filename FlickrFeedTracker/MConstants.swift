struct MConstants {
    static let jpg = "jpg"

    struct URL {
        struct Query {
            struct Keys {
                static let method = "method"
                static let apiKey = "api_key"
                static let page = "page"
                static let perPage = "per_page"
                static let format = "format"
                static let jsonCallback = "nojsoncallback"
            }

            struct Values {
                static let getRecent = "flickr.photos.getRecent"
                static let apiKey = "api_key"
                static let first = 1
                static let perPage = 1
                static let json = "json"
                static let jsonCallback = "1"
            }
        }

        static let base = "https://www.flickr.com/services/rest"
        static let imageBase = "https://live.staticflickr.com/"
        static let statusCodeOk = 200
        static let statusCodemultipleChoice = 300
        static let statusCode2xx = MConstants.URL.statusCodeOk ..< MConstants.URL.statusCodemultipleChoice
    }

    struct Cache {
        static let expiration = 3600
    }
}
