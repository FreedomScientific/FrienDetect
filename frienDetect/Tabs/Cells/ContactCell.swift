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

let cache = NSCache<NSString, UIImage>()

class Contact: Hashable{
    var name: String!
    var numbers: [String]
    var imageData: Data!
    var isBlocked: Bool
    var appleContactID: String
    
    init(name: String, numbers: [String], imageData: Data?, isBlocked: Bool = false,
         appleContactID: String){
        self.name = name
        self.numbers = numbers
        self.imageData = imageData
        self.isBlocked = isBlocked
        self.appleContactID = appleContactID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(numbers[0])
    }
    
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.appleContactID == rhs.appleContactID
    }
}

class ContactCell: ActivesCell{
    
   override var contact: Contact?{
        didSet{
            guard let contact = contact else {return}
            updateCellContent(contact)
            rawPhoneNumber = contact.numbers[0]
            guard let name = contact.name else {return}
            accessibilityLabel = "\(name), discoverable"
        }
    }
    
    var switchButtonDelegate: ContactCellSwitchButtonDelegate?
    var rawPhoneNumber = "1234567899"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = true
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupLayout() {
        setupViews()
        setupSwitchButton()
    }
    
    fileprivate func setupSwitchButton(){
        cell.addSubview(switchButton)
        switchButton.rightAnchor == cell.rightAnchor - 8
        switchButton.heightAnchor == 30
        switchButton.widthAnchor == 50
        switchButton.bottomAnchor == phoneLabel.bottomAnchor
        switchButton.addTarget(self, action: #selector(handleTapSwitchButton), for: .touchUpInside)
    }
    
    @objc fileprivate func handleTapSwitchButton(){
        switchButtonDelegate?.handleTapSwitchButton(isOn: switchButton.isOn, contact: contact!)
    }
    
    
    let switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.onTintColor = UIColor(red: 58/255, green: 177/255, blue: 216/255, alpha: 1)
        return switchButton
    }()
    
}

protocol ContactCellSwitchButtonDelegate{
    func handleTapSwitchButton(isOn: Bool, contact: Contact)
}

extension ContactCell: SelectedCellDelegate{
    func didSelectCell() {
        guard let name = nameLabel.text else {return}
        if switchButton.isOn{
            switchButton.setOn(false, animated: true)
            accessibilityLabel = "\(name), discoverable"
        }
        else{
            switchButton.setOn(true, animated: true)
            accessibilityLabel = "\(name), not discoverable"
        }
    }
}

protocol ContactsBookDelegate{
    func handleNewEntry(phoneNumber: String)
}

extension ContactCell{
    
    static func phoneFormat(inputPhone: String) -> String{
        var outputPhone = finalFormat(string: inputPhone)
        return outputPhone
    }
    
    static func sanitizeNumber(_ string: String) -> String?{
        var finalString = string
        
        let validationRegex = #"^((\+)?1)?( )?\(?-?\d{3}\)?( )?-?\d{3}-?\d{4}"#
        let replaceRegexSet = [#"^\+1"#, "^1"," ", "-", #"\("#, #"\)"#]
        
        if let range = finalString.range(of: validationRegex, options: .regularExpression){
            replaceRegexSet.forEach { (char) in
                finalString = finalString.replacingOccurrences(of: char, with: "", options: .regularExpression)
            }
            
            return finalString
        }
        
        else {
           return nil
        }
        
        
    }
    
  static func finalFormat(string: String) -> String{
        var finalString = string
        finalString = "(\(string[0..<3])) \(string[3..<6])-\(string[6..<10])"
        
        return finalString
    }
}

