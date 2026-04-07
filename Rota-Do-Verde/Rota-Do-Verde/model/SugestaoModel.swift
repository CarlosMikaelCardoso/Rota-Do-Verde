import Foundation

struct CriarSugestaoCorrecaoRequest: Codable {
    let pontoId: String
    let campoSugerido: String
    let valorSugerido: String
    let descricao: String

    enum CodingKeys: String, CodingKey {
        case pontoId = "ponto_id"
        case campoSugerido = "campo_sugerido"
        case valorSugerido = "valor_sugerido"
        case descricao
    }
}
