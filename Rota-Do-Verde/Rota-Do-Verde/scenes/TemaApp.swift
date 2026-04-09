//
//  TemaApp.swift
//  Rota-Do-Verde
//
//  Created by Turma02-2 on 09/04/26.
//


import SwiftUI

// Enum para gerenciar as opções de tema
enum TemaApp: String, CaseIterable {
    case sistema = "Sistema"
    case claro = "Claro"
    case escuro = "Escuro"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .sistema: return nil
        case .claro: return .light
        case .escuro: return .dark
        }
    }
}

struct ConfiguracoesView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("temaApp") private var temaAtual: TemaApp = .sistema
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Aparência") {
                    Picker("Tema do Aplicativo", selection: $temaAtual) {
                        ForEach(TemaApp.allCases, id: \.self) { tema in
                            Text(tema.rawValue).tag(tema)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(temaAtual.colorScheme)
    }
}

#Preview {
    ConfiguracoesView()
}
