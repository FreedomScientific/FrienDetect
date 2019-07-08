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

class NoDisturbAlert: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews(){
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.addSubview(dialogView)
        dialogView.centerXAnchor == view.centerXAnchor
        dialogView.centerYAnchor == view.centerYAnchor
        dialogView.widthAnchor == view.frame.width - 80
        dialogView.heightAnchor == 150
        
        dialogView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapButton)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dialogView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.3) {
            self.dialogView.transform = .identity
        }
    }
    
    
    var dialogView = DialogView(description: "By turning off alerts you won't be notified when your contacts are nearby")
    
    class DialogView: UIView{
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        convenience init(description: String){
            self.init(frame: .zero)
            alertDescription = description
            setupview()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        fileprivate func setupview(){
            backgroundColor = .marine
            layer.cornerRadius = 8
            
            addSubview(nameLabel)
            nameLabel.leftAnchor == leftAnchor + 10
            nameLabel.rightAnchor == rightAnchor - 10
            nameLabel.topAnchor == topAnchor + 4
            nameLabel.heightAnchor == 100
            nameLabel.text = alertDescription
            
            addSubview(button)
            button.centerXAnchor == centerXAnchor
            button.bottomAnchor == bottomAnchor - 4
            button.widthAnchor == 30
            button.heightAnchor == 30
        }
        
        var alertDescription = "Description"
        
        let nameLabel: UILabel = {
            let label = UILabel()
            label.text = "Description"
            label.textColor = .white
            label.numberOfLines = 3
            label.font = UIFont(name: "AvenirNext-Medium", size: 15)
            return label
        }()
        
        let button: UIButton = {
            let button = UIButton()
            button.setAttributedTitle(NSAttributedString(string: "OK", attributes: [NSAttributedString.Key.font : UIFont(name: "AvenirNext-Medium", size: 17), NSAttributedString.Key.foregroundColor : UIColor.white]), for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(handleTapButton), for: .touchUpInside)
            return button
        }()
        
    }
    
    
    @objc func handleTapButton(){
        
        UIView.animate(withDuration: 0.3) {
            
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dialogView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    
}
