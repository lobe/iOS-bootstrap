<div style="text-align:center"><img src="https://github.com/lobe/iOS-bootstrap/raw/master/assets/header.png" /></div>

[Lobe](http://lobe.ai/) is an easy to use app that has everything you need to bring your machine learning ideas to life. Just show it some examples of what you want it to do, and train a custom machine learning model that can be shipped in your app.

iOS Bootstrap takes the machine learning model created in Lobe, and adds it to a project on iOS that uses CoreML and [SwiftUI](https://developer.apple.com/xcode/swiftui/). We help you along the way with everything you need to do to integrate it in your project.

<br />

## Installing Your Development Environment

You need to get you setup so you can build, launch, and play with your app. These instructions are written for macOS, the only system you can develop iOS apps on.

If you already have `git` installed and know how to clone this repo, skip to [Step 2](#step-2---installing-xcode).

If you prefer to use the [GitHub Desktop](https://desktop.github.com) app, click on the "Code" button above and click "Open with GitHub Desktop":

![](https://github.com/lobe/iOS-bootstrap/raw/master/assets/downloadProject.png)

### Step 1 – Install [Homebrew](http://brew.sh/) and [Git](https://git-scm.com)

Type the following into a Terminal window:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew doctor
brew install git
```

Now that we have installed `git`, you can clone this repo with the following command. You'll want to navigate to a folder in Terminal where you'd like to store these files. If you need help, here's a [gentle introduction to navigation in the terminal](http//www.youtube.com/watch?v=zw7Nd67_aFw).

```shell
git clone https://github.com/lobe/iOS-bootstrap.git
```

### Step 2 - Installing [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12)

Next, we're going to install Xcode, a free tool from Apple, via the [App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12). This is a fairly straightforward process that could take an hour or more, as the Xcode app is pretty large.

![Screenshot of XCode installation](https://github.com/lobe/iOS-bootstrap/raw/master/assets/xcodeDownload.png)

Once it's done, double click on the `Lobe_iOS.xcodeproj` file in your project directory and it'll open in Xcode!

Now we need to export your custom model from Lobe. If you'd like, you can skip to the [deploying your app](#deploying-your-app) section if you just want to see this app working with the default sample model.

<br />

### Step 3 - Exporting your model

After your machine learning is done training, and you are getting good results, you can export your model by going into the file menu and clicking export. Lobe supports a bunch of industry standard platforms. For this project, we'll select CoreML, the standard for Apple's platforms.

Once you have the CoreML model, rename it to `LobeModel.mlmodel` and drag it into the root of this repo to replace the exisiting sample model:

![Illustration of Finder](https://github.com/lobe/iOS-bootstrap/raw/master/assets/modeldrag.png)

<br />

## Step 4 - Deploying your app

Next, we'll want to get this app onto your phone so you can see it working live with your device's camera. To do this, plug in your device via a USB-Lightning cable and, in the open Xcode window, press the play button in the top left corner of the window:

![Screenshot of Xcode](https://github.com/lobe/iOS-bootstrap/raw/master/assets/Xcode%20Play%20Button.png)

And there you have it! You're app should be running on your device. If Xcode pops up a message asking you to setup your team, just follow the steps it suggests or [take a look here](https://stackoverflow.com/questions/40475094/how-to-specify-development-team-in-xcode#40476567).

<p align="center">
  <img height='500px' src="https://github.com/lobe/iOS-bootstrap/raw/master/assets/iphone-video.gif" alt="video"/>
</p>

And finally, if you'd like to post your app (running your custom image classification model) to the App Store, you're more than welcome to do so. [Follow the instructions here](https://developer.apple.com/app-store/submitting/) to get the process rolling. You'll need to have an Apple Developer account.

<br />

## Tips and Tricks

This app is meant as a starting place for your own project. Below is a high level overview of the project to get you started. Like any good bootstrap app, this project has been kept intentionally simple. There are only two main components in two files, `ContentView.swift` and `MyViewController.swift`.

#### `ContentView.swift`

This file contains all the main UI, built using SwiftUI. If you'd like to adjust the placement of any UI elements or add you own, start here. If you'd like a primer on SwiftUI, start with this: [Build a SwiftUI app for iOS 14](https://designcode.io/swiftui2-course)

#### `MyViewController.swift`

This file contains all parts that needed to be done using the old style UIKit. Mainly this is making the camera view. Luckily, this is all ported back to SwiftUI using Apple's `UIViewControllerRepresentable` API. This allows us to make the camera view, and then use it like any other SwiftUI view above. You'll also see the CoreML prediction call here.

#### `UpdateTextViewExternal.swift`

Includes the small amount of SwiftUI for the prediction bar at the bottom of the screen.

#### Miscellaneous Pointers

- This project contains a sample icon and other assets, feel free to use these or create your own.
- When you're using the app, swiping up on the screen pulls open the image picker.
- Double tapping flips the camera around to the front facing camera. Double tapping again flips the camera back to the front.

<br />

## Contributing

If you can think of anything you'd like to add, or bugs you find, please reach out! PRs will be openly accepted (if they keep project simple, bonus points for making it even simplier) and issues will be triaged.

For project ideas or feedback, please visit our community on [Reddit](https://www.reddit.com/r/Lobe/)! /(Placeholder wording, maybe a grafic and more inviting language)/

We look forward to seeing the awesome projects you put out there into the world! Cheers!

![team sig](https://github.com/lobe/iOS-bootstrap/raw/master/assets/lobeteam.png)
