import Foundation

struct CompatibilidadeResponse: Codable {
    let veiculo: VeiculoResumo
    let pontosCompativeis: [PontoRecarga]

    enum CodingKeys: String, CodingKey {
        case veiculo
        case pontosCompativeis = "pontos_compativeis"
    }
}
