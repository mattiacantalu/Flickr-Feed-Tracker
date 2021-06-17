extension Swift.Optional {
    func fold<T>(some: (Wrapped) -> T, none: () -> T) -> T {
        guard let unwrapped = self else {
            return none()
        }
        return some(unwrapped)
    }

    
    func filter(_ predicate: (Wrapped) throws -> Bool) rethrows -> Wrapped? {
        try flatMap { try predicate($0) ? self : nil }
    }
}

func zip2<A, B>(_ first: A?, _ second: B?) -> (A, B)? {
    guard let first = first, let second = second else { return nil }
    return (first, second)
}
