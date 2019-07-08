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

protocol RequestContactsDelegate{
    func provideContacts() -> [Contact]
}

class ContactsList: BaseTab{
    
    var contacts: [Contact]!
    var contactsDelegate: RequestContactsDelegate?
    // attributes for UI operations
    var numberOfBlockedContacts = 0
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    convenience init(contactsDelegate: RequestContactsDelegate){
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.contactsDelegate = contactsDelegate
        contacts = self.contactsDelegate?.provideContacts()
        processContacts()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.view.accessibilityViewIsModal = true
        adjustNavigationBarLabels()
        super.viewDidLoad()
        addSearchButtonToNavBar()
        collectionView.register(ContactCell.self, forCellWithReuseIdentifier: "ContactCellId")
    }
    
    override func setupBars(){
        setupBackground()
        setupNavBar(hasBackButton: true)
        
        navBar.addSubview(backArrow)
        backArrow.leftAnchor == navBar.leftAnchor + 20
        backArrow.topAnchor == navLabel.topAnchor
        backArrow.widthAnchor == 40
        backArrow.heightAnchor == 36
        backArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapBackArrow)))
    }
    
    @objc fileprivate func handleTapBackArrow(){
        self.dismiss(animated: true, completion: nil)
    }
    
 
    fileprivate func adjustNavigationBarLabels(){
        navTitle = "Contact's List"
        if numberOfBlockedContacts == 0{
            navSubtitle = "no contact is being blocked"
        }
        navLabel.accessibilityLabel = "Contact's List, \(navSubtitle)"
    }
    
    fileprivate func addSearchButtonToNavBar() {
        navBar.addSubview(searchButton)
        searchButton.rightAnchor == navBar.rightAnchor - 20
        searchButton.topAnchor == navLabel.topAnchor
        searchButton.widthAnchor == 40
        searchButton.heightAnchor == 40
        searchButton.isAccessibilityElement = true
        searchButton.accessibilityLabel = "Search Contact"
        searchButton.addTarget(self, action: #selector(handleTapSearchButton), for: .touchUpInside)
    }
    
    fileprivate func processContacts(){
        for contact in contacts{
            if(contact.isBlocked) {
                updateNavLabel(newBlockedContact: true)
            }
        }
    }
    
    @objc fileprivate func handleTapSearchButton(){
        navBar.addSubview(marineOverlay)
        marineOverlay.widthAnchor == navBar.widthAnchor
        marineOverlay.heightAnchor == navBar.heightAnchor
        
        navBar.addSubview(searchView)
        searchView.leftAnchor == marineOverlay.leftAnchor + 20
        searchView.topAnchor == navLabel.topAnchor
        searchView.rightAnchor == marineOverlay.rightAnchor - 80
        searchView.heightAnchor == 30
        
        let textField = searchView.subviews.filter{$0 is UITextField} as! [UITextField]
        textField.forEach{$0.addTarget(self, action: #selector(textDidChange), for: UIControl.Event.editingChanged)
                          $0.text = ""
                          $0.becomeFirstResponder()}
        
        navBar.addSubview(cancelButton)
        cancelButton.rightAnchor == marineOverlay.rightAnchor - 20
        cancelButton.topAnchor == navLabel.topAnchor
        cancelButton.heightAnchor == 30
        cancelButton.widthAnchor == 50
        cancelButton.addTarget(self, action: #selector(handleTapCancelButton), for: .touchUpInside)
    }
    
    @objc fileprivate func handleTapCancelButton(){
        self.contacts = contactsDelegate?.provideContacts()
        [cancelButton, searchView, marineOverlay].forEach { (view) in
            view.removeFromSuperview()
        }
        collectionView.reloadData()
    }
    
    let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Search"), for: .normal)
        return button
    }()
    
    let backArrow: UIView = {
        let view = UIView()
        view.isAccessibilityElement = true
        view.accessibilityLabel = "Go Back"
        
        let image = UIImage(named: "Arrow")
        let imageView = UIImageView(image: image)
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        imageView.leftAnchor == view.leftAnchor
        imageView.centerYAnchor == view.centerYAnchor
        imageView.widthAnchor == view.widthAnchor / 4
        imageView.heightAnchor == view.heightAnchor / 2
        
        return view
    }()
    
    // views for search bar
    let searchView: UIView = {
        let view = UIView()
        view.backgroundColor = .marine
        view.layer.cornerRadius = 8
        
        let magnifierView = UIImageView(image: UIImage(named: "Search"))
        magnifierView.clipsToBounds = true
        view.addSubview(magnifierView)
        magnifierView.leftAnchor == view.leftAnchor + 8
        magnifierView.bottomAnchor == view.bottomAnchor - 8
        magnifierView.topAnchor == view.topAnchor + 8
        magnifierView.widthAnchor == 16
        
        let searchTextField = UITextField()
        view.addSubview(searchTextField)
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Filter",
                                                                   attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                                                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)])
        searchTextField.textColor = .white
        searchTextField.font = UIFont.systemFont(ofSize: 13)
        UITextField.appearance().tintColor = .white
        searchTextField.backgroundColor = .marine
        searchTextField.leftAnchor == magnifierView.rightAnchor + 8
        searchTextField.bottomAnchor == view.bottomAnchor - 8
        searchTextField.topAnchor == view.topAnchor + 8
        searchTextField.rightAnchor == view.rightAnchor - 8
        
        return view
    }()
    
    let marineOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .darkMarine
        return view
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(NSAttributedString(string: "Cancel",
                                                     attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                                                                  NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)]), for: .normal)
        return button
    }()
    
}

