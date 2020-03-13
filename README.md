# Firebase - Getting Started

Introduction to Firebase. In this app we will cover [Authentication](https://firebase.google.com/docs/auth), [Firestore](https://firebase.google.com/docs/firestore) and [Storage](https://firebase.google.com/docs/storage).

## Running this app

In order to run this app please do the following: 

1. Clone this project to your machine. 
2. Using your google sign in account, navigate to the [Firebase console](https://console.firebase.google.com/u/0/) and create a Firebase project. 
3. Go through the project creation steps below. 
4. Download and add the ```GoogleService-Info.plist``` file to your Xcode project. 
5. At this point you will be able to successfully run this project. 

[See lecture videos for more](https://www.youtube.com/watch?v=n0z2uSDY2Nw&t)

![app screenshot](Assets/app-screenshot.png)

## Marketplace app

![marketplace app](Assets/marketplace-app.gif)

[Firebase](https://firebase.google.com/) 

## App Features

- [x] user can sign in
- [x] user can create a new account
- [x] user can sign out
- [x] user can create an item
- [x] user can view an item
- [x] app stores user profile photos 
- [x] app stores item photos
- [x] user can change profile photo and display name
- [x] user can delete ONLY their created item (security rules)
- [ ] set security rules to prevent user from deleting items that wasn't created by them
- [x] user can see a specific user's items 
- [x] can add a comment to an item (firebase subcollections)
- [ ] can query (filter) for a specific category of items 
- [x] user can favorite an item from the item feed



## 1. Sign up using your Google account and create a Firebase Project

[Firebase Console](https://console.firebase.google.com/u/0/)

![firebase console](Assets/firebase-console.png)

## 2. Part 1 of 3 of creating a Firebase project 

![firebase project part 1](Assets/screenshot1.png)


## 3. Part 2 of 3 of creating a Firebase project 

![firebase project part 1](Assets/screenshot2.png)


## 4. Part 3 of 3 of creating a Firebase project 

![firebase project part 1](Assets/screenshot3.png)


## 5. Project created 

![firebase project part 1](Assets/screenshot5.png)

## 6. Firebase console 

In the left column are the services available from Firebase. In this course we will be using **Authentication**, **Database** and **Storage**. 

![firebase project part 1](Assets/screenshot6.png)

## 7. Let's now add the Firebase project to our iOS app

Click on the iOS button to start the process integrating the Firebase project with your Xcode project. This will be make possible with a created GoogleService-Info.plist file. 

![firebase project part 1](Assets/screenshot7.png)

## 8. Add the bundle identifier from Xcode to your Firebase project 

The bundle identifier is critical in associating your Xcode project with the Firebase project.

![firebase project part 1](Assets/screenshot8.png)

![firebase project part 1](Assets/screenshot9.png)

## 9. If your Github repository is public add your GoogleService-Info.plist to .gitignore

**.gitignore** file 

GoogleService-Info.plist 

## 10. Download the GoogleService-Info.plist file 

Download the GoogleService-Info.plist file and add it to your Xcode project. 

![firebase project part 1](Assets/screenshot10.png)

## 11. Add the Firebase SDK using CocoaPods to your project 

Initialize pod into your project by running ```pod init``` in Terminal. Open your Podfile and add ```pod 'Firebase/Analytics'``` to it and run ```pod install```. At this point closse Xcode and now you will have an **xcworkspace** you will be editing from now on. This xcworkspace will have your Xcode project along with the Pods that were installed.

![firebase project part 1](Assets/screenshot11.png)

## 12. Dependencies for Firebase installed 

![firebase project part 1](Assets/screenshot12.png)

## 13. Initialize Firebase into your Xcode project

Open your xcworkspace and Edit the AppDelegate as pictured below: 

![firebase project part 1](Assets/screenshot13.png)

## 14. App is verified from Firebase servers as being now connected

To verify all went well with the Firebase integration, delete the app and re-run it after adding Firebase configuration in the AppDelegate, wait a few moments for the Firebase server to detect the connection. If all went well you will receieve the verification banner below. Congratulations. 🥳

![firebase project part 1](Assets/screenshot14.png)


## Resources 

1. [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
2. [Firebase](https://firebase.google.com/) 
3. [Firebase Console](https://console.firebase.google.com/u/0/)
4. [Firebase Authentication](https://firebase.google.com/docs/auth)
5. [Firebase Firestore](https://firebase.google.com/docs/firestore)
6. [Firebase Storage](https://firebase.google.com/docs/storage)
7. [What is Firebase?](https://howtofirebase.com/what-is-firebase-fcb8614ba442)



