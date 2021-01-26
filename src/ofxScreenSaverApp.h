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

class ofxScreenSaverApp : public ofBaseApp{

public:

	//if you implement an ofxScreenSaverApp, you must be able to provide valid settings for your window
	virtual void setupWindowSettings(ofxScreenSaverWindowSettings & set, bool isPreviewWindow, const ofRectangle & r) = 0;

	virtual bool hasConfigureSheet(){return false;};

protected:

};

