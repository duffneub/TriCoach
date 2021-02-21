//
//  LegacyMap.swift
//  TriCoach
//
//  Created by Duff Neubauer on 2/20/21.
//

import MapKit
import SwiftUI

struct LegacyMap : UIViewRepresentable {
    let route: [CLLocationCoordinate2D]?

    func makeCoordinator() -> Coordinator {
        .init()
    }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)

        map.delegate = context.coordinator

        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.removeOverlays(map.overlays)

        guard let route = route else {
            return
        }

        let routeOverlay = MKPolyline(coordinates: route, count: route.count)

        map.addOverlay(routeOverlay)
        map.setVisibleMapRect(routeOverlay.boundingMapRect, edgePadding: .init(top: 20, left: 20, bottom: 20, right: 20), animated: false)
    }

    // MARK: - Coordinator

    class Coordinator : NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return .init(overlay: overlay)
            }

            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor(.accent)
            renderer.lineWidth = 4
            return renderer
        }
    }
}

// MARK: - Previews

struct LegacyMap_Previews : PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            LegacyMap(route: [.texasCapitol, .utTower, .dkrStadium, .sixthAndSoCo]).preferredColorScheme($0)
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 12 mini"))
    }
}

// MARK: - CLLocationCoordinate2D + Austin

extension CLLocationCoordinate2D {
    static let texasCapitol = Self(latitude: 30.2747, longitude: -97.7404)
    static let utTower = Self(latitude: 30.2862, longitude: -97.7394)
    static let dkrStadium = Self(latitude: 30.2837, longitude: -97.7326)
    static let sixthAndSoCo = Self(latitude: 30.268038, longitude: -97.742819)
}
