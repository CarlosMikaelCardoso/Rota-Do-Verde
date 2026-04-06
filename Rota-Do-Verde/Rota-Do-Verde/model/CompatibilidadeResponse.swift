//
//  CompatibilidadeResponse.swift
//  Rota-Do-Verde
//
//  Created by Turma02-2 on 06/04/26.
//

import Foundation
import Combine
import SwiftUI

struct CompatibilidadeResponse: Codable {
    let veiculos: VeiculoResumo
    let pontosCompativeis: [PontoRecarga]
    
    enum CodingKeys: String, CodingKey {
        case veiculos
        case pontosCompativeis = "pontos_compativeis"
    }
}

struct VeiculoResumo: Codable {
    let id: String
    let marca: String
    let modelo: String
}

