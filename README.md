<!-- <div style="text-align:center"><img src="https://github.com/lobe/iOS-bootstrap/raw/master/Assets/header.jpg" /></div> -->
<div style="text-align:center"><img src="https://github.com/lobe/iOS-bootstrap/raw/master/assets/header.jpg" /></div>
<br>

[Lobe](http://lobe.ai/) is a free, easy to use app that has everything you need to bring your machine learning ideas to life. The iOS starter project takes the machine learning model created in Lobe, and adds it to an iOS project. To get started using the starter project, follow the instructions below:

## Get Started

1. Clone, fork or download the project on your computer and install [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12) to get started. Xcode is the app that's used to run the starter project on your computer or device.

2. When the installation of Xcode is complete, open the `Lobe_iOS.xcodeproj` file. Notice that we've added a sample model called `LobeModel.mlmodel` in the same folder as your starter project. This model recognizes common objects on your desk.

3. To use your own model file, open your Lobe project, go to the Use tab, select Export and click on the Core ML model file. When exported, rename the `.mlmodel` file to `LobeModel.mlmodel` and drag it to the original starter project folder.

4. Head back to Xcode and run the app by clicking on the play button. Consult [the following section](#Running-on-Personal-Device) to run your project directly on your iPhone, otherwise ensure you select a simulator as a target device.

### Running on Personal Device

The following requirements must be met in order to run the Lobe app on your device:

1. **Apple developer account subscription.** You must link your developer account subscription in Xcode under the preferences panel. 

2. **Create a unique bundle identifier.** Create your own unique ID under Targets > General tab > Bundle Identifier in the project settings.

3. **Register device with developer account.** Follow [Apple's docs](https://developer.apple.com/documentation/xcode/distributing_your_app_to_registered_devices) for adding your own device.

## Additional Information

The iOS starter project supports a swipe up gesture to open the image picker, a double tap to toggle between the front and rear camera, and a triple tap to save a screenshot of the app that omits the UI components on top of it.

The project works on iPhones running iOS 13.4 or later. To dive deeper in the code and understand it better, check out our dedicated [guide](https://github.com/lobe/iOS-bootstrap/tree/master/Lobe_iOS).

## Contributing

GitHub Issues are for reporting bugs, discussing features and general feedback on the iOS starter project. Be sure to check our documentation, FAQ and past issues before opening any new ones.

To share your project, get feedback on it, and learn more about Lobe, please visit our community on [Reddit](https://www.reddit.com/r/Lobe/). We look forward to seeing the amazing projects that can be built, when machine learning is made accessible to you.
