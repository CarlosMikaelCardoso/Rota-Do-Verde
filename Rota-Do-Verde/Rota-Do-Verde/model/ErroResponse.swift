import Foundation
struct ErroResponse: Codable {
    let erro: String
    let obrigatorios: [String]?
}
