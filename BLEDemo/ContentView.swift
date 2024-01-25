//
//  ContentView.swift
//  BLEDemo
//
//  Created by Srinivasan <raman on 2024-01-24.
//

import SwiftUI
import CoreBluetooth
import WidgetKit

class BluetoothViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isConnected = false

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private let targetDeviceUUID = UUID(uuidString:"049C4A37-3941-86AA-9008-EF95B8985AC2")
    let SOME_BLE_CHARACTERISTIC = CBUUID(string: "0000000b-c898-4ba4-9488-70d046f56724")

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
            self.peripheral?.delegate = self
            central.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral?.discoverServices(nil) //can provide array of specific services
        self.peripheral?.delegate = self
        isConnected = true
        print("reload widget to update time of connect")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        print("reload widget to update time of disconnect")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for charac in service.characteristics!{
            if charac.uuid == SOME_BLE_CHARACTERISTIC{
                peripheral.setNotifyValue(true, for: charac)
                peripheral.readValue(for: charac)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services{
            for service in services{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == SOME_BLE_CHARACTERISTIC
        {
            
            //HERE the widget is not reloading in background
            print("reload widget to update time of characterstic")
            WidgetCenter.shared.reloadAllTimelines()
        }
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
