import SwiftUI
import MapKit
import Combine
import Foundation

struct ContentView: View {
    @State private var animatedCoordinates: [CLLocationCoordinate2D] = []
    @State private var mostrandoConfiguracoes = false
    @State private var mostrandoTelaVeiculos = false
    
    @AppStorage("temaApp") private var temaAtual: TemaApp = .sistema
    @Environment(\.colorScheme) var colorScheme
    
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
                    
                    if !animatedCoordinates.isEmpty {
                        MapPolyline(coordinates: animatedCoordinates)
                            .stroke(
                                LinearGradient(
                                    colors: [.verdePrincipal, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(
                                    lineWidth: 6,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                    }
                    
                    ForEach(viewModel.pontos) { loc in
                        Annotation(loc.nome, coordinate: loc.coordinate) {
                            Button {
                                selectedLocation = loc
                            } label: {
                                Image(systemName: "bolt.circle.fill")
                                    .font(.title)
                                    .foregroundColor(corDoPonto(loc))
                                    .padding(8)
                                    .background(Color(.systemBackground))
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                        .tag(loc)
                    }
                }
                .mapStyle(.standard(emphasis: .muted))
                .ignoresSafeArea()
                
                // MARK: - Controles superiores
                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Button {
                                mostrandoConfiguracoes = true
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(.primary)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(Color(.systemBackground))
                                    )
                                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                            }
                            
                            Button {
                                mostrandoFiltros = true
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.primary)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(Color(.systemBackground))
                                    )
                                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 12)
                    }
                    
                    // MARK: - Veículo selecionado centralizado
                    if let veiculo = viewModel.veiculoSelecionado, viewModel.filtroCompatibilidadeAtivo {
                        HStack(spacing: 10) {
                            Image(systemName: "car.fill")
                            
                            Text("\(veiculo.marca) \(veiculo.modelo)")
                                .font(.subheadline.weight(.semibold))
                            
                            Button {
                                Task {
                                    await viewModel.limparCompatibilidade()
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
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
                            Button(action: {
                                mostrandoTelaAdicionar = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title.bold())
                                    .padding()
                                    .background(Color.verdePrincipal)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                            
                            Button(action: {
                                mostrandoTelaVeiculos = true
                            }) {
                                Image(systemName: "car.fill")
                                    .font(.title.bold())
                                    .padding()
                                    .background(viewModel.filtroCompatibilidadeAtivo ? Color.purple : Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                            
                            Button(action: {
                                withAnimation(.snappy) {
                                    position = .userLocation(fallback: .automatic)
                                }
                            }) {
                                Image(systemName: "location.north.circle")
                                    .font(.title.bold())
                                    .padding()
                                    .background(Color.verdePrincipal)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .onChange(of: selectedLocation) { _, newLocation in
                guard let newLocation else {
                    route = nil
                    showToast = false
                    animatedCoordinates = []
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
                    locationForNavigation = nil
                    if let userCoord = locationManager.userLocation {
                        Task {
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
                FiltrosView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $mostrandoConfiguracoes) {
                ConfiguracoesView()
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $mostrandoTelaVeiculos) {
                VeiculosView { veiculo in
                    Task {
                        await viewModel.carregarCompatibilidade(veiculo: veiculo)
                    }
                }
                .presentationDetents([.medium, .large])
            }
            .task {
                await viewModel.carregarPontos()
            }
        }
        .preferredColorScheme(temaAtual.colorScheme)
    }
    
    private func corDoPonto(_ ponto: PontoRecarga) -> Color {
        if ponto.status.lowercased() == "manutencao" {
            return .orange
        }
        if ponto.ocupado == true {
            return .red
        }
        return .green
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
                withAnimation(.snappy(duration: 0.8)) {
                    self.position = .rect(primeiraRota.polyline.boundingMapRect.insetBy(dx: -1200, dy: -1200))
                }
                
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
                
                let allCoords = primeiraRota.polyline.coordinates
                self.animatedCoordinates = []
                
                Task {
                    let duracaoDesejada: TimeInterval = 6.0
                    let taxaDeFrames = 0.06
                    let totalPassos = Int(duracaoDesejada / taxaDeFrames)
                    let pontosPorPasso = max(2, allCoords.count / totalPassos)
                    
                    for step in 0..<totalPassos {
                        let limiteIndex = min((step + 1) * pontosPorPasso, allCoords.count)
                        self.animatedCoordinates = Array(allCoords[0..<limiteIndex])
                        try? await Task.sleep(nanoseconds: UInt64(taxaDeFrames * 1_000_000_000))
                        if limiteIndex >= allCoords.count { break }
                    }
                    
                    self.animatedCoordinates = allCoords
                    
                    withAnimation {
                        self.showToast = true
                    }
                }
            }
        } catch {
            print("Erro ao calcular a rota: \(error.localizedDescription)")
        }
    }
}

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](
            repeating: kCLLocationCoordinate2DInvalid,
            count: pointCount
        )
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

#Preview {
    ContentView()
}
