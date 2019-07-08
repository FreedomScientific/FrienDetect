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

class ActivesCell: UICollectionViewCell{
    
    var contact: Contact?{
        didSet{
            guard let contact = contact else {return}
            updateCellContent(contact)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCellContent(_ contact: Contact) {
        nameLabel.text = contact.name
        phoneLabel.text = ContactCell.phoneFormat(inputPhone: contact.numbers[0]) // prob
        profileImageView.image = UIImage(named: "profile")
        
        if let imageData = contact.imageData{
            if let image = cache.object(forKey: contact.numbers[0] as NSString){
                profileImageView.image = image
            }
            else{
                guard let imageData = contact.imageData else {return}
                guard let image = UIImage(data: imageData) else {return}
                cache.setObject(image, forKey: contact.numbers[0] as NSString)
                profileImageView.image = image
            }
        }
    }
    
    func setupLayout() {
        setupViews()
        setupMessageAndPhoneButtons()
    }
    
    func setupViews(){
        setupBaseCell()
        
        phoneLabel.topAnchor == nameLabel.bottomAnchor + 4
        phoneLabel.leftAnchor == nameLabel.leftAnchor
        phoneLabel.heightAnchor == 12
        phoneLabel.rightAnchor == nameLabel.rightAnchor
        
    }
    
    func setupBaseCell() {
        addSubview(cell)
        cell.widthAnchor == widthAnchor
        cell.heightAnchor == heightAnchor
        
        [profileFrameView, phoneLabel, nameLabel].forEach { (view) in
            cell.addSubview(view)
        }
        
        profileFrameView.leftAnchor == cell.leftAnchor + 15
        profileFrameView.topAnchor == cell.topAnchor + 10
        profileFrameView.bottomAnchor == cell.bottomAnchor - 10
        profileFrameView.widthAnchor == cell.heightAnchor - 20
        profileFrameView.layer.cornerRadius = (frame.height - 20) / 2
        
        profileFrameView.addSubview(profileImageView)
        profileImageView.centerXAnchor == profileFrameView.centerXAnchor
        profileImageView.centerYAnchor == profileFrameView.centerYAnchor
        profileImageView.widthAnchor == profileFrameView.widthAnchor - 20
        profileImageView.heightAnchor == profileFrameView.heightAnchor - 20
        profileImageView.layer.cornerRadius = (frame.height - 40) / 2
        
        nameLabel.leftAnchor == profileFrameView.rightAnchor + 10
        nameLabel.rightAnchor == cell.rightAnchor - 50
        nameLabel.bottomAnchor == profileFrameView.centerYAnchor
        nameLabel.heightAnchor == 20
    }
    
    fileprivate func setupMessageAndPhoneButtons() {
        [phoneButton, messageButton].forEach { (view) in
            cell.addSubview(view)
        }
        
        messageButton.rightAnchor == cell.rightAnchor - 8
        messageButton.bottomAnchor == cell.bottomAnchor - 8
        messageButton.widthAnchor == 30
        messageButton.heightAnchor == 30
        messageButton.addTarget(self, action: #selector(textNumber), for: .touchUpInside)
        
        phoneButton.bottomAnchor == messageButton.bottomAnchor
        phoneButton.rightAnchor == messageButton.leftAnchor - 20
        phoneButton.widthAnchor == 30
        phoneButton.heightAnchor == 30
        phoneButton.addTarget(self, action: #selector(dialNumber), for: .touchUpInside)
    }
    
    fileprivate func openURL(_ string: String) {
        if let url = URL(string: string),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func dialNumber() {
        guard let number = contact?.numbers[0] else {return}
        let string = "tel://\(number)"
        openURL(string)
    }
    
    @objc func textNumber(){
        guard let number = contact?.numbers[0] else {return}
        let string = "sms:\(number)"
        openURL(string)
    }
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Heavy", size: 15)
        label.textColor = UIColor(red: 18/255, green: 176/255, blue: 165/255, alpha: 1)
        label.text = "Tim Cook"
        return label
    }()
    
    let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 12)
        label.textColor = .white
        label.text = "(961) 866-8520"
        return label
    }()
    
    let cell: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .marine
        return view
    }()
    
    let profileFrameView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkMarine
        return view
    }()
    
    let profileImageView: UIImageView = {
        let image = UIImage(named: "profile")
        let imageView = UIImageView(image: image)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let phoneButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "phone"), for: .normal)
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Call friend"
        return button
    }()
    
    let messageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "message"), for: .normal)
        button.isAccessibilityElement = true
        button.accessibilityLabel = "message friend"
        return button
    }()
    
}
