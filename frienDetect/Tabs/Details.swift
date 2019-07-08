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
import Anchorage

protocol SelectedCellDelegate{
    func didSelectCell()
}

protocol DiscoveredPhoneNumberDelegate{
    func isDiscoverableContact(phoneNumber: String) -> Bool
}

class Details: BaseTab{
    
    var contactsPage: ContactsList!
    var contactsDelegate: RequestContactsDelegate?
    
    enum alerts{
        case enabled
        case disabled
    }
    
    var alertsState = alerts.enabled
    let defaults = UserDefaults.standard
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    convenience init(contactsDelegate: RequestContactsDelegate){
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.contactsDelegate = contactsDelegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.view.accessibilityViewIsModal = true
        adjustTabBar()
        adjustNavBar()
        collectionView.register(DoNotDisturbCell.self, forCellWithReuseIdentifier: "AnonymityCellId")
        collectionView.register(FriendsListCell.self, forCellWithReuseIdentifier: "FriendsListCellId")

        fetchDoNotDisturbState()
        
        super.viewDidLoad()
    }
    
    fileprivate func adjustTabBar(){
        homeButton.setImage(UIImage(named: "UserpicDisabled"), for: .normal)
        detailsButton.setImage(UIImage(named: "Details"), for: .normal)
    }
    
    fileprivate func adjustNavBar(){
        navTitle = "Settings"
        navSubtitle = "adjust preferences"
        navLabel.accessibilityLabel = "Settings"
    }
    
    fileprivate func fetchDoNotDisturbState(){
        let isOn = defaults.bool(forKey: "DoNotDisturb")
        alertsState = (isOn) ? .disabled : .enabled
    }
}

extension Details: UICollectionViewDelegateFlowLayout{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnonymityCellId", for: indexPath) as! DoNotDisturbCell
            cell.delegate = self
            return cell
        }
        else if indexPath.item == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendsListCellId", for: indexPath) as! FriendsListCell
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 120, left: 0, bottom: 0, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0{
            let cell = collectionView.cellForItem(at: indexPath) as! SelectedCellDelegate
            cell.didSelectCell()
            provideHapticFeedback()
        }
        else if indexPath.item == 1{
            if contactsPage == nil{
                contactsPage = ContactsList(contactsDelegate: self)
            }
            self.view.window?.rootViewController?.present(contactsPage, animated: true, completion: nil)
        }
        
    }
}

extension Details: NoDisturbAlertDelegate{
    func handleNoDisturb(isOn: Bool) {
        if isOn{
            let alert = NoDisturbAlert()
            alert.modalPresentationStyle = .overFullScreen
            self.view.window?.rootViewController?.present(alert, animated: false, completion: nil)
        }
        switch isOn {
        case true:
            alertsState = .disabled
        case false:
            alertsState = .enabled
        }
        
        defaults.set(isOn, forKey: "DoNotDisturb")
    }
}

extension Details: RequestContactsDelegate{
    func provideContacts() -> [Contact] {
        return contactsDelegate?.provideContacts() ?? [Contact]()
    }
}

extension Details: DoNotDisturbDelegate{
    func isDoNotDisturbOn() -> Bool {
        return (alertsState == .enabled) ? false : true
    }
}

// Public method -- haptic feedback
func provideHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.prepare()
    generator.impactOccurred()
}



