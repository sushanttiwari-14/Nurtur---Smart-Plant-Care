//
//  WeatherService.swift
//  Nurtur
//
//  Created by sushant tiwari on 25/02/26.
//

import Foundation
struct WeatherResponse: Codable {
    let name: String
    let main: Main
}
struct Main : Codable {
    let temp: Double
    let humidity: Int
}
final class WeatherService {

    private var apiKey: String {
        Secrets.WeatherApiKey
    }
    func fetchWeather(for city: String) async throws -> WeatherResponse {
        let urlString = """
        https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)
        """

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
}
