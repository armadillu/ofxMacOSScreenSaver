# ofxMacOSScreenSaver

Easily turn any OF project into an OSX screen saver.
This is a horrible Frankenstein mess that started from code scavanged from OF forums & Nick Hardeman's blog posts. OF changed a lot from then, so I am having to rewrite most of it.

So far I have multi-screen and retina support working, but it needs a proper interface for easy integration.

Note that this is not currently setup to place your project inside the OpenFrameworks/apps folder, but outside the OpenFrameworks folder. All the magic happens in the `ScreenSaverOF.xcconfig` file.

Also very important steps in the Xcode Project "Build Phases".

When testing / developing, it is useful to launch SystemPreferences from the command line using a Terminal app to get console output:

```
$ /Applications/System\ Preferences.app/Contents/MacOS/System\ Preferences; 
```

Also if you run on an old enough version of MacOS you can still run [SaverLab](https://www.macintoshrepository.org/16641-saverlab) which makes the quick iteration process less painful. It seems it's no longer being developed but maybe theres a fork somewhere running on newer systems.

Very much a WIP!

# Distribution 

For the ssaver to run on other computers on recent versions of Mac OS, you will need to codesign and notarize it. This [guide](http://www.cannonade.net/blog.php?id=1872) worked fine for me.

## Forum discussions
* http://forum.openframeworks.cc/t/screen-saver/1709
* http://forum.openframeworks.cc/t/arnold-screen-saver/9271

## Related notes
* http://nickhardeman.com/506/stand-alone-application-in-openframeworks/


##LICENSE
ofxMacOSScreenSaver is made available under the [MIT](http://opensource.org/licenses/MIT) license.
