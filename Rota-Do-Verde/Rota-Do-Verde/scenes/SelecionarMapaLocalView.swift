import SwiftUI
import MapKit

struct SelecionarLocalMapaView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -1.4746, longitude: -48.4534),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    
    @State private var coordenadaSelecionada: CLLocationCoordinate2D?
    
    let onSelecionar: (CLLocationCoordinate2D) -> Void
    
    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(position: $position) {
                    if let coordenadaSelecionada {
                        Marker("Novo ponto", coordinate: coordenadaSelecionada)
                    }
                }
                .onTapGesture { screenPoint in
                    if let coordinate = proxy.convert(screenPoint, from: .local) {
                        coordenadaSelecionada = coordinate
                    }
                }
            }
            .navigationTitle("Escolher local")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Confirmar") {
                        if let coordenadaSelecionada {
                            onSelecionar(coordenadaSelecionada)
                            dismiss()
                        }
                    }
                    .disabled(coordenadaSelecionada == nil)
                }
            }
        }
    }
}
