/******************************************************************************
Copyright (c) 2019 Freedom Scientific 
Licensed under the New BSD license

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors 
may be used to endorse or promote products derived from this software without 
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
sTHIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
******************************************************************************/




import UserNotifications
import UIKit
import CoreBluetooth


protocol BluetoothManagerDelegate {
    func isDiscoverableContact(phoneNumber: String) -> Bool
    func handleContactFound(phoneNumber: String, uuid: UUID?)
    func handleRediscovery(uuid: UUID)
    func handleBluetoothOff()
}

struct ConnectedPeripheral{
    var peripheral: CBPeripheral?
    var phoneCharacteristic: CBCharacteristic?
    var confirmationCharacteristic: CBCharacteristic?
    var responseCharacteristic: CBCharacteristic?
    
    var centralPhoneFound = false
    var centralPhoneNumber = ""
    
    init(peripheral: CBPeripheral){
        self.peripheral = peripheral
    }
}

struct ConnectedCentral{
    var confirmation: Bool?
    var phoneNumber: String?
}

struct FDDevice{
    var peripheral: CBPeripheral!
    var numberOfAttempts = 0
}

class BluetoothManager: NSObject {
    
    var delegate: BluetoothManagerDelegate!
    
    // User's phone number
    var advertisedPhone: Data?
    
    var centralPhone: Data?
    
    // Positive confirmation
    var positiveConfirmation: Data? = "yes".data(using: .utf8)
    
    // Negative confirmation
    var negativeConfirmation: Data? = "no".data(using: .utf8)
    
    // Current peripheral
    var connectedPeripheral: ConnectedPeripheral?
    
    // queue
    var queue = [FDDevice]()
    
    // Current central
    var connectedCentral: ConnectedCentral?
    
    // Recently Discovered
    var discoveredDevices = [CBPeripheral: Bool]()
    var handshakeWasSuccessfulFor = [CBPeripheral: Bool]()
    
    let UserPhoneCharacteristicUUID = CBUUID.init(string: "32D28D64-3B88-41B4-8138-4C183D93EF79")
    let ConfirmationCharacteristicUUID = CBUUID.init(string: "B746B607-447C-40B0-B066-3697431920C3")
    let PeripheralResponseCharacteristicUUID = CBUUID.init(string: "55F4A4A0-F837-45D2-92B9-C6C2FB5000E0")
    
    let serviceUUID = CBUUID(string: "B42D832B-49BD-421E-9A93-19326801E6A7")
    let advertisementServiceUUID = CBUUID(string: "FD25")
    
    var service: CBMutableService!
    var phoneCharacteristic: CBMutableCharacteristic!
    var confirmationCharacteristic: CBMutableCharacteristic!
    var peripheralResponseCharacteristic: CBMutableCharacteristic!
    
    var peripheralManager: CBPeripheralManager!
    var centralManager: CBCentralManager!
    
