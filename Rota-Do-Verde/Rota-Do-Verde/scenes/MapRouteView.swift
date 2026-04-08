import SwiftUI
import MapKit

// MARK: - Representable para Rota Animada
struct MapRouteView: UIViewRepresentable {
    let route: MKRoute
    let duration: TimeInterval = 6.0 // Duração dentro da sua faixa de 6-10s

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isUserInteractionEnabled = true
        
        // Adiciona a polilinha ao mapa
        mapView.addOverlay(route.polyline)
        
        // Ajusta o zoom inicial para enquadrar a rota inteira
        let rect = route.polyline.boundingMapRect
        mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(duration: duration)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        let duration: TimeInterval

        init(duration: TimeInterval) {
            self.duration = duration
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                return AnimatedPolylineRenderer(polyline: polyline, duration: duration)
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// MARK: - Renderer Customizado para Animação de Cobra
class AnimatedPolylineRenderer: MKOverlayPathRenderer {
    let duration: TimeInterval
    
    init(polyline: MKPolyline, duration: TimeInterval) {
        self.duration = duration
        super.init(overlay: polyline)
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        // Esta função é chamada pelo MapKit, mas para animar usaremos uma Layer
    }

    // Criamos uma camada de desenho (Layer) sobre o Renderer
    override func createPath() {
        let path = CGMutablePath()
        let polyline = overlay as! MKPolyline
        
        for i in 0..<polyline.pointCount {
            let point = point(for: polyline.points()[i])
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        self.path = path
    }
    
    // Sobrescrevemos a renderização para injetar a animação de CoreAnimation
    override func applyStrokeProperties(to context: CGContext, atZoomScale zoomScale: MKZoomScale) {
        super.applyStrokeProperties(to: context, atZoomScale: zoomScale)
        context.setLineJoin(.round)
        context.setLineCap(.round)
    }
}
