//
//  VeiculoModel.swift
//  Rota-Do-Verde
//
//  Created by Turma02-2 on 06/04/26.
//

import Foundation
import Combine
import SwiftUI

struct VeiculoModel: Identifiable, Codable {
    let id: String
    let marca: String
    let modelo: String
    let conectoresCompativeis: [String]
    let potenciaMaxSuportadaKW: Int
    
    enum CodingKeys: String, CodingKey {
        case id, marca, modelo
        case conectoresCompativeis = "conectores_compativeis"
        case potenciaMaxSuportadaKW = "potencia_max_suportada_kw"
    }
}
