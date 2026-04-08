import SwiftUI
import MapKit

struct EditarPontoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditarPontoViewModel
    
    @State private var mostrandoMapa = false
    @State private var coordenadaSelecionada: CLLocationCoordinate2D?
    
    @State private var mostrarPopupSucesso = false
    @State private var mostrarPopupErro = false
    
    let onPontoEditado: () async -> Void
    
    init(ponto: PontoRecarga, onPontoEditado: @escaping () async -> Void) {
        _viewModel = StateObject(wrappedValue: EditarPontoViewModel(ponto: ponto))
        self.onPontoEditado = onPontoEditado
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações principais") {
                    TextField("Nome do ponto", text: $viewModel.nome)
                    TextField("Descrição", text: $viewModel.descricao, axis: .vertical)
                    TextField("Endereço", text: $viewModel.endereco, axis: .vertical)
                    
                    Picker("Status", selection: $viewModel.status) {
                        Text("Funcionando").tag("funcionando")
                        Text("Manutenção").tag("manutencao")
                    }
                }
                
                Section("Localização") {
                    Button {
                        mostrandoMapa = true
                    } label: {
                        HStack {
                            Image(systemName: "map")
                            Text("Alterar no mapa")
                        }
                    }
                    
                    if let coordenadaSelecionada {
                        Text("Latitude: \(coordenadaSelecionada.latitude)")
                            .font(.caption)
                        Text("Longitude: \(coordenadaSelecionada.longitude)")
                            .font(.caption)
                    } else {
                        Text("Latitude atual: \(viewModel.latitude)")
                            .font(.caption)
                        Text("Longitude atual: \(viewModel.longitude)")
                            .font(.caption)
                    }
                    
                    TextField("Latitude", text: $viewModel.latitude)
                        .keyboardType(.decimalPad)
                    
                    TextField("Longitude", text: $viewModel.longitude)
                        .keyboardType(.decimalPad)
                }
                
                Section("Conector principal") {
                    TextField("Tipo do conector", text: $viewModel.conectorTipo)
                    TextField("Potência (kW)", text: $viewModel.conectorPotencia)
                        .keyboardType(.numberPad)
                }
                
                Section("Serviços") {
                    TextField("Ex: wifi, banheiro, estacionamento", text: $viewModel.servicosTexto)
                }
                
                if viewModel.carregando {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView("Salvando...")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Editar ponto")
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
                            let sucesso = await viewModel.salvarEdicao()
                            if sucesso {
                                mostrarPopupSucesso = true
                            } else if viewModel.erro != nil {
                                mostrarPopupErro = true
                            }
                        }
                    } label: {
                        if viewModel.carregando {
                            ProgressView()
                        } else {
                            Text("Salvar")
                        }
                    }
                    .disabled(!viewModel.formularioValido || viewModel.carregando)
                }
            }
            .sheet(isPresented: $mostrandoMapa) {
                SelecionarLocalMapaView { coordinate in
                    coordenadaSelecionada = coordinate
                    viewModel.definirCoordenada(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                }
            }
            .alert("Ponto atualizado", isPresented: $mostrarPopupSucesso) {
                Button("OK") {
                    Task {
                        await onPontoEditado()
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.mensagemSucesso ?? "O ponto foi atualizado com sucesso.")
            }
            .alert("Erro ao editar ponto", isPresented: $mostrarPopupErro) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.erro ?? "Ocorreu um erro ao salvar as alterações.")
            }
        }
    }
}
