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
import Anchorage

protocol ExpiredContactsDelegate{
    func handleExpiredContacts(contacts: [Contact])
}

class Recents: BaseTab{
    
    var recents = [RecentContact]()
    
    override func viewDidLoad() {
        fetchRecents()
        self.view.accessibilityViewIsModal = true
        collectionView.register(RecentsCell.self, forCellWithReuseIdentifier: "ActivesCellId")
        adjustTabBar()
        adjustNavBar()
        super.viewDidLoad()
    }
    
    fileprivate func adjustTabBar(){
        homeButton.setImage(UIImage(named: "UserpicDisabled"), for: .normal)
        recentsButton.setImage(UIImage(named: "Recents"), for: .normal)
    }
    
    fileprivate func adjustNavBar(){
        navTitle = "Recent Friends"
        navSubtitle = "friends that were recently in the area"
    }
    
    fileprivate func updateNavLabel(_ string: String) {
        navSubtitle = string
        setupNavLabel()
    }
    
    fileprivate func fetchRecents(){
        let records = PersistentContainer.retreiveRecents()
        recents.append(contentsOf: records)
        collectionView.reloadData()
    }
    
    func saveRecentsToDisk(){
        PersistentContainer.eraseRecentsHistory()
        recents.forEach{
            PersistentContainer.saveRecent(recent: $0)
        }
    }
    
}

extension Recents: UICollectionViewDelegateFlowLayout{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recents.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivesCellId", for: indexPath) as! RecentsCell
        cell.recent = recents[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 60, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 110, left: 0, bottom: 60, right: 0)
    }
}

extension Recents: ExpiredContactsDelegate{
    func handleExpiredContacts(contacts: [Contact]) {
        for contact in contacts{
            recents.removeAll{$0.name == contact.name}
            let name = contact.name
            let imageData = contact.imageData
            let lastSeen = getDate()
            var recent = RecentContact(name: name, imageData: imageData, lastSeen: lastSeen)
            recents.insert(recent, at: 0)
            self.collectionView.reloadData()
        }
        if recents.count > 100{
            recents.removeSubrange(100..<recents.count)
        }
       
        let string = "\(recents.count) friend(s) were recently in the area"
        updateNavLabel(string)
    }
    
    fileprivate func getDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = dateFormatter.string(from: Date())
        
        return date
    }
    
}
