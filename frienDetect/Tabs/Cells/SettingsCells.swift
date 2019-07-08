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


protocol NoDisturbAlertDelegate{
    func handleNoDisturb(isOn: Bool)
}

class SettingsCell: UICollectionViewCell{
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews(){
        
        isAccessibilityElement = true
        accessibilityLabel = accessibilityInfo
        [nameLabel, icon, dividerLine].forEach { (view) in
            addSubview(view)
        }
        
        icon.leftAnchor == leftAnchor + 20
        icon.bottomAnchor == bottomAnchor - 10
        icon.widthAnchor == 30
        icon.heightAnchor == 30
        
        nameLabel.leftAnchor == icon.rightAnchor + 20
        nameLabel.bottomAnchor == bottomAnchor - 10
        nameLabel.widthAnchor == frame.width - 120
        nameLabel.heightAnchor == 25
        
        dividerLine.bottomAnchor == bottomAnchor
        dividerLine.leftAnchor == leftAnchor + 20
        dividerLine.rightAnchor == rightAnchor
        dividerLine.heightAnchor == 0.5
    }
    
    var accessibilityInfo = "Do Not Disturb, off"
    
    let icon: UIImageView = {
        let image = UIImage(named: "Disturb")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Do Not Disturb"
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        return label
    }()
    
    let dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
}

class DoNotDisturbCell: SettingsCell{
    
    var delegate: NoDisturbAlertDelegate!
    
    enum option{
        case on
        case off
    }
    
    var optionState = option.off
    let defaults = UserDefaults.standard
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupSwitchButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupSwitchButton(){
        addSubview(switchButton)
        switchButton.rightAnchor == rightAnchor - 30
        switchButton.bottomAnchor == bottomAnchor - 10
        switchButton.heightAnchor == 30
        switchButton.widthAnchor == 50
        
        switchButton.addTarget(self, action: #selector(handleTapSwitchButton), for: .touchUpInside)
        
        let isOn = defaults.bool(forKey: "DoNotDisturb")
        switchButton.setOn(isOn, animated: false)
        optionState = (isOn) ? .on : .off
    }
    
    @objc fileprivate func handleTapSwitchButton(){
        switch optionState {
        case .on:
            optionState = .off
            accessibilityLabel = "Do Not Disturb, off"
            switchButton.setOn(false, animated: true)
            delegate.handleNoDisturb(isOn: false)
        case .off:
            optionState = .on
            accessibilityLabel = "Do Not Disturb, on"
            switchButton.setOn(true, animated: true)
            delegate.handleNoDisturb(isOn: true)
        }
    }
    
    let switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.onTintColor = .marine
        return switchButton
    }()
    
}

extension DoNotDisturbCell: SelectedCellDelegate{
    
    func didSelectCell() {
        handleTapSwitchButton()
    }
    
}

class FriendsListCell: SettingsCell{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        adjustViews()
        setupViews()
        setupButton()
    }
    
    fileprivate func adjustViews(){
        accessibilityInfo = "Contact's List"
        nameLabel.text = "Contact's List"
        icon.image = UIImage(named: "Contacts")
    }
    
    fileprivate func setupButton(){
        addSubview(button)
        button.rightAnchor == rightAnchor - 30
        button.bottomAnchor == bottomAnchor - 10
        button.heightAnchor == 25
        button.widthAnchor == 15
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "forwardArrow"), for: .normal)
        return button
    }()
    
}

