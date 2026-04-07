import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = PontosViewModel()
    @State private var selectedLocation: PontoRecarga?
    @State private var locationForNavigation: PontoRecarga?
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -1.4746, longitude: -48.4534),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                //MARK: - Mapa
                Map(position: $position, selection: $selectedLocation) {
                    ForEach(viewModel.pontos) { loc in
                        Marker(loc.nome, coordinate: loc.coordinate)
                            .tag(loc)
                    }
                }
                .mapStyle(.standard(emphasis: .muted))
                .ignoresSafeArea()
                
                //MARK: - Picker
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
                
//MARK: - Botão de adição de pontos
                HStack {
                    Button(action: {
                        print("Botão Adicionar pressionado")
                    }) {
                        Image(systemName: "plus")
                            .font(.title.bold())
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.top, 650)
                    .padding(.trailing, 220)
//MARK: - Botão de Centralização

                    Button(action: {
                        withAnimation(.snappy) {
                            position = .region(
                                MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: -1.4746, longitude: -48.4534),
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                            )
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
                    .padding(.top, 650)
                }
            }
            
//MARK: - Lógica de transição entre pickers
            .onChange(of: selectedLocation) { _, newLocation in
                guard let newLocation else { return }
                
                withAnimation(.snappy) {
                    position = .region(
                        MKCoordinateRegion(
                            center: newLocation.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                        )
                    )
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    locationForNavigation = newLocation
                }
            }
            .navigationDestination(item: $locationForNavigation) { local in
                PontoView(pontoId: local.id)
            }
            .task {
                await viewModel.carregarPontos()
            }
        }
    }
}

#Preview {
    ContentView()
}
