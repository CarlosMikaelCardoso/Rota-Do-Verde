//
//  LocationManager.swift
//  Rota-Do-Verde
//
//  Created by Turma02-2 on 07/04/26.
//


import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        // Dispara o alerta pedindo permissão ao usuário
        manager.requestWhenInUseAuthorization()
    }
}
