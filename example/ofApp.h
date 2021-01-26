#pragma once

#include "ofMain.h"
#ifdef OF_SCREEN_SAVER
	#include "ofxScreenSaverApp.h"
#endif

#ifdef OF_SCREEN_SAVER
class ofApp : public ofxScreenSaverApp{
#else
class ofApp : public ofBaseApp{
#endif

	public:
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
		void setupWindowSettings(ofxScreenSaverWindowSettings & set);
		#endif

		ofTexture tex;
};
