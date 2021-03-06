<h1> Bluu</h1>

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/8ee9da023d7d45b7a488166be52b53e3)](https://app.codacy.com/manual/CocoGinger/bluu?utm_source=github.com&utm_medium=referral&utm_content=CocoGinger/bluu&utm_campaign=Badge_Grade_Settings)
[![GitHub issues](https://img.shields.io/github/issues/CocoGinger/bluu?style=flat)](https://github.com/CocoGinger/bluu/issues)
[![GitHub forks](https://img.shields.io/github/forks/CocoGinger/bluu)](https://github.com/CocoGinger/bluu/network)
[![GitHub stars](https://img.shields.io/github/stars/CocoGinger/bluu)](https://github.com/CocoGinger/bluu/stargazers)
[![Twitter](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Fgithub.com%2FCocoGinger%2Fbluu)](https://twitter.com/intent/tweet?text=Flutter%Fully%Functional%Messenger&url=https%3A%2F%2Fgithub.com%2FCocoGinger%2Fbluu)
[![GitHub license](https://img.shields.io/github/license/CocoGinger/bluu?style=flat)](https://github.com/CocoGinger/bluu/blob/master/LICENSE)



## Description

A Flutter Chat Application, using Firebase for Google Sign In/Sign Up, exchange texts, emojis, and images. Integrated Agora Sdk for communicating over video calls. A little tweaking to communicate over voice calls only.

## Get Started

*   Clone this repo
*   Run `flutter packages get`
*   Run `flutter run` (remember to open simulator or connect physical device, iOS auto run additional command `pod install`)

## Setup

Connect the app to your Firebase Project from your [Firebase Console](http://console.firebase.google.com) and add the `google-services.json` in the `/android/app` directory.

Inside `/lib` directory make a new directory `/configs`, where you'll need to make two new files `agora_configs.dart` and `firebase_configs.dart`.

Inside `agora_configs.dart` add:

  `const APP_ID = '<YOUR_AGORA_SDK_TOKEN>';` from your [Agora.io](https://console.agora.io).

Inside `firebase_configs.dart` add: 
  
  `const SERVER_KEY = '<YOUR_FIREBASE_SERVER_KEY>';` from your [Firebase Console](http://console.firebase.google.com).

## bluu UI



## TODO

*   Integrate Facebook Sign in and Sign up.
*   Enable Group Chats.
*   Enable Group Calls.


## LICENSE

<p>
<b>MIT License</b>

Copyright (c) 2020 Bryan Bill

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
</p>
