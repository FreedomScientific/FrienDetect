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

import UIKit
import Contacts
import UserNotifications
import CoreData

import Firebase

class MainController: UIViewController{
    
    var activesTab: Actives!
    var recentsTab: Recents!
    var detailsTab: Details!
    
    var activesTabView: UIView!
    var recentsTabView: UIView!
    var detailsTabView: UIView!
    
    var phoneVerificationPage: PhoneVerificationPage!
    var codeVerificationPage: CodeVerificationPage!
    
    var contacts = [Contact]()
    
    var bluetoothManager: BluetoothManager!
    var contactFoundDelegate: ContactFoundDelegate!
    
    var userPhoneNumber: Data!
    
    enum tabState{
        case actives
        case recents
        case settings
    }
    
    var currentTab: tabState!
    
    let defaults = UserDefaults.standard
    
    struct Keys{
        static let userPhoneNumber = "userPhoneNumber"
    }
    
    override func viewDidLoad() {
        modalPresentationStyle = .currentContext
        fetchContacts()
        retreiveUserPhoneNumber()
        subscribeToContactsChange()
    }
    
    fileprivate func retreiveUserPhoneNumber(){
        setupViews()
        
        if let userPhoneNumber = defaults.data(forKey: Keys.userPhoneNumber){
            bluetoothManager = BluetoothManager(userPhoneNumber: userPhoneNumber, delegate: self)
        }
        else{
            FirebaseApp.configure()
            phoneVerificationPage = PhoneVerificationPage(delegate: self)
            present(phoneVerificationPage, animated: true, completion: nil)
        }
    }
    
    
    fileprivate func setupViews(){
        navigationController?.isNavigationBarHidden = true
        
        recentsTab = Recents(collectionViewLayout: UICollectionViewFlowLayout())
        detailsTab = Details(contactsDelegate: self)
        activesTab = Actives(doNotDisturbDelegate: self, expiredContactsDelegate: recentsTab)
        
        guard let detailsTab = detailsTab, let activesTab = activesTab, let recentsTab = recentsTab else {return}
        
        [activesTab, recentsTab, detailsTab].forEach { (tab) in
            view.addSubview(tab.view)
            tab.delegate = self
        }
        
        contactFoundDelegate = activesTab
        
        activesTabView = activesTab.view
        recentsTabView = recentsTab.view
        detailsTabView = detailsTab.view
        
        handleActivesTap()
    }
    
    fileprivate func subscribeToContactsChange(){
        NotificationCenter.default.addObserver(self, selector: #selector(contactsDidChange), name: NSNotification.Name.CNContactStoreDidChange, object: nil)
    }
    
    @objc fileprivate func contactsDidChange(){
        fetchContacts()
    }
    
  
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
}

extension MainController: TabBarDelegate{
    
    func handleActivesTap() {
        view.bringSubviewToFront(activesTabView)
        activesTab.updateAccessibilityLabelForActiveTab(tab: "active")
    }
    
    func handleRecentsTap() {
        view.bringSubviewToFront(recentsTabView)
        recentsTab.updateAccessibilityLabelForActiveTab(tab: "recents")
    }
    
    func handleSettingsTap() {
        view.bringSubviewToFront(detailsTabView)
        detailsTab.updateAccessibilityLabelForActiveTab(tab: "details")
    }
    
}


extension MainController: RequestContactsDelegate{
    
    func provideContacts() -> [Contact] {
        return contacts
    }
    
    fileprivate func fetchContacts(){
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error{
                print("ERROR fetching contacts: \(error)")
                return
            }
            
            if !granted{
                print("ERROR: Access to contacts denied")
                return
            }
            else{
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataAvailableKey, CNContactImageDataKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do{
                    try store.enumerateContacts(with: request) { (appleContact, stopPointer) in
                        // grab valid numbers off the Apple Contact
                        var numbers = [String]()
                        for appleNumber in appleContact.phoneNumbers {
                            let potentialNumber = ContactCell.sanitizeNumber(appleNumber.value.stringValue)
                            
                            if let number = potentialNumber {
                                numbers.append(number)
                            }
                        }
                        
                        if(numbers.count < 1){
                            return
                        }
                        
                        // grab name off the Apple Contact
                        let name = "\(appleContact.givenName) \(appleContact.familyName)"
                        
                        
                        // check for existing contact
                        let query = PersistentContainer.queryForContactWith(appleContactID: appleContact.identifier)
                        if var oldContact = query {
                            // update the contacts information
                            oldContact.imageData = appleContact.imageData
                            oldContact.name = name
                            oldContact.numbers = numbers
                            PersistentContainer.updateContactData(contact: oldContact)
                            self.contacts.append(oldContact)
                        } else {
                            // save the new contact
                            let contact = Contact(name: name, numbers: numbers,
                                                  imageData: appleContact.imageData,
                                                  isBlocked: false,
                                                  appleContactID: appleContact.identifier)
                            PersistentContainer.saveNewContact(contact: contact)
                            self.contacts.append(contact)
                        }
                    }
                    
                } catch let error{
                    print("Failed to enumerate contacts: \(error)")
                }
                
            }
            
            // clean-up old contacts on disk
            let appleIDs = self.contacts.map(){ contact -> String in
                return contact.appleContactID
            }
           
            PersistentContainer.cleanUp(goodAppleIDs: appleIDs)
        }
    }
}

