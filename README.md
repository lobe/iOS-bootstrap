<div style="text-align:center"><img src="https://github.com/lobe/iOS-bootstrap/raw/master/assets/header.png" /></div>

[Lobe](http://lobe.ai/) is an easy to use free tool to help you start working with machine learning.

This project was created to help you bootstrap your Lobe project on the iOS. Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/) for Apple's iOS and iPadOS platforms.

## Table of contents

In the next few sections we’ll take you through the basics of creating your new project and getting started. At a high level, we’ll go over:

1. [Installing your Development Environment](https://github.com/lobe/iOS-bootstrap/tree/master#installing-your-development-environment)
2. [Exporting your model from Lobe and integrating it into the code](https://github.com/lobe/iOS-bootstrap/blob/master/README.md#exporting-your-model)
3. [Deploying your app to the web](https://github.com/lobe/iOS-bootstrap/tree/master#deploying-your-app)
4. [Tips and Tricks for creating your own custom version of this app](https://github.com/lobe/iOS-bootstrap/tree/master#tips-and-tricks)
5. [Contributing](https://github.com/lobe/iOS-bootstrap/tree/master#contributing)

## Installing Your Development Environment

In this stage we’re going to get your setup so you can launch and play with your app. These instructions are written for macOS, the only system you can run iOS app on. To start, we’re going to download this repository. To do this, we need to install a few things.

### Step 1 – Install [Homebrew](http://brew.sh/)

First, [open a terminal window](http//www.youtube.com/watch?v=zw7Nd67_aFw).

Next, copy & paste the following into a terminal window and hit return.

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew doctor
```

You will be offered to install the *Command Line Developer Tools* from *Apple*. Confirm by clicking *Install*. After the installation finished, continue installing *Homebrew* by hitting return again.

### Step 2 – Installing [Git](https://git-scm.com)

Feel free to skip second step if you already have git installed, or if you'd perfer to use the [GitHub Desktop](https://desktop.github.com) app. Otherwise, Copy & paste the following into the terminal window and hit return.

```shell
brew install git
```

Now that we git installed, you can clone this repo with the following command. You'll want to navigate to a folder in terminal where you'd like to store these files. If you need help, here's a [gentle introduction to navigation in the terminal](https://computers.tutsplus.com/tutorials/navigating-the-terminal-a-gentle-introduction--mac-3855).

```shell
git clone https://github.com/lobe/iOS-bootstrap.git
```

### Step 3 - Installing [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12)

Next, we're going to install [Xcode from the App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12). This will be a fairly strightforward process that'll take about an hour as the Xcode app is pretty large. 

<div style="text-align:center"><img src="https://github.com/lobe/iOS-bootstrap/raw/master/assets/xcodeDownload.png" /></div>

Once it's done, just double click on the `Lobe_iOS.xcodeproj` file and it'll open in Xcode! Now we need to export your custom model from Lobe. If you'd like, you and skip to the deploying you app section if you just want to see that app working with the sample model.

## Exporting your model

Next, we're going to drop in your new model. So first, let's open your project in Lobe and export it by pressing `⌘-E` and selecting CoreML:

![](https://github.com/lobe/iOS-bootstrap/raw/master/assets/exportHeader.png)

Once you have the CoreML model, rename it to `LobeModel.mlmodel` and drag it into the root of this repo to replace the exisiting sample model:

![](https://github.com/lobe/iOS-bootstrap/raw/master/assets/modeldrag.png)

And we're done! Next let's get it on your phone so you can see it work live


## Deploying your app

Next, we'll want to get this app onto your phone so you can see it working live with your device's camera. To do this, plug in your device via a USB-Lighting cabel and in the open xcode window, press the play button in the top left hard corner of the screen:

<div style="text-align:center"><img src="https://github.com/lobe/iOS-bootstrap/raw/master/assets/Xcode%20Play%20Button.png" /></div>

And there you have it! You're app should be running on your device. If xcode pops up a message asking you to setup your team, just follow the steps it suggests or [take a look here](https://stackoverflow.com/questions/40475094/how-to-specify-development-team-in-xcode#40476567). And finally, if you'd like to post this app to the App Store, you're more then welcome to. To do so, [follow the instrustions here](https://developer.apple.com/app-store/submitting/) to get the process rolling. You'll need to have an Apple Developer account.

## Tips and Tricks

You're more the welcome to use this app as a starting place for your own project. Below is a high level overview of the project to get you started. Like any good bootstrap app, this project has been kept intentionally simple. There are only two main components in two files, `ContentView.swift` and `MyViewController.swift`.

### `ContentView.swift`
This file contains all the main UI, built using SwiftUI. If you'd like to adjust the plactment of any UI elements or add you own, start here. If you'd like a primer on SwiftUI, I'd start with this: [Build a SwiftUI app for iOS 14](https://designcode.io/swiftui2-course)

### `MyViewController.swift`
This file contains all parts that needed to be done using the old style UIKit. Mainly this is making the camera view. Luckily, this is all ported back to SwiftUI using Apple's `UIViewControllerRepresentable` API. This allows us to make the camera view, and the use it like any other SwiftUI view above. Because this deals with the camera, you'll also see the CoreML prediction call here.

### Miscellaneous Pointers
* This project contains a sample icon and other assets, feel free to use these or create your own.
* When you're using the app, swiping up on the screen pulls open the image picker.
* Double tapping flips the camera around to the front facing camera. Double tapping again filps the camera back to the front.

## Contributing

If you can think of anything you'd like to add, or bugs you find, please reach out! PRs will be openly accepted (if they keep project simple, bonus points for making it even simplier) and issues will be triaged.

We look forward to seeing the awesome projects you put out there into the world! Cheers!

– The Lobe Team
