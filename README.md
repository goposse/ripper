<p/>
<p align="center">
<img src="https://raw.githubusercontent.com/goposse/ripper/assets/ripper_logo.png" align="center" width="460">
</p>
<br/>
> <b>Ripper</b> : great, fantastic - "that is a ripper of an image downloader"<br/>
> <b>Ripper, you little!</b> : Exclamation of delight or as a reaction to good news<br/>


Ripper is an image download library written in Swift for iOS. It is simple, easy to use, and doesn't come stuffed with things you don't need.

[![CocoaPods](https://img.shields.io/cocoapods/v/Ripper.svg?style=flat-square)](#)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Ripper.svg?style=flat-square)](#)


# Features

- Full featured, but none of the bloat
- Easy to understand, Builder(ish)-based architecture
- Download directly to a `UIImageView`, block, or both (so you can edit it before it ends up in your View)
- On-the-fly global image resizing (other operations to come)
- Image filters (global and operation-scoped)
- Built in image caching
- Powered by [Haitch](http://github.com/goposse/haitch)


# Installation

## CocoaPods

Add the following line to your `Podfile`:

`pod 'Ripper', '~> 0.7'`

Then run `pod update` or `pod install` (if starting from scratch).

## Carthage

Add the following line to your `Cartfile`:

`github "goposse/ripper" ~> 0.7`

Run `carthage update` and then follow the installation instructions [here](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).


# The basics

Loading an image from a url into a `UIImageView` with a placeholder image is as easy as:

```swift
  Ripper.downloader
    .load("http://somedomain.com/image.png")
    .placeholder(UIImage(named: "my_placeholder"))
    .into(myImageView)
```

If you want more control over the process you can simply execute the load request and do what you like with it:

```swift
Ripper.downloader
  .load("http://somedomain.com/image.png")
  .execute { (image, error) -> Void in
    // do something with the image or handle error
    // NOTE: this block will execute on main thread  
  }
```


# FAQ

## I wish it did ___ (or I found a bug)!

Please log an issue in Github and we'll get back to you ASAP!

## Why should I use this?

It's up to you. There are other fantastic frameworks out there but, in our experience, we only need a small subset of the things they do. The goal of Ripper was to do one thing and one thing well. Not to deal with the possibility of "what if?". As we add new things to the library, we intend to work very hard to stay true to this one principle.

## Has it been tested in production? Can I use it in production?

The code here has been written based on Posse's experiences with clients of all sizes. It has been production tested. That said, this incarnation of the code is our own. It's fresh. We plan to use it in production and we plan to keep on improving it. If you find a bug, let us know!

## Who the f*ck is Posse?

We're the best friggin mobile shop in NYC that's who. Hey, but we're biased. Our stuff is at [http://goposse.com](http://goposse.com). Go check it out.

# Outro

## Credits

Ripper is sponsored, owned and maintained by [Posse Productions LLC](http://goposse.com). Follow us on Twitter [@goposse](https://twitter.com/goposse). Feel free to reach out with suggestions, ideas or to say hey.

### Security

If you believe you have identified a serious security vulnerability or issue with Ripper, please report it as soon as possible to apps@goposse.com. Please refrain from posting it to the public issue tracker so that we have a chance to address it and notify everyone accordingly.

## License

Ripper is released under a modified MIT license. See LICENSE for details.
