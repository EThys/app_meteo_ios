//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Muzola Ethberg on 19/04/2025.
//

import Foundation


class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherData?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let apiKey = "0643feaedc7fbdc0fe814f08a27ccbb8" // Votre clé API
    
    func fetchWeather(for city: String) {
        isLoading = true
        errorMessage = nil
        
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric&lang=fr"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur réseau: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Aucune donnée reçue"
                    return
                }
                
                // Pour débogage - affiche la réponse JSON brute
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Réponse JSON brute:", jsonString)
                }
                
                do {
                        let decoder = JSONDecoder()
                                    // Utilisez cette stratégie pour convertir les snake_case en camelCase
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let weatherResponse = try decoder.decode(WeatherData.self, from: data)
                             self.weather = weatherResponse
                } catch {
                        self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                        print("Erreur détaillée:", error)
                        // Affichez la réponse pour débogage
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("Réponse JSON brute:", jsonString)
                        }
                }
            }
        }.resume()
    }
}
