import Foundation
import CoreLocation

struct PontoRecarga: Codable, Identifiable, Hashable, Equatable {
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
    
    // Compara os objetos usando apenas o ID para melhor performance
    static func == (lhs: PontoRecarga, rhs: PontoRecarga) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Conector: Codable, Hashable, Equatable {
    let tipo: String
    let potenciaKW: Int

    enum CodingKeys: String, CodingKey {
        case tipo
        case potenciaKW = "potencia_kw"
    }
}

extension PontoRecarga {
    var coordenada: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
