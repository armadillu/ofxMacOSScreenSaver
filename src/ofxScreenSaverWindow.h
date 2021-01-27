//
//  ofxScreenSaverWindow.h
//  ofxScreenSaver
//
//  Created by Nick Hardeman on 1/24/14.
//
//

#pragma once

#include "ofConstants.h"
#include "ofAppBaseWindow.h"

#if defined(__OBJC__)
#import <Cocoa/Cocoa.h>
#else
typedef void* id;
#endif

class ofBaseApp;

class ofBaseApp;
class ofCoreEvents;
class ofPath;
class of3dGraphics;
class ofBaseRenderer;
class ofxScreenSaverGLView;

///////////////////////////////////////////////////////////////////////////////

class ofxScreenSaverWindowSettings: public ofGLWindowSettings{
friend class ofxScreenSaverWindow;
public:
	ofxScreenSaverWindowSettings(bool wantsRetina){ retina = wantsRetina;}

	ofxScreenSaverWindowSettings(const ofGLWindowSettings & settings)
	:ofGLWindowSettings(settings){}

	int numSamples = 4;
	int depthBits = 24;
	int stencilBits = 0;
	int alphaBits = 8;
private:
	bool retina = false;
};


/////////////////////////////////////////////////////////////////////////////////


class ofxScreenSaverWindow : public ofAppBaseGLWindow {

public:

	ofxScreenSaverWindow();
	~ofxScreenSaverWindow();

	static bool doesLoop(){ return false; }
	static bool allowsMultiWindow(){ return true; }
	static void loop(){};
	static bool needsPolling(){ return false; }
	static void pollEvents(){};

	static void exitApp();
	
	void setup(const ofGLWindowSettings & settings);
	void setup(const ofxScreenSaverWindowSettings & settings, id ssView);

	void update();
	void draw();

	void close();

	void enableSetupScreen();
	void disableSetupScreen();

	glm::vec2 getWindowPosition();
	glm::vec2 getWindowSize();
	glm::vec2 getScreenSize();

	int getWidth();
	int getHeight();

	float getUiScale(){return pixelScreenCoordScale;} //retina : 2;  !retina : 1

	void setVerticalSync(bool enabled);

	ofCoreEvents & events();
	std::shared_ptr<ofBaseRenderer> & renderer();

	id getGlView();

private:

	int width, height;
	bool bEnableSetupScreen = true;

	float pixelScreenCoordScale = 1;
	id glView = nil;
	ofBaseApp *	ofAppPtr;

	std::unique_ptr<ofCoreEvents> coreEvents;
	std::shared_ptr<ofBaseRenderer> currentRenderer;
};
