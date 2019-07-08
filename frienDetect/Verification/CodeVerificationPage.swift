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
import Firebase

protocol CodeVerificationPageDelegate{
    func handleTapOnBackArrow()
    func handleCodeWasSuccessful()
    func testCode(_ code: String, completion: @escaping (_ isGoodCode: Bool) -> Void)
}

class CodeVerificationPage: UIViewController{
    
    var currentCell = cursor.one
    
    var inputIsDisabled = false
    
    var delegate: CodeVerificationPageDelegate?
    
    let hiddenTextField = UITextField()
    
    init(delegate: CodeVerificationPageDelegate, number: String){
        let formattedNumber = ContactCell.finalFormat(string: number)
        textLabel.text = "Please type the verification code sent to \(formattedNumber)"
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        super.viewDidLoad()
        setupViews()
        setupInputControl()
    }
    
    fileprivate func setupInputControl() {
        view.addSubview(hiddenTextField)
        hiddenTextField.delegate = self
        hiddenTextField.keyboardType = .numberPad
        hiddenTextField.becomeFirstResponder()
    }
    
    fileprivate func setupViews(){
        view.backgroundColor = .darkMarine
        
        view.addSubview(nameLabel)
        let horizontalPadding: CGFloat = 50
        let distanceFromTop: CGFloat = 75
        nameLabel.widthAnchor == view.frame.width - 2 * horizontalPadding
        nameLabel.heightAnchor == 30
        nameLabel.topAnchor == view.topAnchor + distanceFromTop
        nameLabel.leftAnchor == view.leftAnchor + horizontalPadding
        nameLabel.rightAnchor == view.rightAnchor - horizontalPadding
        
        view.addSubview(textLabel)
        textLabel.widthAnchor == view.frame.width - 2 * horizontalPadding
        textLabel.heightAnchor == 45
        textLabel.topAnchor == nameLabel.bottomAnchor + 8
        textLabel.leftAnchor == view.leftAnchor + horizontalPadding
        textLabel.rightAnchor == view.rightAnchor - horizontalPadding
        
        view.addSubview(cellOne)
        let cellWidth: CGFloat = 45
        let cellHeight: CGFloat = 55
        let distanceFromLabelToCell: CGFloat = 40
        let distanceBetweenCells: CGFloat = 6
        let cellHorizontalPadding: CGFloat = (view.frame.width - (6 * cellWidth + 5 * distanceBetweenCells)) / 2
        
        cellOne.topAnchor == textLabel.bottomAnchor + distanceFromLabelToCell
        cellOne.leftAnchor == view.leftAnchor + cellHorizontalPadding
        cellOne.widthAnchor == cellWidth
        cellOne.heightAnchor == cellHeight
        
        view.addSubview(cellTwo)
        cellTwo.topAnchor == cellOne.topAnchor
        cellTwo.leftAnchor == cellOne.rightAnchor + distanceBetweenCells
        cellTwo.widthAnchor == cellWidth
        cellTwo.heightAnchor == cellHeight
        
        view.addSubview(cellThree)
        cellThree.topAnchor == cellOne.topAnchor
        cellThree.leftAnchor == cellTwo.rightAnchor + distanceBetweenCells
        cellThree.widthAnchor == cellWidth
        cellThree.heightAnchor == cellHeight
  
        view.addSubview(cellFour)
        cellFour.topAnchor == cellOne.topAnchor
        cellFour.leftAnchor == cellThree.rightAnchor + distanceBetweenCells
        cellFour.widthAnchor == cellWidth
        cellFour.heightAnchor == cellHeight
        
        view.addSubview(cellFive)
        cellFive.topAnchor == cellOne.topAnchor
        cellFive.leftAnchor == cellFour.rightAnchor + distanceBetweenCells
        cellFive.widthAnchor == cellWidth
        cellFive.heightAnchor == cellHeight

        view.addSubview(cellSix)
        cellSix.topAnchor == cellOne.topAnchor
        cellSix.leftAnchor == cellFive.rightAnchor + distanceBetweenCells
        cellSix.widthAnchor == cellWidth
        cellSix.heightAnchor == cellHeight
        
        
        view.addSubview(backArrow)
        backArrow.leftAnchor == view.leftAnchor + 20
        backArrow.topAnchor == view.topAnchor + 40
        backArrow.widthAnchor == 40
        backArrow.heightAnchor == 36
        backArrow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnBackArrow)))
        
        [cellOne, cellTwo, cellThree, cellFour, cellFive, cellSix].forEach{
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startEditing)))
        }
    }
    
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
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 25)
        label.textColor = .white
        label.text = "Verification Code"
        label.textAlignment = .center
        return label
    }()

    let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Light", size: 15)
        label.textColor = .white
        label.text = "Please type the verification code sent to +34 4921 801 856"
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    let cellOne = Cell()
    let cellTwo = Cell()
    let cellThree = Cell()
    let cellFour = Cell()
    let cellFive = Cell()
    let cellSix = Cell()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    class Cell: UIView{
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.cornerRadius = 8
            backgroundColor = .white
            
            digit.textColor = .darkGray
            digit.text = ""
            digit.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 25)
            digit.textAlignment = .center
            
            addSubview(digit)
            digit.centerXAnchor == centerXAnchor
            digit.centerYAnchor == centerYAnchor
            digit.heightAnchor == heightAnchor - 8
            digit.widthAnchor == widthAnchor - 8
            
        }
        
        let digit = UILabel()
        
         convenience init(){
            self.init(frame: .zero)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}

