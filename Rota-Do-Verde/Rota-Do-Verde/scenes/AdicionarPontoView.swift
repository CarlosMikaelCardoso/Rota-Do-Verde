import SwiftUI
import MapKit
import CoreLocation
import Contacts

struct AdicionarPontoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CriarPontoViewModel()
    
    @State private var mostrandoMapa = false
    @State private var coordenadaSelecionada: CLLocationCoordinate2D?
    
    @State private var mostrarPopupSucesso = false
    @State private var mostrarPopupErro = false
    
    @State private var endereco: String? = nil
    
    private let TIPOS_DE_CARREGADORES: [String] = [
        "CCS2",
        "Emergência/Portátil",
        "Wallbox",
        "Fast Charge DC",
        "Mennekes",
        "GB/T",
        "Outros"
    ]
    
    let onPontoCriado: () async -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações principais") {
                    TextField("Nome do ponto", text: $viewModel.nome)
                    TextField("Descrição", text: $viewModel.descricao, axis: .vertical)
                    
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
                            .foregroundStyle(.secondary)
                        Text("Longitude: \(coordenadaSelecionada.longitude)")
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(endereco ?? "Nenhum local selecionado")
                        .foregroundColor(.secondary)
                        .task(id: coordenadaSelecionada?.latitude) {
                            guard let coordenada = coordenadaSelecionada else { return }
                            endereco = "Buscando endereço..."
                            await buscarEndereco(latitude: coordenada.latitude, longitude: coordenada.longitude)
                        }
                }
                
                Section("Conector principal") {
                    Picker("Tipo do conector", selection: $viewModel.conectorTipo) {
                        ForEach(TIPOS_DE_CARREGADORES, id: \.self) { tipo in
                                Text(tipo)
                        }
                    }
                    
                    if viewModel.conectorTipo == "Outros" {
                        TextField("Tipo do conector", text: $viewModel.conectorTipo)
                    }
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
    
    @MainActor
    private func buscarEndereco(latitude: Double, longitude: Double) async {
        let localizacao = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(localizacao)
            
            guard let placemark = placemarks.first else {
                self.endereco = "Endereço não encontrado"
                return
            }
            
            if let postalAddress = placemark.postalAddress {
                let formatter = CNPostalAddressFormatter()
                self.endereco = formatter.string(from: postalAddress).replacingOccurrences(of: "\n", with: ", ")
            } else {
                self.endereco = placemark.name ?? "Endereço não encontrado"
            }
            
        } catch {
            print("Erro de geocodificação: \(error.localizedDescription)")
            self.endereco = "Falha ao buscar endereço"
        }
    }
}

#Preview {
    AdicionarPontoView(onPontoCriado: {})
}
