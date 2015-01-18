# LDStickerView
LDStickerView a custome UIView that can resize, rotate, move, remove by single touch. It was wrote by Swift programming language.
## Features
Do all actions just one finger
* Resize View
* Rotate & Resize View
* Delete View

## How to use
```swift
override func viewDidLoad() {
super.viewDidLoad()
// Do any additional setup after loading the view, typically from a nib.
var imageView: UIImageView = UIImageView(image: UIImage(named: "cu-meo.png"))
imageView.contentMode = UIViewContentMode.ScaleAspectFill
var stickerView: LDStickerView = LDStickerView(frame: CGRectMake(10, 10, imageView.frame.size.width, imageView.frame.size.height))
stickerView.setContentView(imageView)
view.addSubview(stickerView)
}
```