    init(userPhoneNumber: Data, delegate: BluetoothManagerDelegate){
        super.init()
        advertisedPhone = userPhoneNumber
        self.delegate = delegate
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    fileprivate func processPhoneNumber(number: String){
        
        guard let peripheral = connectedPeripheral?.peripheral else {return}
        guard let confirmationCharacteristic = connectedPeripheral?.confirmationCharacteristic else {return}
        guard let userPhoneNumber = advertisedPhone else {return}
        guard let negativeConfirmation = negativeConfirmation else {return}
        
        /*   Central searches peripheral's phone number in its directory
         */
        
        guard let delegate = delegate else {return}
        print("Attempting to write")
        if delegate.isDiscoverableContact(phoneNumber: number){
            connectedCentral = ConnectedCentral(confirmation: true, phoneNumber: number)
            peripheral.writeValue(userPhoneNumber, for: confirmationCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
        else{
            connectedCentral = ConnectedCentral(confirmation: false, phoneNumber: nil)
            peripheral.writeValue(negativeConfirmation, for: confirmationCharacteristic, type: CBCharacteristicWriteType.withResponse)
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    var queueIsBeenProcessed = false
    
    fileprivate func processQueue(){
        print("Processing queue")
        if var device = queue.first{
            queue.removeFirst()
            if handshakeWasSuccessfulFor[device.peripheral] ?? false{
                print("elements in queue: \(queue.count)")
                if !queue.isEmpty{
                    processQueue()
                }
                else{
                    queueIsBeenProcessed = false
                }
            }
            else{
                if device.numberOfAttempts < 3{
                    print("Attempt \(device.numberOfAttempts)")
                    device.numberOfAttempts += 1
                    queue.append(device)
                    connectedPeripheral = ConnectedPeripheral(peripheral: device.peripheral)
                    centralManager.connect(device.peripheral, options: nil)
 
                }
                else{
                    if !queue.isEmpty{
                        processQueue()
                    }
                }
            }
        }
    }
    
} // end CustomBluetoothClass


/*  Peripheral Role
 */
extension BluetoothManager: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        // if bluetooth is on
        if peripheral.state == .poweredOn {
            // instantiate service
            service = CBMutableService(type: serviceUUID, primary: true)
            
            phoneCharacteristic = CBMutableCharacteristic(type: UserPhoneCharacteristicUUID, properties: [.read], value: nil, permissions: .readable)
            
            confirmationCharacteristic = CBMutableCharacteristic(type: ConfirmationCharacteristicUUID, properties: [.write], value: nil, permissions: .writeable)
            
            peripheralResponseCharacteristic = CBMutableCharacteristic(type: PeripheralResponseCharacteristicUUID, properties: [.read], value: nil, permissions: .readable)
            
            // Add characteristics to service
            service.characteristics = [phoneCharacteristic!, confirmationCharacteristic!, peripheralResponseCharacteristic!]
            // Add service to Peripheral Manager
            peripheralManager?.add(service!)
            peripheralManager?.delegate = self
            let adData = [CBAdvertisementDataLocalNameKey:"This Is FrienDetect Service", CBAdvertisementDataServiceUUIDsKey:[advertisementServiceUUID]] as [String:Any]
            peripheralManager?.startAdvertising(adData)
            
        }
    }
    
    // Read request from central
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("Read request received")
        if request.characteristic.uuid == phoneCharacteristic.uuid{
            phoneCharacteristic.value = advertisedPhone
            
            guard let length = phoneCharacteristic.value?.count else {return}
            
            if request.offset > length{
                peripheralManager.respond(to: request, withResult: CBATTError.Code.invalidOffset)
                print("ERROR: Invalid read request - invalid offset")
                return
            }
            
            let range = request.offset..<length - request.offset
            request.value = phoneCharacteristic.value?.subdata(in: range)
            
            peripheralManager.respond(to: request, withResult: CBATTError.Code.success)
            
        }
        else if request.characteristic.uuid == peripheralResponseCharacteristic.uuid{
            
            if connectedPeripheral?.centralPhoneFound == true{
                peripheralResponseCharacteristic.value = positiveConfirmation
                /*  Alert user
                 */
                print("handshake I'm a peripheral - Central_Id: \(request.central.identifier)")
                guard let phoneNumber = connectedPeripheral?.centralPhoneNumber else {return}
                delegate.handleContactFound(phoneNumber: phoneNumber, uuid: request.central.identifier)
            }
            else{
                peripheralResponseCharacteristic.value = negativeConfirmation
            }
            
            guard let length = peripheralResponseCharacteristic.value?.count else {return}
            
            if request.offset > length{
                peripheralManager.respond(to: request, withResult: CBATTError.Code.invalidOffset)
                print("ERROR: Invalid read request - invalid offset")
                return
            }
            
            let range = request.offset..<length - request.offset
            request.value = peripheralResponseCharacteristic.value?.subdata(in: range)
            
            peripheralManager.respond(to: request, withResult: CBATTError.Code.success)
        }
    }
    
    // Write request from Central
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("Write request received")
        let request = requests[0]
        if request.characteristic.uuid == confirmationCharacteristic.uuid{
            
            confirmationCharacteristic.value = request.value
            
            guard let value = request.value else{
                print("ERROR reading request value")
                return
            }
            
            guard let centralPhone = String(data: value, encoding: .utf8) else {return}
            print("centralPhone: \(centralPhone)")
            if centralPhone == "no"{
                /*  Central should cancel connection
                 No user notification
                 */
            }
            else{
                /*  peripheral searches central's phone in its directory
                 */
                if delegate.isDiscoverableContact(phoneNumber: centralPhone){
                    /*  peripheral found central's phone
                     */
                    connectedPeripheral?.centralPhoneFound = true
                    connectedPeripheral?.centralPhoneNumber = centralPhone
                }
                else{
                    connectedPeripheral?.centralPhoneFound = false
                }
            }
            peripheralManager.respond(to: request, withResult: CBATTError.Code.success)
        }
    }
}

/*  Central role
 */
extension BluetoothManager: CBCentralManagerDelegate, CBPeripheralDelegate{
    
