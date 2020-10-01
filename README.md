<div style="text-align:center"><img src="https://github.com/lobe/iOS-bootstrap/raw/nicerDevExperience/assets/header.png" /></div>

[Lobe](http://lobe.ai/) is an easy to use free tool to help you start working with machine learning.

This project was created to help you bootstrap your Lobe project on the iOS. Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/) for Apple's iOS and iPadOS platforms.

## Table of contents

In the next few sections we’ll take you through the basics of creating your new project and getting started. At a high level, we’ll go over:

1. [Installing your Development Environment](https://github.com/lobe/iOS-bootstrap/tree/nicerDevExperience#installing-your-development-environment)
2. [Exporting your model from Lobe and integrating it into the code](https://github.com/lobe/iOS-bootstrap/blob/nicerDevExperience/README.md#exporting-your-model)
3. [Deploying your app to the web](https://github.com/lobe/iOS-bootstrap/tree/nicerDevExperience#deploying-your-app)
4. [Tips and Tricks for creating your own custom version of this app](https://github.com/lobe/iOS-bootstrap/tree/nicerDevExperience#tips-and-tricks)
5. [Contributing](https://github.com/lobe/iOS-bootstrap/tree/nicerDevExperience#contributing)

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

<div style="https://github.com/lobe/iOS-bootstrap/raw/nicerDevExperience/assets/xcodeDownload.png" /></div>

Next, we're going to install [Xcode from the App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12). This will be a fairly strightforward process that'll take about an hour as the Xcode app is pretty large. Once it's done, just double click on the `Lobe_iOS.xcodeproj` file and it'll open in Xcode! Now we need to export your custom model from Lobe. If you'd like, you and skip to the deploying you app section if you just want to see that app working with the sample model.

## Exporting your model

Next, we're going to drop in your new model. So first, let's open your project in Lobe and export it by pressing `⌘-E` and selecting CoreML:

![](https://github.com/lobe/iOS-bootstrap/raw/nicerDevExperience/assets/exportHeader.png)

Once you have the CoreML model, rename it to `LobeModel.mlmodel` and drag it into the root of this repo to replace the exisiting sample model:

![](https://github.com/lobe/iOS-bootstrap/raw/nicerDevExperience/assets/modeldrag.png)

And we're done! Next let's get it on your phone so you can see it work live


## Deploying your app

Luckily for us, deploying on the web is much easier then on iOS or Android. You can deploy to a varitiy of cloud services, such as AWS, GCP, or Azure. One of the best choices is using GitHub pages: it's free and will give you a URL (`yourproject.github.io`) for you to use and share around the web. Because this is using tensorflow.js, all the inference is done client side, so using your app should remain fast for all users, regardness of how many there are! We recomend [this guide](https://github.com/gitname/react-gh-pages) that will take you through the steps.

## Tips and Tricks

You're more the welcome to use this app as a starting place for your own project. Below is a high level overview of the project to get you started. Like any good bootstrap app, this project has been kept intentionally simple. There are only two main components, the Camera, and the Prediction.

### `Camera.js`
The Camera is resonsible for displaying a live full screen view of the user's webcam. It can easily be modified to take input from any camera attached to your computer, so could hook this up to your sub telescope and use that!

### `Prediction.js`
Our Prediction component is the box in the lower left hand corner. It's responsible for displaying the prediction results and their confidences.

### Miscellaneous Pointers
* There's a config file in `/src` that has various config options for the app. 
* The prediction happens at a set interval (500ms), while the camera is kept showing a live feed regardless of the prediction frequency.
* The shared css in the `App.css`
* All the code is commented, this should help you explore and configure to create your own version

## Contributing

If you can think of anything you'd like to add, or bugs you find, please reach out! PRs will be openly accepted (if they keep project simple, bonus points for making it even simplier) and issues will be triaged.

We look forward to seeing the awesome projects you put out there into the world! Cheers!

– The Lobe Team
