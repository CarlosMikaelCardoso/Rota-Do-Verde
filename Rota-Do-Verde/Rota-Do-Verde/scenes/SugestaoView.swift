import SwiftUI

struct SugestaoView: View {
    let pontoId: String
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SugestaoViewModel()
    
    @State private var campoSugerido = "status"
    @State private var valorSugerido = ""
    @State private var descricao = ""
    
    @State private var mostrarPopupSucesso = false
    @State private var mostrarPopupErro = false
    
    private let camposDisponiveis = [
        "status",
        "nome",
        "descricao",
        "endereco",
        "conectores",
        "servicos"
    ]
    
    private var formularioValido: Bool {
        !valorSugerido.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !descricao.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Sobre a correção") {
                    Picker("Campo", selection: $campoSugerido) {
                        ForEach(camposDisponiveis, id: \.self) { campo in
                            Text(campo.capitalized).tag(campo)
                        }
                    }
                    
                    TextField("Valor sugerido", text: $valorSugerido, axis: .vertical)
                    
                    TextField("Descreva o problema encontrado", text: $descricao, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }
                
                Section {
                    Text("Sua sugestão será salva como pendente para revisão.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if viewModel.carregando {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView("Enviando...")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Sugerir correção")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.enviarSugestao(
                                pontoId: pontoId,
                                campoSugerido: campoSugerido,
                                valorSugerido: valorSugerido,
                                descricao: descricao
                            )
                            
                            if viewModel.mensagemSucesso != nil {
                                mostrarPopupSucesso = true
                            } else if viewModel.erro != nil {
                                mostrarPopupErro = true
                            }
                        }
                    } label: {
                        if viewModel.carregando {
                            ProgressView()
                        } else {
                            Text("Enviar")
                        }
                    }
                    .disabled(!formularioValido || viewModel.carregando)
                }
            }
            .alert("Sugestão enviada", isPresented: $mostrarPopupSucesso) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(viewModel.mensagemSucesso ?? "Sua sugestão foi enviada com sucesso.")
            }
            .alert("Erro ao enviar sugestão", isPresented: $mostrarPopupErro) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.erro ?? "Ocorreu um erro ao enviar a sugestão.")
            }
        }
    }
}

#Preview {
    SugestaoView(pontoId: "ponto_001")
}
