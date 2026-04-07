import Foundation

struct CriarPontoRequest: Codable {
    let nome: String
    let descricao: String?
    let status: String?
    let latitude: Double
    let longitude: Double
    let endereco: String
    let conectores: [Conector]
    let servicos: [String]
}