extension MainController: BluetoothManagerDelegate{
    
    func handleContactFound(phoneNumber: String, uuid: UUID?) {
        print("Contact found!: \(phoneNumber)")
        let contacts = PersistentContainer.getContactsWith(number: phoneNumber)
        for contact in contacts {
            if !contact.isBlocked{
                contactFoundDelegate.handleContactFound(contact: contact, uuid: uuid)
            }
        }
    }
    
    func isDiscoverableContact(phoneNumber: String) -> Bool {
        print("checkingContact")
        // check friend-list for contacts containing the phoneNumber
        let contacts = PersistentContainer.getContactsWith(number: phoneNumber)
        if(contacts.count < 1){
            return false
        }
        
        // check for an unblocked contact
        if contacts.contains(where: {$0.isBlocked == false }) {
            return true
        }
        else {
            return false
        }
    }
    
    func handleRediscovery(uuid: UUID) {
        contactFoundDelegate.handleRediscovery(uuid: uuid)
    }
    
    func handleBluetoothOff(){
        let alert = UIAlertController(title: "Bluetooth Off", message: "Bluetooth must be turned on for the app to work", preferredStyle: .alert)
       
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            guard let url = URL(string: "App-Prefs:root=BLUETOOTH") else {return}
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        alert.addAction(settingsAction)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
  
        self.present(alert, animated: true)
    }
}


extension MainController: PhoneVerificationPageDelegate{
    func handlePhoneNumberSubmitted(phoneNumber: String) {
        userPhoneNumber = phoneNumber.data(using: .utf8)
        
        // bypass the authentication
        if(phoneNumber == "0001756493" || phoneNumber == "0006974813"){
            handleSignupFinished()
            return
        }
      
        if codeVerificationPage == nil{
            codeVerificationPage = CodeVerificationPage(delegate: self, number: phoneNumber)
        }
    
        present(codeVerificationPage, animated: true){
            // Send Verification Code
            PhoneAuthProvider.provider().verifyPhoneNumber("+1 " + phoneNumber, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    print("ERROR submitting number: \(error.localizedDescription)")
                    // TODO: print the error to the user
                    return
                }
                
                /*  Save verification code to UserDefaults in case the user takes long time outside the app
                 */
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                UserDefaults.standard.set(phoneNumber, forKey: "unverifiedNumber")
                
            }
        }
    }
}

extension MainController: DoNotDisturbDelegate{
    func isDoNotDisturbOn() -> Bool {
        let delegate = detailsTab as DoNotDisturbDelegate
        return delegate.isDoNotDisturbOn()
    }
}

protocol SignupFinishedDelegate{
    func handleSignupFinished()
}

extension MainController: SignupFinishedDelegate{
    func handleSignupFinished() {
        defaults.setValue(userPhoneNumber, forKey: Keys.userPhoneNumber)
        bluetoothManager = BluetoothManager(userPhoneNumber: userPhoneNumber, delegate: self)
    }
}

extension MainController: CodeVerificationPageDelegate{
    func handleTapOnBackArrow() {
        present(phoneVerificationPage, animated: true, completion: nil)
    }
    
    func handleCodeWasSuccessful() {
        handleSignupFinished()
    }
    
    func testCode(_ code: String, completion: @escaping (_ isGoodCode: Bool) -> Void) {
        let verifyCompletionEnclosure = completion
        // Retrieving verification code from UserDefaults
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            return
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID,
                                                                 verificationCode: code)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // TODO print error to the user
                print("ERROR during number verification: \(error.localizedDescription)")
                verifyCompletionEnclosure(false)
            }
            else {
                verifyCompletionEnclosure(true)
            }
            
        }
    }
    
}

extension MainController{
    func appEnteredBackGround(){
        recentsTab.saveRecentsToDisk()
    }
}
