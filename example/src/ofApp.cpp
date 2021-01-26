#include "ofApp.h"


void ofApp::setupWindowSettings(ofxScreenSaverWindowSettings & set){

	set.depthBits = 24;
	set.stencilBits = 0;
	set.alphaBits = 8;
	set.numSamples = 4; //MSAA
	set.retina = true;
}


void ofApp::setup(){

	ofSetFrameRate(60);
	ofSetVerticalSync(true);

	ofLoadImage(tex, "test.png");
}


void ofApp::update(){
 
}


void ofApp::draw(){

	tex.draw(0,0);
	ofDrawBitmapStringHighlight("ofApp::draw()  frame: " + ofToString(ofGetFrameNum()) +
								"\nofGetWidth: " + ofToString(ofGetWidth()) +
								"\nofGetHeight: " + ofToString(ofGetHeight()) +
								"\nframerate: " + ofToString(ofGetFrameRate(),1)
								,
								30, 30);

	float r = ofGetHeight()/4;
	ofDrawCircle((10 * ofGetFrameNum())%(int( 1 + ofGetWidth())), ofGetHeight()/2, r);
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
