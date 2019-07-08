# FrienDetect
FrienDetect is an iOS app  that uses Bluetooth LE to find other people within Bluetooth range also running the app. The intended audience is blind people in a crowded room wanting  to know which of their contacts is nearby.
This was a student project developed as part of the University of Florida’s IPPD program. You can read more about its origin at http://www.ippd.ufl.edu/index.php/projects/2-uncategorised/151-current-projects2018.

The app in its current incarnation is peer to peer without any sort of server infrastructure .
In order for user1 to report that user2 is nearby, they must have one another in their respective iOS contacts. 

Since iOS does not allow an app to programmatically determine the phone number of the person running it, the app uses Firebase to authenticate the number provided by each user on first run. You’ll need to create a free Firebase account an  fill in firebase credentials in the GoogleService-Info file before this will work properly.

The app is at prototype stage where it’s been proven to work with a small number of iOS devices within vicinity of one another.
