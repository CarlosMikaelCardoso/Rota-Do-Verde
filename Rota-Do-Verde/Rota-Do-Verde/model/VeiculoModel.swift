import Foundation

struct Veiculo: Codable, Identifiable {
    let id: String
    let marca: String
    let modelo: String
    let conectoresCompativeis: [String]
    let potenciaMaxSuportadaKW: Int

    enum CodingKeys: String, CodingKey {
        case id
        case marca
        case modelo
        case conectoresCompativeis = "conectores_compativeis"
        case potenciaMaxSuportadaKW = "potencia_max_suportada_kw"
    }
}

struct VeiculoResumo: Codable {
    let id: String
    let marca: String
    let modelo: String
}