extension CodeVerificationPage{
    
    enum cursor{
        case one
        case two
        case three
        case four
        case five
        case six
    }
    
    fileprivate func verifyCode(){
        print("Testing Code")
        let cellsArray = [cellOne, cellTwo, cellThree, cellFour, cellFive, cellSix]
        
        /*  Compare user code with firebase code
         */
        var userCode = ""
        cellsArray.forEach { (cell) in
            userCode += cell.digit.text ?? ""
        }
        
        delegate?.testCode(userCode) { (codeIsGood: Bool) in
            if(codeIsGood){
                self.delegate?.handleCodeWasSuccessful()
                self.dismiss(animated: true, completion: nil)
                return
            } else {
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.5)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
                
                let borderAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.borderWidth))
                
                CATransaction.setCompletionBlock {
                    let fadeAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.borderColor))
                    fadeAnimation.fromValue = UIColor.red.cgColor
                    fadeAnimation.toValue = UIColor.white.cgColor
                    fadeAnimation.duration = 0.5
                    fadeAnimation.delegate = self
                    
                    cellsArray.forEach({ (cell) in
                        cell.layer.borderColor = UIColor.white.cgColor
                        cell.layer.add(fadeAnimation, forKey: "fade")
                        
                        borderAnimation.fromValue = 4
                        borderAnimation.toValue = 0
                        cell.layer.borderWidth = 0
                        cell.digit.text = ""
                        cell.layer.add(borderAnimation, forKey: "border")
                    })
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
                
                borderAnimation.fromValue = 0
                borderAnimation.toValue = 4
                
                cellsArray.forEach { (cell) in
                    cell.layer.borderColor = UIColor.red.cgColor
                    cell.layer.borderWidth = 4
                    cell.layer.add(borderAnimation, forKey: "borderWidth")
                }
                
                CATransaction.commit()
                
                self.currentCell = .one
            }
        }
    }
    
    @objc fileprivate func handleTapOnBackArrow(){
        dismiss(animated: true, completion: nil)
        delegate?.handleTapOnBackArrow()
    }
    
    @objc fileprivate func startEditing(){
        hiddenTextField.becomeFirstResponder()
    }
    
    fileprivate func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
}

extension CodeVerificationPage: CAAnimationDelegate{
    
    fileprivate func disableInput(){
        inputIsDisabled = true
    }
    
    fileprivate func reenableInput(){
        inputIsDisabled = false
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        reenableInput()
    }
}

protocol InputControlDelegate{
    func insertText(_ text: String)
    func hasText() -> Bool
    func deleteBackward()
}

extension CodeVerificationPage: InputControlDelegate{
    
    func hasText() -> Bool {
        return (currentCell == cursor.one) ? false : true
    }
    
    func insertText(_ text: String) {
        if inputIsDisabled{
            return
        }
        
        provideHapticFeedback()
        
        switch currentCell {
        case .one:
            cellOne.digit.text = text
            currentCell = .two
        case .two:
            cellTwo.digit.text = text
            currentCell = .three
        case .three:
            cellThree.digit.text = text
            currentCell = .four
        case .four:
            cellFour.digit.text = text
            currentCell = .five
        case .five:
            cellFive.digit.text = text
            currentCell = .six
        case .six:
            cellSix.digit.text = text
            disableInput()
            verifyCode()
        }
    }
    
    func deleteBackward() {
        if inputIsDisabled{
            return
        }
        
        switch currentCell {
        case .one:
            cellOne.digit.text = ""
        case .two:
            cellOne.digit.text = ""
            currentCell = .one
        case .three:
            cellTwo.digit.text = ""
            currentCell = .two
        case .four:
            cellThree.digit.text = ""
            currentCell = .three
        case .five:
            cellFour.digit.text = ""
            currentCell = .four
        case .six:
            cellFive.digit.text = ""
            currentCell = .five
        }
        
        provideHapticFeedback()
    }
}

extension CodeVerificationPage: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let code = (hiddenTextField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if string != ""{
            insertText(string)
        }
        else{
            deleteBackward()
        }
        return true
    }
}


