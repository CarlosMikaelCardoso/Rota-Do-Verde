//
//  Rota_Do_VerdeApp.swift
//  Rota-Do-Verde
//
//  Created by Turma01-28 on 31/03/26.
//

import SwiftUI

@main
struct Rota_Do_VerdeApp: App {
    // 1. Lemos a variável global salva no AppStorage
    @AppStorage("temaApp") private var temaAtual: TemaApp = .sistema
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 2. Aplicamos o tema diretamente na raiz, forçando todo o app a mudar
                .preferredColorScheme(temaAtual.colorScheme)
        }
    }
}
