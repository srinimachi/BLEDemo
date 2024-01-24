//
//  ContentView.swift
//  BLEDemo
//
//  Created by Srinivasan <raman on 2024-01-24.
//

import SwiftUI
import CoreBluetooth
import WidgetKit

class BluetoothViewModel: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var isConnected = false

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private let targetDeviceUUID = UUID(uuidString:"049C4A37-3941-86AA-9008-EF95B8985AC2")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn{
            central.scanForPeripherals(withServices:nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if peripheral.identifier == targetDeviceUUID {
            self.peripheral = peripheral
            central.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        print("reload widget to update time of connect")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        print("reload widget to update time of disconnect")
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct ContentView: View {
    @ObservedObject private var bluetoothViewModel = BluetoothViewModel()

    var body: some View {
        VStack {
            Text(bluetoothViewModel.isConnected ? "Connected" : "Disconnected")
                .font(.title)
                .padding()
        
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
