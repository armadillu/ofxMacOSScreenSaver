#include "ofApp.h"


ofApp::~ofApp(){
	ofLogNotice("ofApp") << "~ofApp()";
}

void ofApp::setupParameters(){

	// Define the parameters you created GUI for in the NIB file.
	// You need to provide a name, a default value (which infers type), and the tag TAG #
	// you did set for that control in interface builder.
	// In Interface Builder, sliders, checkboxes, and dropdown menus are supported.
	// See the supplied ConfigureSheet.nib
	//
	// Beware! this method will be called b4 setup() is called!

	ofLogNotice("ofApp") << "setupParameters()";

	ADD_SSAVER_PARAM("X", 10, 33.1f); //create a float for our slider gui X
	ADD_SSAVER_PARAM("Y", 11, 2); //create a int for our slider gui Y
	ADD_SSAVER_PARAM("TEST TOGGLE", 12, false); //create a bool for TEST TOGGLE checkbox
	ADD_SSAVER_PARAM("MENU", 13, 0); //create a int for DropDown Menu
}


void ofApp::supplyWindowSettings(ofxScreenSaverWindowSettings & set, bool isPreviewWindow){
	isPreview = isPreviewWindow; //is this window the little preview on SystemPreferences?

	//choose specs for your GL window
	set.depthBits = 24;
	set.stencilBits = 0;
	set.alphaBits = 8;
	set.numSamples = 4; //MSAA
}


void ofApp::viewCreated(bool isPreviewWindow, const ofRectangle & r, float uiScale){
	isPreview = isPreviewWindow; //is this window the little preview on SystemPreferences?
	myRect = r; //rect in global OSX desktop space (so you can figure out what monitor you are in multi-monitor scenarios)
	myUiScale = uiScale; //"retina" factor - the user can change this in the control panel
}


bool ofApp::hasConfigureSheet(){
	return true; //return FALSE if want your screensaver to have no settings window
}


/////////////////////////////////////////////////////////////////////////////////////////////////

void ofApp::setup(){

	ofSetFrameRate(60);
	ofSetVerticalSync(true);

	ofLoadImage(tex, "test.png");

	//you can retrieve the SSaver defaults for the paramters you defined before

	//get a parameter value
	float x = GET_SSAVER_PARAM("X"); //access param by "name"
	ofLogNotice("ofApp") << "param 'X' is: " << x;
	x = GET_SSAVER_PARAM(10);  //access param by TAG
	ofLogNotice("ofApp") << "param tag 10 is: " << x;

	//query parameter type
	string type = GET_SSAVER_PARAM_TYPE(10);
	ofLogNotice("ofApp") << "param tag 10 is type: " << type;
	type = GET_SSAVER_PARAM_TYPE("X");
	ofLogNotice("ofApp") << "param 'X' is type: " << type;

}


void ofApp::update(){
 
}


void ofApp::draw(){

	tex.draw(0,0);
	ofDrawBitmapStringHighlight("ofApp::draw()  frame: " + ofToString(ofGetFrameNum()) +
								"\nofGetWidth: " + ofToString(ofGetWidth()) +
								"\nofGetHeight: " + ofToString(ofGetHeight()) +
								"\nframerate: " + ofToString(ofGetFrameRate(),1) +
								"\nisPreview: " + ofToString(isPreview) +
								"\nRect:" + ofToString(myRect)
								,
								30, 30);

	float r = ofGetHeight()/4;

	int speed = GET_SSAVER_PARAM("X");
	ofDrawCircle((speed * ofGetFrameNum())%(int( 1 + ofGetWidth())), ofGetHeight()/2, r);
}


void ofApp::keyPressed(int key){
	ofLogNotice() << "ofApp::keyPressed";
}


void ofApp::keyReleased(int key){
}


void ofApp::mouseMoved(int x, int y){
	ofLogNotice() << "ofApp::mouseMoved";
}


void ofApp::mouseDragged(int x, int y, int button){

}


void ofApp::mousePressed(int x, int y, int button){

}


void ofApp::mouseReleased(int x, int y, int button){

}


void ofApp::mouseEntered(int x, int y){

}


void ofApp::mouseExited(int x, int y){

}


void ofApp::windowResized(int w, int h){

}


void ofApp::gotMessage(ofMessage msg){

}


void ofApp::dragEvent(ofDragInfo dragInfo){ 

}
