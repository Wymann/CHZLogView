# CHZLogView
Print and view logs on your APP easily. 一行代码输出日志到App上。

## Installing
CHZLogView can be installed using [CocoaPods](https://cocoapods.org/).

If you haven't done so already, you might want to initialize the project, to have it produce a `Podfile` template for you:

```
$ pod init
```

Then, edit the `Podfile`, adding `CHZLogView`:

```ruby
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MyAppName' do
    pod 'CHZLogView'
end
```

Then install the pods:

```
$ pod install
```

Then open the `.xcworkspace` rather than the `.xcodeproj`.

For more information on Cocoapods visit https://cocoapods.org.

## How to use

Import header file
```
#import <CHZLogView.h>
```
Method
```
APPLogWithFormat(@".....:%@", string);
```

## Gestures Tips
1. Show or hide LogView by clicking floating button.
2. Touch-hold floating button to close CHZLogView.
3. You can drag floating button to its right place.
4. Double-clicking on the LogView can clear all logs.

## Screenshot
![image](https://github.com/Wymann/CHZLogView/blob/master/Screenshot/1.PNG)
![image](https://github.com/Wymann/CHZLogView/blob/master/Screenshot/2.PNG)
![image](https://github.com/Wymann/CHZLogView/blob/master/Screenshot/3.PNG)
![image](https://github.com/Wymann/CHZLogView/blob/master/Screenshot/4.PNG)
