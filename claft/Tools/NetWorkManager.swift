//
//  NetWorkManager.swift
//  claft
//
//  Created by zfu on 2021/12/2.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case responseError
    case unknown
}

class NetworkManager {
    static let shared = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    
    func getData<T: Decodable>(url: String, type: T.Type, headers: [String:String] = [:]) -> Future<T, Error> {
        return Future<T, Error> { [weak self] promise in
            guard let self = self, let url = URL(string: url) else {
                return promise(.failure(NetworkError.invalidURL))
            }
            print("request from url \(url)")
            var request = URLRequest(url: url)
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
                print("set header \(header.key) => \(header.value)")
            }
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data: Data, response: URLResponse) in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw NetworkError.responseError
                    }
                    let str = String(data: data, encoding: .utf8)
                    print("str \(str ?? "NA")")
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        switch error {
                        case let decodingError as DecodingError:
                            promise(.failure(decodingError))
                        case let apiError as NetworkError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(NetworkError.unknown))
                        }
                    }
                }, receiveValue: { promise(.success($0)) })
                .store(in: &self.cancellables)
        }
    }
}
