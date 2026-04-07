import Foundation

struct EditarPontoRequest: Codable {
    let nome: String?
    let descricao: String?
    let status: String?
    let latitude: Double?
    let longitude: Double?
    let endereco: String?
    let conectores: [Conector]?
    let servicos: [String]?
    let ativo: Bool?
    let ocupado: Bool?
    let ocupadoEm: String?

    enum CodingKeys: String, CodingKey {
        case nome
        case descricao
        case status
        case latitude
        case longitude
        case endereco
        case conectores
        case servicos
        case ativo
        case ocupado
        case ocupadoEm = "ocupado_em"
    }
}
