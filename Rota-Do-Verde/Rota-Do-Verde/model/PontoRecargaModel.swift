import Foundation
import SwiftUI
import Combine

struct PontoRecarga: Codable, Identifiable {
    let id : String
    let nome : String
    let descricao : String?
    let status : String
    let latitude : String
    let longitude : String
    let endereco : String
    let conectores : [Conector]
    let servicos : [String]
    let ultimaAtualizacao : String?
    let ativo : Bool?
    
    enum ContContent: String, Codable {
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
