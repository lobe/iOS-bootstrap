# Files in iOS Bootstrap

This project adheres to [MVVM architecture](https://www.raywenderlich.com/34-design-patterns-by-tutorials-mvvm). MVVM is a design pattern which organizes objects by model, view model, and view.

![Code Diagram](https://github.com/lobe/iOS-bootstrap/raw/master/Assets/codeDiagram.png)

*Arrows designate subscriptions in their pointed direction, i.e `PlayViewModel` subscribes to `PredictionLayer`.*

## View
View files define the look-and-feel of the app. This starter project defines a `PlayView` superview which imports all other view objects. Please consult the README in the [`/Views`](https://github.com/lobe/iOS-bootstrap/tree/master/Lobe_iOS/Views) folder for more information.

## View Model
[`PlayViewModel`](https://github.com/lobe/iOS-bootstrap/tree/master/Lobe_iOS/PlayViewModel.swift) is the view model which publishes data to the `PlayView` view. View models act as important intermediaries between the view and model by de-coupling business logic from views and by subscribing to changes from the model.

`PlayViewModel` publishes changes to the view by subscribing to the following events:
1. New images (either from video capture or image preview) will trigger a prediction request.
2. Responses to prediction requests update the UI to display the prediction result.
3. Switching to `ImagePreview` mode (which uses prediction on a chosen image from the device's library) will tear-down the video capture session manager.

## Model
The model layer handles all data processing in the app, publishing results to any subscribers. In this case, `PlayViewModel` is the only subscriber to model objects, which are:
- [`CaptureSessionManager`](https://github.com/lobe/iOS-bootstrap/tree/master/Lobe_iOS/Models/CaptureSessionManager.swift): publishes select frames from the video capture feed.
- [`PredictionLayer`](https://github.com/lobe/iOS-bootstrap/tree/master/Lobe_iOS/Models/PredictionLayer.swift): uses the imported Core ML model to publish the results from prediction requests.
- [`Project`](https://github.com/lobe/iOS-bootstrap/tree/master/Lobe_iOS/Models/Project.swift): a struct for managing Core ML models.

## Other Files
[`CaptureSessionViewController`](https://github.com/lobe/iOS-bootstrap/tree/master/Lobe_iOS/CaptureSessionViewController.swift) is an exception to the MVVM rule. Although we leverage the SwiftUI library whenever possible, we still need the older UIKit library for select purposes relating to video capture handling.

Thankfully, [we can integrate UIKit easily into SwiftUI](https://developer.apple.com/tutorials/swiftui/interfacing-with-uikit) with `UIViewControllerRepresentable`, a struct that manages view controllers directly in a SwiftUI view. In our app, [`CameraView`](https://github.com/lobe/iOS-bootstrap/tree/master/Lobe_iOS/Views/CameraView.swift) is a `UIViewControllerRepresentable` which creates `CaptureSessionViewController`. This view controller is responsible for:
1. Setting the view frame to the video feed.
2. Handling device orientation changes, ensuring the video feed is correctly oriented.
3. Managing tap gestures. UIKit handles conflicts between multiple tap gesture handlers better than SwiftUI, at the time of this writing. [Click here](https://github.com/lobe/iOS-bootstrap#in-app-gestures) to read more about tap-gestures in iOS-bootstrap.

## Useful Links

For further reading and guidance for Swift best practices:
- [Ray Wenderlich](https://www.raywenderlich.com/4161005-mvvm-with-combine-tutorial-for-ios) has a great tutorial showcasing MVVM with the [Combine](https://developer.apple.com/documentation/combine) library, which is used to define publishers and subscribers between MVVM layers. We use Combine a lot in the view model and model layers.
- [Design+Code](https://designcode.io/swi\ftui2-course) has in-depth material for creating a Swift app in iOS 14.
