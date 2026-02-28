//
//  TestService.swift
//  Nurtur
//
//  Created by sushant tiwari on 25/02/26.
//

import Foundation

struct TestResponse: Decodable {
    let title: String
}

final class TestService {
    
    func fetchTestData() async throws -> TestResponse {
        
        let urlString = "https://jsonplaceholder.typicode.com/posts/1"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(TestResponse.self, from: data)
        
        return decodedResponse
    }
}
