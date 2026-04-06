import SwiftUI
import MapKit

struct ContentView: View {
    @State private var viewModel = PontosViewModel()
    @State private var selectedLocation: PontoRecarga?
    @State private var locationForNavigation: PontoRecarga?
    
    // Posição inicial da câmera
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -1.4746, longitude: -48.4534),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    var body: some View {
            NavigationStack {
                ZStack(alignment: .top) {
                    Map(position: $position, selection: $selectedLocation) {
                        ForEach(viewModel.pontos) { loc in
                            Marker(loc.nome, coordinate: loc.coordenada)
                                .tag(loc) // Necessário para a seleção do mapa funcionar
                        }
                    }
                    .mapStyle(.standard(emphasis: .muted))
                    .ignoresSafeArea()
                    
                    // Picker flutuando sobre o mapa
                    Picker("Selecione um local", selection: $selectedLocation) {
                        Text("📍 Explorar Hallownest").tag(nil as PontoRecarga?)
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
                    .padding(.top, -40)
                }
                .onChange(of: selectedLocation) { _, newLocation in
                    if let newLocation = newLocation {
                        // Executa a animação da câmera do mapa
                        withAnimation(.snappy) {
                            position = .region(
                                MKCoordinateRegion(
                                    center: newLocation.coordenada,
                                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                )
                            )
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            locationForNavigation = newLocation
                        }
                    }
                }
                .navigationDestination(item: $locationForNavigation) { local in
                    pontoView(local: local)
                }
            }
            .task { await viewModel.carregarPontos() }
        }}

#Preview {
    ContentView()
}

