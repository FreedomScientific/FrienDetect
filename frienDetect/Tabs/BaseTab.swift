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

protocol TabBarDelegate{
    func handleActivesTap()
    func handleRecentsTap()
    func handleSettingsTap()
}

class BaseTab: UICollectionViewController{
    
    // Tab bar delegate
    var delegate: TabBarDelegate?

    override func viewDidLoad() {
        self.view.accessibilityViewIsModal = true
        setupBars()
    }
    
    func setupBars() {
        setupBackground()
        setupNavBar()
        setupTabBar()
    }
    
    func setupBackground(){
        collectionView.backgroundColor = .white
    }
    
    func setupNavLabel() {
        let attributedText = NSMutableAttributedString(string: "\(navTitle)\n", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Heavy", size: 26)])
        attributedText.append(NSAttributedString(string: "\(navSubtitle)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Medium", size: 17)]))
        navLabel.attributedText = attributedText
    }
    
    func setupNavBar(hasBackButton: Bool = false){
        setupNavLabel()
        
        let navLabelLeftPadding: CGFloat = (hasBackButton) ? 50 : 20
        navBar.addSubview(navLabel)
        navLabel.leftAnchor == navBar.leftAnchor + navLabelLeftPadding
        navLabel.bottomAnchor == navBar.bottomAnchor - 2
        navLabel.heightAnchor == 60
        
        view.addSubview(navBar)
        navBar.topAnchor == view.topAnchor
        navBar.leftAnchor == view.leftAnchor
        navBar.rightAnchor == view.rightAnchor
        navBar.heightAnchor == 100
        navBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        
        navBar.backgroundColor = .darkMarine
        navBar.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)

    }
    
    func setupTabBar(){
        view.addSubview(tabBar)
        tabBar.leftAnchor == view.leftAnchor
        tabBar.rightAnchor == view.rightAnchor
        tabBar.bottomAnchor == view.bottomAnchor
        tabBar.heightAnchor == 50
        tabBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        tabBar.backgroundColor = .darkMarine
        tabBar.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        
       
        tabBar.addSubview(homeButton)
        tabBar.addSubview(recentsButton)
        tabBar.addSubview(detailsButton)
        
        let numberOfTabs = 3
        let tabIconWidth: CGFloat = 38
        let horizontalPadding: CGFloat = 40
        let verticalPadding: CGFloat = 7
        let tabBarWidth: CGFloat = view.frame.width
        let usedSpace: CGFloat = 3 * tabIconWidth + 2 * horizontalPadding
        let spaceBetweenIcons: CGFloat = (tabBarWidth - usedSpace) / CGFloat((numberOfTabs - 1))
        
        homeButton.topAnchor == tabBar.topAnchor + verticalPadding
        homeButton.bottomAnchor == tabBar.bottomAnchor - verticalPadding
        homeButton.leftAnchor == tabBar.leftAnchor + horizontalPadding
        homeButton.widthAnchor == tabIconWidth
        
        recentsButton.topAnchor == tabBar.topAnchor + verticalPadding
        recentsButton.bottomAnchor == tabBar.bottomAnchor - verticalPadding
        recentsButton.leftAnchor == homeButton.rightAnchor + spaceBetweenIcons
        recentsButton.widthAnchor == tabIconWidth
        
        detailsButton.topAnchor == tabBar.topAnchor + verticalPadding
        detailsButton.bottomAnchor == tabBar.bottomAnchor - verticalPadding
        detailsButton.leftAnchor == recentsButton.rightAnchor + spaceBetweenIcons
        detailsButton.widthAnchor == tabIconWidth
        
        homeButton.addTarget(self, action: #selector(handleActivesTap), for: .touchUpInside)
        recentsButton.addTarget(self, action: #selector(handleRecentsTap), for: .touchUpInside)
        detailsButton.addTarget(self, action: #selector(handleSettingsTap), for: .touchUpInside)
    }
    
    func updateAccessibilityLabelForActiveTab(tab: String){
        switch tab {
        case "active":
            homeButton.accessibilityLabel = "Selected, active friends tab"
            recentsButton.accessibilityLabel = "recents tab"
            detailsButton.accessibilityLabel = "details tab"
        case "recents":
            homeButton.accessibilityLabel = "active friends tab"
            recentsButton.accessibilityLabel = "Selected, recents tab"
            detailsButton.accessibilityLabel = "details tab"
        case "details":
            homeButton.accessibilityLabel = "active friends tab"
            recentsButton.accessibilityLabel = "recents tab"
            detailsButton.accessibilityLabel = "Selected, details tab"
        default:
            break
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @objc func handleActivesTap(){
        delegate?.handleActivesTap()
    }
    
    @objc func handleRecentsTap(){
        delegate?.handleRecentsTap()
    }
    
    @objc func handleSettingsTap(){
        delegate?.handleSettingsTap()
    }
    
    let navBar = UIView()
    let tabBar = UIView()
    
    var navTitle = "Active Friends"
    var navSubtitle = "no friend is nearby"
    
    let navLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "Active Friends")
        label.numberOfLines = 2
        return label
    }()
    
    let homeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "Userpic")
        button.setImage(image, for: .normal)
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Selected, active friends tab"
        return button
    }()
    
    let recentsButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "RecentsDisabled")
        button.setImage(image, for: .normal)
        button.isAccessibilityElement = true
        button.accessibilityLabel = "recents tab"
        return button
    }()
    
    let detailsButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "DetailsDisabled")
        button.isAccessibilityElement = true
        button.accessibilityLabel = "details tab"
        button.setImage(image, for: .normal)
        return button
    }()
    
}

extension UIView{
    
    func setBackgroundGradient(colorOne: UIColor, colorTwo: UIColor){
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

