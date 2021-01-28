#pragma once

#include "ofMain.h"
#ifdef OF_SCREEN_SAVER
	#include "ofxScreenSaverApp.h"
	#include "ofxScreenSaverParameters.h"
#endif

#ifdef OF_SCREEN_SAVER
class ofApp : public ofxScreenSaverApp{
#else
class ofApp : public ofBaseApp{
#endif

	public:

		~ofApp();

		void setup();
		void update();
		void draw();
		
		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y);
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void mouseEntered(int x, int y);
		void mouseExited(int x, int y);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);

		#ifdef OF_SCREEN_SAVER

		//in here you need to provide the params that you added to the ConfigureSheet.NIB
		void setupParameters();

		//this will be called before your app starts so you can setup a few things - similar to main.cpp
		void supplyWindowSettings(ofxScreenSaverWindowSettings & set, bool isPreviewWindow);
		void viewCreated(bool isPreviewWindow, const ofRectangle & r, float uiscale);
		bool hasConfigureSheet(); //return true if your ssaver has preferences and you want to edit your ConfigureSheet.nib
		#endif

		ofRectangle myRect;
		bool isPreview = false;
		float myUiScale = 0.0;

		ofTexture tex;


};
