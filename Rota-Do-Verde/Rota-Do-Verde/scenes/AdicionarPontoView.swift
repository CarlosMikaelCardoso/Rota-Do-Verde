import SwiftUI
import MapKit

struct AdicionarPontoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CriarPontoViewModel()
    
    @State private var mostrandoMapa = false
    @State private var coordenadaSelecionada: CLLocationCoordinate2D?
    
    @State private var mostrarPopupSucesso = false
    @State private var mostrarPopupErro = false
    
    let onPontoCriado: () async -> Void
    
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
                            Text("Escolher no mapa")
                        }
                    }
                    
                    if let coordenadaSelecionada {
                        Text("Latitude: \(coordenadaSelecionada.latitude)")
                            .font(.caption)
                        Text("Longitude: \(coordenadaSelecionada.longitude)")
                            .font(.caption)
                    } else {
                        Text("Nenhum local selecionado")
                            .foregroundColor(.secondary)
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
                            ProgressView("Enviando...")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Adicionar ponto")
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
                            let sucesso = await viewModel.criarPonto()
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
            .alert("Ponto adicionado", isPresented: $mostrarPopupSucesso) {
                Button("OK") {
                    Task {
                        await onPontoCriado()
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.mensagemSucesso ?? "O ponto foi cadastrado com sucesso.")
            }
            .alert("Erro ao adicionar ponto", isPresented: $mostrarPopupErro) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.erro ?? "Ocorreu um erro ao salvar o ponto.")
            }
        }
    }
}

#Preview {
    AdicionarPontoView(onPontoCriado: {})
}