extension ContactsList: UICollectionViewDelegateFlowLayout{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactCellId", for: indexPath) as! ContactCell
        if let contact = contacts?[indexPath.item]{
            cell.contact = contact
            cell.switchButtonDelegate = self
            
            if(contact.isBlocked){
                cell.switchButton.setOn(true, animated: false)
            } else {
                cell.switchButton.setOn(false, animated: false)
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SelectedCellDelegate
        cell.didSelectCell()
        provideHapticFeedback()
        
        let contact = contacts[indexPath.item]
        
        handleContactBlockStatusChanged(contact: contact)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 60, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 110, left: 0, bottom: 60, right: 0)
    }
    
}

extension ContactsList: ContactCellSwitchButtonDelegate{
    func handleTapSwitchButton(isOn: Bool, contact: Contact) {
        handleContactBlockStatusChanged(contact: contact)
    }
    
    fileprivate func handleContactBlockStatusChanged(contact: Contact){
        contact.isBlocked = !contact.isBlocked
        
        PersistentContainer.updateContactData(contact: contact)
        updateNavLabel(newBlockedContact: contact.isBlocked)
    }
    
    fileprivate func updateNavLabel(newBlockedContact: Bool){
        
        let currentlyBlockedCount = numberOfBlockedContacts
        
        if newBlockedContact{
            numberOfBlockedContacts += 1
            navSubtitle = "\(numberOfBlockedContacts) contact(s) are being blocked"
        }
        else{
            numberOfBlockedContacts -= 1
            if numberOfBlockedContacts == 0{
                navSubtitle = "no contact is being blocked"
            }
            else{
               navSubtitle = "\(numberOfBlockedContacts) contact(s) are being blocked"
            }
        }
        setupNavLabel()
        navLabel.accessibilityLabel = "Contact's List, \(navSubtitle)"
        if currentlyBlockedCount == 0 && numberOfBlockedContacts == 1{
            let alert = BlockedContactAlert()
            alert.modalPresentationStyle = .overFullScreen
            present(alert, animated: false, completion: nil)
        }
    }
}

extension ContactsList: UITextFieldDelegate{
    @objc fileprivate func textDidChange(textField: UITextField){
        guard let text = textField.text else {return}
        print("here - text: \(text)")
        let listOfContacts = contactsDelegate?.provideContacts()
        if let query = listOfContacts?.filter({$0.name.contains(text) || $0.numbers[0].contains(text)}){
            if text != ""{
                self.contacts = query
            }
            else{
                self.contacts = listOfContacts
            }
        }
        self.collectionView.reloadData()
    }
}




