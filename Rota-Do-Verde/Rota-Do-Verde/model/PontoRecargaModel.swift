import Foundation
import CoreLocation

struct PontoRecarga: Codable, Identifiable {
    let id: String
    let nome: String
    let descricao: String?
    let status: String
    let latitude: Double
    let longitude: Double
    let endereco: String
    let conectores: [Conector]
    let servicos: [String]
    let ultimaAtualizacao: String?
    let ativo: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case nome
        case descricao
        case status
        case latitude
        case longitude
        case endereco
        case conectores
        case servicos
        case ultimaAtualizacao = "ultima_atualizacao"
        case ativo
    }
}

struct Conector: Codable {
    let tipo: String
    let potenciaKW: Int

    enum CodingKeys: String, CodingKey {
        case tipo
        case potenciaKW = "potencia_kw"
    }
}

extension PontoRecarga {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
