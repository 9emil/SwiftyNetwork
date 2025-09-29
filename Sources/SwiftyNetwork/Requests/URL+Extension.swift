//
//  URL+Extension.swift
//  SwiftyNetwork
//
//  Created by Emil Andersen on 29/09/2025.
//

import Foundation

extension URL {
    func appendingQueryItems(_ items: [URLQueryItem]) -> URL {
        guard var comps = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        var qi = comps.queryItems ?? []
        qi.append(contentsOf: items)
        comps.queryItems = qi
        return comps.url ?? self
    }
}
