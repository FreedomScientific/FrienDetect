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
import UserNotifications
import Anchorage

class Actives: BaseTab{
   
    var activeContacts = [Contact]()
    var timestamp = [Contact: Double]()
    var contactIdentifier = [UUID: Contact]()
    var timer: RepeatingTimer!
    
    var notificationTimeout = 60.0 * 10 // 10 minutes
    
    var doNotDisturbDelegate: DoNotDisturbDelegate!
    var expiredContactsDelegate: ExpiredContactsDelegate!
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    convenience init(doNotDisturbDelegate: DoNotDisturbDelegate, expiredContactsDelegate: ExpiredContactsDelegate){
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.doNotDisturbDelegate = doNotDisturbDelegate
        self.expiredContactsDelegate = expiredContactsDelegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityViewIsModal = true
        collectionView.register(ActivesCell.self, forCellWithReuseIdentifier: "ActivesCellId")
        setupNotificationCenter()
        setupTimer()
    }
    
    fileprivate func cleanUpTask(){
        let currentValue = getCurrentTimeSeconds()

        var cells = [Contact]()
        activeContacts.removeAll { (contact) -> Bool in
            let oldValue = timestamp[contact] ?? currentValue
            let difference = currentValue - oldValue
            if difference >= 6{
                cells.append(contact)
                return true
            }
            return false
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        let string = (activeContacts.count == 0) ?  "no friend is nearby" : "\(activeContacts.count) friend(s) are nearby"
        updateNavLabel(string)
        
        
        expiredContactsDelegate.handleExpiredContacts(contacts: cells)
    }
    
    fileprivate func setupTimer(){
        timer = RepeatingTimer(timeInterval: 1)
        timer.eventHandler = {
            self.cleanUpTask()
        }
        timer.resume()
    }
    
}

extension Actives: UICollectionViewDelegateFlowLayout{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activeContacts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivesCellId", for: indexPath) as! ActivesCell
        cell.contact = activeContacts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 60, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 110, left: 0, bottom: 60, right: 0)
    }
}


protocol ContactFoundDelegate{
    func handleContactFound(contact: Contact, uuid: UUID?)
    func handleRediscovery(uuid: UUID)
}

extension Actives: ContactFoundDelegate{
    
    func handleContactFound(contact: Contact, uuid: UUID?) {
        if !activeContacts.contains(contact) {
            activeContacts.insert(contact, at: 0)
            collectionView.reloadData()
            let string = "\(activeContacts.count) friend(s) are nearby"
            
            updateNavLabel(string)
            
        }
        
        if let uuid = uuid{
            contactIdentifier[uuid] = contact
            refreshContactTimestamp(contact)
        }
    }
    
    func handleRediscovery(uuid: UUID) {
        if let contact = contactIdentifier[uuid]{
            refreshContactTimestamp(contact)
        }
    }
    
    fileprivate func refreshContactTimestamp(_ contact: Contact) {
        // pull back any contacts that were moved into recents
        if(!activeContacts.contains(contact)){
            activeContacts.insert(contact, at: 0)
            collectionView.reloadData()
            let string = "\(activeContacts.count) friend(s) are nearby"
            
            updateNavLabel(string)
        }
        
        // notify if contact was away for 15min
        let currentValue = getCurrentTimeSeconds()
        if let oldValue = timestamp[contact] {
            let difference = currentValue - oldValue
            if difference >= notificationTimeout{
                launchAlerts(contact.name)
            }
        } else {
            launchAlerts(contact.name)
        }
        
        // refresh contact's timestamp
        timestamp[contact] = currentValue
    }
    
    fileprivate func updateNavLabel(_ string: String) {
        navSubtitle = string
        setupNavLabel()
    }
    
    fileprivate func getCurrentTimeSeconds() ->Double{
        let seconds = Date().timeIntervalSince1970
        return seconds
    }
}

protocol DoNotDisturbDelegate{
    func isDoNotDisturbOn() -> Bool
}

extension Actives{
    
    private func launchAlerts(_ name: String){
       
        if doNotDisturbDelegate.isDoNotDisturbOn(){
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(
            forKey: "Friend Detected",
            arguments: nil
        )
        content.body = NSString.localizedUserNotificationString(
            forKey: "\(name) is nearby",
            arguments: nil
        )
        
        content.categoryIdentifier = "FRIEND_DETECTED"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "TIMER_EXPIRED", content: content, trigger: trigger
        )
        let center = UNUserNotificationCenter.current()
        center.add(request) {
            (error : Error?) in
            if let Error = error {
                print("ERROR: alert not sent to Lock Screen: \(Error.localizedDescription)")
            }
        }
    }
    
    fileprivate func setupNotificationCenter(){
        let center = UNUserNotificationCenter.current()
        
        let detectionCategory = UNNotificationCategory(
            identifier: "FRIEND_DETECTED",
            actions: [], intentIdentifiers: [],
            options: UNNotificationCategoryOptions(rawValue: 0)
        )
        
        center.setNotificationCategories([detectionCategory])
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if !granted {
                // TODO: alert user that notifications will no longer work
            }
        }
        
    }
    
}