    // Scan for Peripherals
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "FD25")], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        else{
            delegate.handleBluetoothOff()
        }
    }
    
    // Did Discover Peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let alreadyDiscovered = discoveredDevices[peripheral]{
            delegate.handleRediscovery(uuid: peripheral.identifier)
            return
        }
        else{
            print("enqueing")
            discoveredDevices[peripheral] = true
            queue.append(FDDevice(peripheral: peripheral, numberOfAttempts: 0))
            if !queueIsBeenProcessed{
                queueIsBeenProcessed = true
                processQueue()
            }
        }
    }
    
    // Did Connect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    // Did Discover Services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let services = peripheral.services{
            for svc in services{
                if svc.uuid == serviceUUID{
                    peripheral.discoverCharacteristics([UserPhoneCharacteristicUUID, ConfirmationCharacteristicUUID, PeripheralResponseCharacteristicUUID], for: svc)
                }
            }
        }
    }
    
    // Did Discover Characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let error = error{
            print("ERROR discovering characteristic: \(error.localizedDescription)")
            return
        }
        
        if let characteristics = service.characteristics{
            for char in characteristics{
                if char.uuid == ConfirmationCharacteristicUUID{
                    connectedPeripheral?.confirmationCharacteristic = char
                }
                else if char.uuid == PeripheralResponseCharacteristicUUID{
                    connectedPeripheral?.responseCharacteristic = char
                }
                else if char.uuid == UserPhoneCharacteristicUUID{
                    
                    connectedPeripheral?.phoneCharacteristic = char
                }
            }
            guard let char = connectedPeripheral?.phoneCharacteristic else {return}
            print("Attempting to read Phone Number")
            peripheral.readValue(for: char)
        }
        
    }
    
    // Peripheral Updated Value Of Characteristic
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error{
            print("ERROR reading value from peripheral: \(error.localizedDescription)")
            return
        }
        
        if characteristic.uuid == UserPhoneCharacteristicUUID{
            if let data = characteristic.value{
                guard let phoneNumber = String(data: data, encoding: .utf8) else {
                    print("Failed to read peripheral phone number")
                    return
                }
                print("Phone number: \(phoneNumber)")
                processPhoneNumber(number: phoneNumber)
            }
            
        }
        else if characteristic.uuid == PeripheralResponseCharacteristicUUID{
            if let data = characteristic.value{
                guard let response = String(data: data, encoding: .utf8) else {
                    print("Failed to read peripheral response")
                    return
                }
                if response == "yes"{
                    /*  Alert user
                     */
                    guard let phoneNumber = connectedCentral?.phoneNumber else {return}
                    delegate.handleContactFound(phoneNumber: phoneNumber, uuid: peripheral.identifier)
                }
                
                print("handshake I'm a central - Peripheral_Id: \(peripheral.identifier)")
                
                handshakeWasSuccessfulFor[peripheral] = true
                queueIsBeenProcessed = false
                if !queue.isEmpty{
                    queueIsBeenProcessed = true
                    processQueue()
                }
                
                /*  Disconnect
                 */
                centralManager.cancelPeripheralConnection(peripheral)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error{
            print("Error writing to characteristic: \(error.localizedDescription)")
            return
        }
        
        if connectedCentral?.confirmation == false{
            /*  Central didn't find peripheral's phone in its directory
             cancel connection
             */
            centralManager.cancelPeripheralConnection(peripheral)
        }
        else{
            /*  Central found peripheral's phone
             request peripheral's confirmation
             */
            guard let char = connectedPeripheral?.responseCharacteristic else {return}
            print("Attempting to read peripheral's response")
            peripheral.readValue(for: char)
        }
    }
    
    // Error On Subscribing to Characteristic
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error{
            print("ERROR subscribing: \(error)")
        }
    }
    
    // Did Disconnect From Peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Peripheral disconnected: \(peripheral)")
        
        if let handshakeSuccessful = handshakeWasSuccessfulFor[peripheral]{
            if !handshakeSuccessful{
                print("Reconnecting to: \(peripheral)")
                queueIsBeenProcessed = true
                processQueue()
            }
        }
        else{
            print("Reconnecting to: \(peripheral)")
            queueIsBeenProcessed = true
            processQueue()
        }
        
    }
    
}

class RepeatingTimer {
    
    let timeInterval: TimeInterval
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: DispatchQueue.main)
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    
    var eventHandler: (() -> Void)?
    
    private enum State {
        case suspended
        case resumed
    }
    
    private var state: State = .suspended
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }
    
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}

