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


## Notes 
To turn a "normal" OF Xcode project to turn it into a ScreenSaver project:

* Before opening project in xcode, manually edit the project.pbxprj inside your *.xcodeproj file with a text editor.  
Search for "productType" and replace "com.apple.product-type.application" with "com.apple.product-type.bundle".
* Project Target > Build Settings: change "WRAPPER_EXTENSION" from "app" to "saver"
* Make sure the info.plist file contains:
  * "Principal Class" : ${SCREEN_SAVER_PRINCIPAL_CLASS}
  * Bundle OS Type Code: "BNDL"
  * Bundle Identifier: $(PRODUCT_BUNDLE_IDENTIFIER)
* Make sure the info.plist does NOT contain any "privacy" entries (allow camera & mic access)
* Remove src for main.cpp
* Make sure your project settings set CLANG_ENABLE_MODULES "(Enable Modules (C and Objective-C)" to NO

* Make sure PreProcessor Macros are in effect (delete override)
* Edit "Compile OF" Run Script to look like this

```
# Note that this builds OF with NO FMOD to avoid dylibs.
# Note that this means your ScreenSaver can't play sounds through ofSound
xcodebuild -project "${OF_PATH}/libs/openFrameworksCompiled/project/osx/openFrameworksLib.xcodeproj" -target openFrameworks -configuration "Release" OTHER_CFLAGS="-DUSE_FMOD=false" OTHER_CPLUSPLUSFLAGS="-DUSE_FMOD=false" 

```
* Add a new "Copy Bundle Resources" build phase, and make sure it includes the "ConfigureSheet.nib" file.
* Remove the existing "Run Script" build phase that handles codesign, fmod, etc.
* Add a new "Run Script" build phase, paste this:

```
mkdir -p "$TARGET_BUILD_DIR/$PRODUCT_NAME.saver/Contents/Resources/"
# Copy bin/data into App/Resources
rsync -avz --exclude='.DS_Store' "${SRCROOT}/bin/data/" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data/"

```

*Note that you can also just add a new target choosing "screen saver" to your existing standard OF project, just apply these steps will apply to this new target.*
