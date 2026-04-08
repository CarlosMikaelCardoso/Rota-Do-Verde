import SwiftUI
import MapKit
import Combine
import Foundation

struct ContentView: View {
    @StateObject private var viewModel = PontosViewModel()
    @State private var selectedLocation: PontoRecarga?
    @State private var locationForNavigation: PontoRecarga?
    @StateObject private var locationManager = LocationManager()
    
    @State private var route: MKRoute?
    @State private var showToast: Bool = false
    @State private var distanciaRota: String = ""
    @State private var tempoRota: String = ""
    @State private var mostrandoTelaAdicionar = false
    @State private var mostrandoFiltros = false
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -1.4746, longitude: -48.4534),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // MARK: - Mapa
                Map(position: $position, selection: $selectedLocation) {
                    UserAnnotation()
                    
                    if let route {
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 5)
                    }
                    
                    ForEach(viewModel.pontos) { loc in
                        Marker(loc.nome, coordinate: loc.coordinate)
                            .tag(loc)
                    }
                }
                .mapStyle(.standard(emphasis: .muted))
                .ignoresSafeArea()
                
                // MARK: - Controles Superiores (Apenas o Botão de Filtro)
                                VStack {
                                    HStack {
                                        Spacer()
                                        
                                        // MARK: - Botão de Filtro (Canto superior direito, agora branco)
                                        Button {
                                            mostrandoFiltros = true
                                        } label: {
                                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                                .font(.system(size: 32)) // Aumentei um pouco para dar mais destaque
                                                .foregroundColor(.primary) // A cor do ícone
                                                .background(
                                                    Circle()
                                                        .fill(.white) // FUNDO AGORA É BRANCO PURO
                                                )
                                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4) // Sombra mais suave
                                        }
                                        .padding(.trailing, 20) // Espaçamento da borda direita
                                        .padding(.top, 12)     // Espaçamento do topo (SafeArea)
                                    }
                                }
                // MARK: - Toast da rota
                if showToast {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 20) {
                            HStack {
                                Image(systemName: "ruler")
                                Text(distanciaRota)
                            }
                            
                            HStack {
                                Image(systemName: "clock")
                                Text(tempoRota)
                            }
                        }
                        .font(.headline)
                        .padding()
                        .background(.ultraThinMaterial)
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.bottom, 60)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                                withAnimation {
                                    showToast = false
                                }
                            }
                        }
                    }
                    .zIndex(1)
                }
                
                // MARK: - Botões flutuantes
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            // Botão adicionar ponto
                            Button(action: {
                                mostrandoTelaAdicionar = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title.bold())
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                            
                            // Botão centralizar no usuário
                            Button(action: {
                                withAnimation(.snappy) {
                                    position = .userLocation(fallback: .automatic)
                                }
                            }) {
                                Image(systemName: "location.north.circle")
                                    .font(.title.bold())
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            
            // MARK: - Lógica de seleção do ponto
            // 1. No .onChange(of: selectedLocation), REMOVA ou COMENTE a parte do cálculo automático:
            .onChange(of: selectedLocation) { _, newLocation in
                guard let newLocation else {
                    route = nil
                    showToast = false
                    return
                }
                
                withAnimation(.snappy) {
                    position = .region(
                        MKCoordinateRegion(
                            center: newLocation.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
                        )
                    )
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    locationForNavigation = newLocation
                }
            }

            // 2. Atualize o .navigationDestination para lidar com o callback:
            .navigationDestination(item: $locationForNavigation) { local in
                PontoView(pontoId: local.id) {
                    // Ação quando o botão de rota é clicado na PontoView
                    locationForNavigation = nil // Fecha a PontoView voltando ao mapa
                    if let userCoord = locationManager.userLocation {
                        Task {
                            // Pequeno delay para a animação de volta ser suave antes de traçar a rota
                            try? await Task.sleep(nanoseconds: 500_000_000)
                            await calcularRota(origem: userCoord, destino: local.coordinate)
                        }
                    }
                }
            }
            .sheet(isPresented: $mostrandoTelaAdicionar) {
                AdicionarPontoView {
                    await viewModel.carregarPontos()
                }
            }
            .sheet(isPresented: $mostrandoFiltros) {
                            // Passamos o viewModel atual para que a view de filtros consiga acionar a busca
                            FiltrosView(viewModel: viewModel)
                                .presentationDetents([.medium, .large]) // Faz o Bottom Sheet não cobrir a tela toda se não precisar
                        }
            .task {
                await viewModel.carregarPontos()
            }
        }
    }
    
    private func calcularRota(origem: CLLocationCoordinate2D, destino: CLLocationCoordinate2D) async {
        let request = MKDirections.Request()
        
        let locationOrigem = CLLocation(latitude: origem.latitude, longitude: origem.longitude)
        let locationDestino = CLLocation(latitude: destino.latitude, longitude: destino.longitude)
        
        request.source = MKMapItem(location: locationOrigem, address: nil)
        request.destination = MKMapItem(location: locationDestino, address: nil)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        do {
            let response = try await directions.calculate()
            if let primeiraRota = response.routes.first {
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.route = primeiraRota
                    self.position = .rect(primeiraRota.polyline.boundingMapRect)
                    
                    let distanciaEmKm = primeiraRota.distance / 1000.0
                    self.distanciaRota = String(format: "%.1f km", distanciaEmKm)
                    
                    let tempoEmMinutos = Int(primeiraRota.expectedTravelTime / 60)
                    if tempoEmMinutos >= 60 {
                        let horas = tempoEmMinutos / 60
                        let minutos = tempoEmMinutos % 60
                        self.tempoRota = "\(horas)h \(minutos)min"
                    } else {
                        self.tempoRota = "\(tempoEmMinutos) min"
                    }
                    
                    self.showToast = true
                }
            }
        } catch {
            print("Erro ao calcular a rota: \(error.localizedDescription)")
        }
    }
    
    private func calcularRotaParaEnderecoTexto(origem: CLLocationCoordinate2D, endereco: String) async {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = endereco
        
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search.start()
            
            if let mapItem = response.mapItems.first {
                let destinoCoordinate = mapItem.location.coordinate
                await calcularRota(origem: origem, destino: destinoCoordinate)
            }
        } catch {
            print("Endereço fixo não encontrado ou erro na busca: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
