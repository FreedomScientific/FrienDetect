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

protocol PhoneVerificationPageDelegate{
    func handlePhoneNumberSubmitted(phoneNumber: String)
}

class PhoneVerificationPage: UIViewController {
    
    var delegate: PhoneVerificationPageDelegate?
    
    var modelText = ""
    
    init(delegate: PhoneVerificationPageDelegate){
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        disableButton()
    }
    
    fileprivate func setupViews(){
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        phoneTextField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.widthAnchor == view.widthAnchor
        scrollView.heightAnchor == view.heightAnchor
        
        scrollView.addSubview(blueOverlay)
        blueOverlay.leftAnchor == scrollView.leftAnchor
        blueOverlay.rightAnchor == scrollView.rightAnchor
        blueOverlay.bottomAnchor == scrollView.centerYAnchor
        blueOverlay.heightAnchor == scrollView.heightAnchor / 2
        
        scrollView.addSubview(dividerLine)
        let horizontalPadding: CGFloat = 50
        let distanceFromBlueOverlayToLine: CGFloat = 100
        dividerLine.widthAnchor == view.frame.width - 2 * horizontalPadding
        dividerLine.heightAnchor == 1.3
        dividerLine.topAnchor == blueOverlay.bottomAnchor + distanceFromBlueOverlayToLine
        dividerLine.leftAnchor == scrollView.leftAnchor + horizontalPadding
        dividerLine.rightAnchor == scrollView.rightAnchor - horizontalPadding
        
        scrollView.addSubview(countryLabel)
        countryLabel.widthAnchor == view.frame.width - 2 * horizontalPadding
        countryLabel.heightAnchor == 25
        countryLabel.leftAnchor == scrollView.leftAnchor + horizontalPadding
        countryLabel.rightAnchor == scrollView.rightAnchor - horizontalPadding
        countryLabel.bottomAnchor == dividerLine.topAnchor - 10
        
        scrollView.addSubview(bottomDividerLine)
        let distanceFromLineToLine: CGFloat = 80
        bottomDividerLine.widthAnchor == view.frame.width - 2 * horizontalPadding
        bottomDividerLine.heightAnchor == 1.3
        bottomDividerLine.topAnchor == dividerLine.bottomAnchor + distanceFromLineToLine
        bottomDividerLine.leftAnchor == scrollView.leftAnchor + horizontalPadding
        bottomDividerLine.rightAnchor == scrollView.rightAnchor - horizontalPadding
        
        
        scrollView.addSubview(phoneTextField)
        phoneTextField.widthAnchor == view.frame.width - 2 * horizontalPadding
        phoneTextField.heightAnchor == 25
        phoneTextField.bottomAnchor == bottomDividerLine.topAnchor - 10
        phoneTextField.leftAnchor == scrollView.leftAnchor + horizontalPadding
        phoneTextField.rightAnchor == scrollView.rightAnchor - horizontalPadding
        
        scrollView.addSubview(buttonBackLayer)
        buttonBackLayer.widthAnchor == view.frame.width - 2 * horizontalPadding
        buttonBackLayer.heightAnchor == 47
        buttonBackLayer.bottomAnchor == bottomDividerLine.bottomAnchor + distanceFromLineToLine + 12
        buttonBackLayer.leftAnchor == scrollView.leftAnchor + horizontalPadding
        buttonBackLayer.rightAnchor == scrollView.rightAnchor - horizontalPadding
        
        scrollView.addSubview(submitButton)
        submitButton.widthAnchor == view.frame.width - 2 * horizontalPadding
        submitButton.heightAnchor == 45
        submitButton.bottomAnchor == bottomDividerLine.bottomAnchor + distanceFromLineToLine + 10
        submitButton.leftAnchor == scrollView.leftAnchor + horizontalPadding
        submitButton.rightAnchor == scrollView.rightAnchor - horizontalPadding
        
        scrollView.addSubview(nameLabel)
        nameLabel.widthAnchor == view.frame.width - 2 * horizontalPadding
        nameLabel.heightAnchor == 80
        nameLabel.bottomAnchor == blueOverlay.bottomAnchor - 150
        nameLabel.leftAnchor == scrollView.leftAnchor + horizontalPadding
        nameLabel.rightAnchor == scrollView.rightAnchor - horizontalPadding
        
        submitButton.addTarget(self, action: #selector(handleTapOnSubmitButton), for: .touchUpInside)
    }
    
    
    let scrollView = UIScrollView()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 25)
        label.textColor = .white
        label.text = "Let's verify your phone number"
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    let blueOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .darkMarine
        view.clipsToBounds = true
        return view
    }()
    
    let dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    let bottomDividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    let countryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        label.text = "United States (+1)"
        return label
    }()
    
    let phoneTextField: UITextField = {
        let field = UITextField()
        field.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        field.placeholder = "Your phone number"
        field.keyboardType = .numberPad
        return field
    }()
    
    let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
        button.backgroundColor = .silver
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    let buttonBackLayer: UIView = {
        let view = UIView()
        view.backgroundColor =  .darkSilver
        view.layer.cornerRadius = 8
        return view
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    fileprivate func registerListeners(){
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc fileprivate func handleTapOnSubmitButton(){
        let number = modelText
        print("phoneNumber: \(number)")
        dismiss(animated: true, completion: nil)
        delegate?.handlePhoneNumberSubmitted(phoneNumber: number)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.setContentOffset(CGPoint(x: 0, y: keyboardSize.height), animated: true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset = .zero
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerListeners()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // removing observer
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func enableButton(){
        submitButton.backgroundColor = .steelBlue
        submitButton.setTitleColor(.white, for: .normal)
        buttonBackLayer.backgroundColor = .darkSteel
        submitButton.isUserInteractionEnabled = true
    }
    
    fileprivate func disableButton(){
        submitButton.backgroundColor = .silver
        submitButton.setTitleColor(.darkGray, for: .normal)
        buttonBackLayer.backgroundColor = .darkSilver
        submitButton.isUserInteractionEnabled = false
    }
}

extension UIColor{
    static var steelBlue = UIColor(red: 70/255, green: 130/255, blue: 180/255, alpha: 1)
    static var darkSteel = UIColor(red: 61/255, green: 121/255, blue: 171/255, alpha: 1)
    static var bleue = UIColor(red: 49/255, green: 140/255, blue: 231/255, alpha: 1)
    static var darkBleue = UIColor(red: 40/255, green: 131/255, blue: 222/255, alpha: 1)
    static var silver = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
    static var darkSilver = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    static var darkMarine = UIColor(red: 36/255, green: 42/255, blue: 58/255, alpha: 1)
    static var marine = UIColor(red: 44/255, green: 62/255, blue: 82/255, alpha: 1)
}

extension PhoneVerificationPage: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let phoneNumber = (phoneTextField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if string != "" && modelText.count < 10{
            modelText += string
        }
        else if string == ""{
            modelText.removeLast()
        }
        
        var text = ""
        
        if modelText.count < 3{
            text = modelText
        }
        else if modelText.count <= 6{
            text = "(\(modelText[0 ..< 3])) \(modelText[3 ..< 7])"
        }
        else{
            text = "(\(modelText[0 ..< 3])) \(modelText[3 ..< 6])-\(modelText[6 ..< 10])"
        }
        
        if modelText.count == 10{
            enableButton()
        }
        else{
            disableButton()
        }
        
        textField.text = text
        return false
    }
    
   
}


extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
}
