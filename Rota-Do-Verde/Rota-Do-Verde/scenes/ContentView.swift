import SwiftUI
import MapKit
import Combine
import Foundation

struct ContentView: View {
    @State private var animatedCoordinates: [CLLocationCoordinate2D] = []
    
    @StateObject private var viewModel = PontosViewModel()
    @State private var selectedLocation: PontoRecarga?
    @State private var locationForNavigation: PontoRecarga?
    @StateObject private var locationManager = LocationManager()
    
    @State private var route: MKRoute?
    @State private var showToast: Bool = false
    @State private var distanciaRota: String = ""
    @State private var tempoRota: String = ""
    @State private var mostrandoTelaAdicionar = false
    
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
                    
                    // Substitua a lógica de MapPolyline(route) por esta:
                    if !animatedCoordinates.isEmpty {
                        MapPolyline(coordinates: animatedCoordinates)
                            .stroke(
                                LinearGradient(colors: [.green, .cyan], startPoint: .leading, endPoint: .trailing),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                            )
                    }
                    
                    ForEach(viewModel.pontos) { loc in
                        Marker(loc.nome, coordinate: loc.coordinate)
                            .tag(loc)
                    }
                }
                .mapStyle(.standard(emphasis: .muted))
                .ignoresSafeArea()
                
                // MARK: - Picker
                Picker("Selecione um local", selection: $selectedLocation) {
                    Text("Explorar pontos").tag(nil as PontoRecarga?)
                    ForEach(viewModel.pontos) { loc in
                        Text(loc.nome).tag(loc as PontoRecarga?)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .overlay {
                    Capsule()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                }
                .padding(.top, -50)
                
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
            .task {
                await viewModel.carregarPontos()
            }
        }
    }
    
// MARK: - Calcular Rota
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
                // 1. Ajusta a câmera imediatamente
                withAnimation(.snappy(duration: 0.8)) {
                    self.position = .rect(primeiraRota.polyline.boundingMapRect.insetBy(dx: -1200, dy: -1200))
                }
                
                // Textos do Toast
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
                
                // 2. Extrai os pontos e faz a animação da cobra
                let allCoords = primeiraRota.polyline.coordinates
                self.animatedCoordinates = [] // Reseta a linha anterior
                
                Task {
                    let duracaoDesejada: TimeInterval = 6.0
                    let taxaDeFrames = 0.06 // ~30 atualizações por segundo
                    let totalPassos = Int(duracaoDesejada / taxaDeFrames)
                    let pontosPorPasso = max(2, allCoords.count / totalPassos)
                    
                    for step in 0..<totalPassos {
                        let limiteIndex = min((step + 1) * pontosPorPasso, allCoords.count)
                        
                        // Atualiza a interface com a nova fatia da rota
                        self.animatedCoordinates = Array(allCoords[0..<limiteIndex])
                        
                        // Pausa para o próximo frame
                        try? await Task.sleep(nanoseconds: UInt64(taxaDeFrames * 1_000_000_000))
                        
                        // Se já desenhou tudo, para o loop
                        if limiteIndex >= allCoords.count { break }
                    }
                    
                    // Garante que 100% da rota seja renderizada no final
                    self.animatedCoordinates = allCoords
                    
                    // Mostra o Toast só quando a cobra chegar no destino
                    withAnimation {
                        self.showToast = true
                    }
                }
            }
        } catch {
            print("Erro ao calcular a rota: \(error.localizedDescription)")
        }
    }
    
// MARK: - Calcular Rota pelo Endereço
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

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

#Preview {
    ContentView()
}
