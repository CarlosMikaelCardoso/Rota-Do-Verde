import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida."
        case .invalidResponse:
            return "Resposta inválida do servidor."
        case .serverError(let message):
            return message
        case .decodingError:
            return "Erro ao interpretar os dados da API."
        case .unknown:
            return "Erro desconhecido."
        }
    }
}

final class APIService {
    static let shared = APIService()
    
    // Se for testar em iPhone físico, troque pelo IP da sua máquina na rede
    private let baseURL = "http://10.119.172.36:1880"
    
    private init() {}
    
    // MARK: - GET
    private func fetch<T: Decodable>(_ endpoint: String, responseType: T.Type) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let apiError = try? JSONDecoder().decode(ErroResponse.self, from: data) {
                throw APIError.serverError(apiError.erro)
            }
            throw APIError.serverError("Erro HTTP: \(httpResponse.statusCode)")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    // MARK: - POST
    private func post<T: Encodable, U: Decodable>(
        _ endpoint: String,
        body: T,
        responseType: U.Type
    ) async throws -> U {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let apiError = try? JSONDecoder().decode(ErroResponse.self, from: data) {
                throw APIError.serverError(apiError.erro)
            }
            throw APIError.serverError("Erro HTTP: \(httpResponse.statusCode)")
        }
        
        do {
            return try JSONDecoder().decode(U.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    // MARK: - PATCH
    private func patch<T: Encodable, U: Decodable>(
        _ endpoint: String,
        body: T,
        responseType: U.Type
    ) async throws -> U {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let apiError = try? JSONDecoder().decode(ErroResponse.self, from: data) {
                throw APIError.serverError(apiError.erro)
            }
            throw APIError.serverError("Erro HTTP: \(httpResponse.statusCode)")
        }
        
        do {
            return try JSONDecoder().decode(U.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    // MARK: - POST sem body
    private func postWithoutBody<U: Decodable>(
        _ endpoint: String,
        responseType: U.Type
    ) async throws -> U {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let apiError = try? JSONDecoder().decode(ErroResponse.self, from: data) {
                throw APIError.serverError(apiError.erro)
            }
            throw APIError.serverError("Erro HTTP: \(httpResponse.statusCode)")
        }
        
        do {
            return try JSONDecoder().decode(U.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    // MARK: - Pontos
    
    func buscarPontos() async throws -> [PontoRecarga] {
        try await fetch("/pontos", responseType: [PontoRecarga].self)
    }
    
    func buscarPontoPorId(_ id: String) async throws -> PontoRecarga {
        try await fetch("/ponto/\(id)", responseType: PontoRecarga.self)
    }
    
    func buscarPontosFiltrados(
        conector: String? = nil,
        potenciaMin: Int? = nil,
        status: String? = nil,
        servico: String? = nil
    ) async throws -> [PontoRecarga] {
        
        var components = URLComponents(string: baseURL + "/pontos/filtros")
        var queryItems: [URLQueryItem] = []
        
        if let conector, !conector.isEmpty {
            queryItems.append(URLQueryItem(name: "conector", value: conector))
        }
        
        if let potenciaMin {
            queryItems.append(URLQueryItem(name: "potencia_min", value: String(potenciaMin)))
        }
        
        if let status, !status.isEmpty {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        
        if let servico, !servico.isEmpty {
            queryItems.append(URLQueryItem(name: "servico", value: servico))
        }
        
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let apiError = try? JSONDecoder().decode(ErroResponse.self, from: data) {
                throw APIError.serverError(apiError.erro)
            }
            throw APIError.serverError("Erro HTTP: \(httpResponse.statusCode)")
        }
        
        do {
            return try JSONDecoder().decode([PontoRecarga].self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    func criarPonto(_ ponto: CriarPontoRequest) async throws -> MensagemResponse {
        try await post("/pontos", body: ponto, responseType: MensagemResponse.self)
    }
    
    func editarPonto(id: String, body: EditarPontoRequest) async throws -> MensagemResponse {
        try await patch("/ponto/\(id)", body: body, responseType: MensagemResponse.self)
    }
    
    func ocuparPonto(id: String) async throws -> MensagemResponse {
        try await postWithoutBody("/ponto/\(id)/ocupar", responseType: MensagemResponse.self)
    }
    
    func desocuparPonto(id: String) async throws -> MensagemResponse {
        try await postWithoutBody("/ponto/\(id)/desocupar", responseType: MensagemResponse.self)
    }
    
    // MARK: - Veículos
    
    func buscarVeiculos() async throws -> [Veiculo] {
        try await fetch("/veiculos", responseType: [Veiculo].self)
    }
    
    func buscarCompatibilidade(veiculoId: String) async throws -> CompatibilidadeResponse {
        try await fetch("/compatibilidade/\(veiculoId)", responseType: CompatibilidadeResponse.self)
    }
    
    // MARK: - Sugestões
    
    func enviarSugestaoCorrecao(_ sugestao: CriarSugestaoCorrecaoRequest) async throws -> MensagemResponse {
        try await post("/sugestoes-correcao", body: sugestao, responseType: MensagemResponse.self)
    }
}
