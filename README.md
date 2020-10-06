<div style="text-align:center"><img src="https://github.com/lobe/iOS-bootstrap/raw/newReadme/assets/header.png" /></div>

[Lobe](http://lobe.ai/) is an easy-to-use free tool to help you start working with machine learning.

This project was created to help you bootstrap your Lobe project on iOS. Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/) for Apple's iOS and iPadOS platforms.

## Table of contents

In the next few sections we’ll take you through the basics of creating your new project and getting started. At a high level, we’ll go over:

1. [Installing your Development Environment](#installing-your-development-environment)
2. [Exporting your model from Lobe and integrating it into the code](#exporting-your-model)
3. [Deploying your app on your device](#deploying-your-app)
4. [Tips and Tricks for creating your own custom version of this app](#tips-and-tricks)
5. [Contributing](#contributing)

## Installing Your Development Environment

In this stage we’re going to get you setup so you can build, launch, and play with your app. These instructions are written for macOS, the only system you can develop iOS apps on.

To start, we’re going to download ("clone") this repository.

If you already have `git` installed and know how to clone this repo, skip to [Step 2](#step-2---installing-xcode).

If you prefer to use the [GitHub Desktop](https://desktop.github.com) app, click on the "Code" button above and click "Open with GitHub Desktop":

![](https://github.com/lobe/iOS-bootstrap/raw/newReadme/assets/downloadProject.png)

Otherwise, we need to install a few things:

### Step 1 – Install [Homebrew](http://brew.sh/) and [Git](https://git-scm.com)

First, [open a Terminal window](http//www.youtube.com/watch?v=zw7Nd67_aFw).

Next, copy & paste the following into a Terminal window and hit return.

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/newReadme/install.sh)"
brew doctor
brew install git
```

Now that we have installed `git`, you can clone this repo with the following command. You'll want to navigate to a folder in Terminal where you'd like to store these files. If you need help, here's a [gentle introduction to navigation in the terminal](http//www.youtube.com/watch?v=zw7Nd67_aFw).

```shell
git clone https://github.com/lobe/iOS-bootstrap.git
```

### Step 2 - Installing [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12)

Next, we're going to install Xcode, a free tool from Apple, via the [App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12). This is a fairly straightforward process that could take an hour or more, as the Xcode app is pretty large.

![Screenshot of XCode installation](https://github.com/lobe/iOS-bootstrap/raw/newReadme/assets/xcodeDownload.png)

Once it's done, double click on the `Lobe_iOS.xcodeproj` file in your project directory and it'll open in Xcode!

Now we need to export your custom model from Lobe. If you'd like, you can skip to the [deploying your app](#deploying-your-app) section if you just want to see this app working with the default sample model.

## Exporting your model

Once you've trained a custom model in Lobe, you can drop it into your app.

First, let's open your project in Lobe and export it by pressing `⌘E` and selecting CoreML.

Once you have the CoreML model, rename it to `LobeModel.mlmodel` and drag it into the root of this repo to replace the exisiting sample model:

![Illustration of Finder](https://github.com/lobe/iOS-bootstrap/raw/newReadme/assets/modeldrag.png)

And we're done! Next let's get it on your phone so you can see it work live.

## Deploying your app

Next, we'll want to get this app onto your phone so you can see it working live with your device's camera. To do this, plug in your device via a USB-Lightning cable and, in the open Xcode window, press the play button in the top left corner of the window:

![Screenshot of Xcode](https://github.com/lobe/iOS-bootstrap/raw/newReadme/assets/Xcode%20Play%20Button.png)

And there you have it! You're app should be running on your device. If Xcode pops up a message asking you to setup your team, just follow the steps it suggests or [take a look here](https://stackoverflow.com/questions/40475094/how-to-specify-development-team-in-xcode#40476567).

<p align="center">
  <img height='200px' src="https://github.com/lobe/iOS-bootstrap/raw/newReadme/assets/iphone-video.gif" alt="video"/>
</p>

And finally, if you'd like to post your app (running your custom image classification model) to the App Store, you're more than welcome to do so. [Follow the instructions here](https://developer.apple.com/app-store/submitting/) to get the process rolling. You'll need to have an Apple Developer account.

## Tips and Tricks

This app is meant as a starting place for your own project. Below is a high level overview of the project to get you started. Like any good bootstrap app, this project has been kept intentionally simple. There are only two main components in two files, `ContentView.swift` and `MyViewController.swift`.

### `ContentView.swift`

This file contains all the main UI, built using SwiftUI. If you'd like to adjust the placement of any UI elements or add you own, start here. If you'd like a primer on SwiftUI, start with this: [Build a SwiftUI app for iOS 14](https://designcode.io/swiftui2-course)

### `MyViewController.swift`

This file contains all parts that needed to be done using the old style UIKit. Mainly this is making the camera view. Luckily, this is all ported back to SwiftUI using Apple's `UIViewControllerRepresentable` API. This allows us to make the camera view, and then use it like any other SwiftUI view above. You'll also see the CoreML prediction call here.

### `UpdateTextViewExternal.swift`

Includes the small amount of SwiftUI for the prediction bar at the bottom of the screen.

### Miscellaneous Pointers

- This project contains a sample icon and other assets, feel free to use these or create your own.
- When you're using the app, swiping up on the screen pulls open the image picker.
- Double tapping flips the camera around to the front facing camera. Double tapping again flips the camera back to the front.

## Contributing

If you can think of anything you'd like to add, or bugs you find, please reach out! PRs will be openly accepted (if they keep project simple, bonus points for making it even simplier) and issues will be triaged.

We look forward to seeing the awesome projects you put out there into the world! Cheers!

– The Lobe Team
