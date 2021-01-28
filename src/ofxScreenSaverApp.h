//
//  ofxScreenSaverApp.h
//  ScreenSaverOF
//
//  Created by Oriol Ferrer Mesià on 26/01/2021.
//Copyright © 2021 Oriol Ferrer Mesià. All rights reserved.
//

#pragma once
#include "ofMain.h"
#include "ofxScreenSaverWindow.h"

#if defined(__OBJC__)
#import <Cocoa/Cocoa.h>
#else
typedef void* id;
#endif


class ofxScreenSaverApp : public ofBaseApp{

public:

	//if you implement an ofxScreenSaverApp, you must be able to provide valid settings for your window
	void supplyWindowSettings(ofxScreenSaverWindowSettings & set, bool isPreviewWindow);

	//you get notified when the view is up, with some info about it
	void viewCreated(bool isPreviewWindow, const ofRectangle & r, float uiscale);

	virtual bool hasConfigureSheet(){return true;};

protected:

};

