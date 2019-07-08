# FrienDetect
FrienDetect is an iOS app  that uses Bluetooth LE to find other people within Bluetooth range also running the app. The intended audience is blind people in a crowded room wanting  to know which of their contacts is nearby.
This was a student project developed as part of the University of Florida’s IPPD program. You can read more about its origin at the [University Of Florida IPPD website](http://www.ippd.ufl.edu/index.php/projects/2-uncategorised/151-current-projects2018.).

The app in its current incarnation is peer to peer without any sort of server infrastructure .
In order for user1 to report that user2 is nearby, they must have one another in their respective iOS contacts. 

Since iOS does not allow an app to programmatically determine the phone number of the person running it, the app uses Firebase to authenticate the number provided by each user on first run. You’ll need to create a free Firebase account an  fill in firebase credentials in the GoogleService-Info file before this will work properly.

The app is at prototype stage where it’s been proven to work with a small number of iOS devices within vicinity of one another.


Instructions to compile and run FrienDetect. ~25min setup
=========================================================


Requirements:
-----------------------------
* MacOS Mojave+
* FrienDetect.bundle file
* Recommended iPhone 5s(or higher) with usb cable

Apple Account (~5min)
-----------------------------
* Setup an Apple ID
	* need name, email, security questions
* Setup an Apple Developer Acconut
	* go to: https://developer.apple.com/

Installing Programs (~10min)
--------------------------------
* Install XCode (get from AppStore or Apple Website)
* Install XCode command line tools
	* run 'xcode-select --install'
* Install Cocoa Pods
	* run 'sudo gem install cocoapods' (or download from internet)


Compiling without FireBase ~10min
-------------------------------------
* In xx/FrienDetect:
	* run 'pod install'
	* run 'open ./frienDetect.xcworkspace'

* In XCode:
	* Open 'frienDetect'- the project file (available in the left pane*):
		*hit command+shift+1 to show project navigator
	* In the project under general>signing>team, select your account
	* In general>Identity>Bundle Identifier, append numbers so it's unique
		* press enter
		* if uniqueness error shows under general>signing, append more numbers & press enter.
		* The Bundle Identifier must be unique and should be configured properly before uploading to the AppStore/TestFlight

* On iPhone
	* connect, unlock and hit 'trust this computer'
* In XCode (top left corner) click the drop down & select your device
* Hit the play button or press 'command+r' 
* If you are using a free account, open the iPhone and go to settings>general>device management(at the bottom), select your account and hit trust. Now the run command will work (you will have to do this periodically when using a free account)

Troubleshooting:
----------------------
* If compilation fails, hit command+5 to view error messages
* This can help explain what is missing
