//
//  ofxScreenSaverWindow.cpp
//  ofxScreenSaver
//
//  Created by Nick Hardeman on 1/24/14.
//
//

#include "ofxScreenSaverWindow.h"

#include "ofBaseApp.h"
#include "ofEvents.h"
#include "ofUtils.h"
#include "ofGraphics.h"
#include "ofAppRunner.h"
#include "ofGLProgrammableRenderer.h"
#include "ofGLRenderer.h"
#import "ofxScreenSaverGLView.h"
#include <AppKit/AppKit.h>
#import <ScreenSaver/ScreenSaver.h>


ofxScreenSaverWindow::ofxScreenSaverWindow()
:coreEvents(new ofCoreEvents){
	ofLogNotice("ofxScreenSaverWindow") << "ofxScreenSaverWindow()";
	ofAppPtr = nullptr;
	currentRenderer = std::make_shared<ofGLRenderer>(this);
	width = 0;
	height = 0;

}

ofxScreenSaverWindow::~ofxScreenSaverWindow(){
	ofLogNotice("ofxScreenSaverWindow") << "~ofxScreenSaverWindow()";
	if(glView) {
		[NSOpenGLContext clearCurrentContext];
		[glView removeFromSuperview];
		glView = nil;
	}
}

id ofxScreenSaverWindow::getGlView(){
	return glView;
}


void ofxScreenSaverWindow::setup(const ofGLWindowSettings & settings){
	const ofxScreenSaverWindowSettings * glSettings = dynamic_cast<const ofxScreenSaverWindowSettings*>(&settings);
	if(glSettings){
		setup(*glSettings);
	}else{
		setup(ofxScreenSaverWindowSettings(settings));
	}
}

void ofxScreenSaverWindow::setup(const ofxScreenSaverWindowSettings & settings, id ssView){

	width = settings.getWidth();
	height = settings.getHeight();

	std::vector<NSOpenGLPixelFormatAttribute> attribs;

	if(settings.glVersionMajor >= 4){
		ofLogNotice("ofxScreenSaverWindow") << "requesting GL 4.1";
		attribs.push_back(NSOpenGLPFAOpenGLProfile);
		attribs.push_back(NSOpenGLProfileVersion4_1Core);
	}else{
		if(settings.glVersionMajor >= 3){
			ofLogNotice("ofxScreenSaverWindow") << "requesting GL 3.2";
			attribs.push_back(NSOpenGLPFAOpenGLProfile);
			attribs.push_back(NSOpenGLProfileVersion3_2Core);
		}else{
			ofLogNotice("ofxScreenSaverWindow") << "requesting GL 2.1";
		}
	}

	attribs.push_back(NSOpenGLPFAAccelerated);
	attribs.push_back(NSOpenGLPFAClosestPolicy);
	attribs.push_back(NSOpenGLPFADoubleBuffer);
	attribs.push_back(NSOpenGLPFASampleBuffers);
	attribs.push_back(settings.numSamples > 0 ? 1 : 0);
	attribs.push_back(NSOpenGLPFASamples);
	attribs.push_back(settings.numSamples);
	attribs.push_back(NSOpenGLPFAMultisample);
	attribs.push_back(NSOpenGLPFANoRecovery);
	attribs.push_back(NSOpenGLPFADepthSize);
	attribs.push_back(settings.depthBits);
	attribs.push_back(NSOpenGLPFAStencilSize);
	attribs.push_back(settings.stencilBits);
	attribs.push_back(NSOpenGLPFAAlphaSize);
	attribs.push_back(settings.alphaBits);
	attribs.push_back(0);

	id pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs.data()];
	if (pixelFormat == nil){
		ofLogError("ofxScreenSaverWindow") << "can't create PixelFormat!";
		return;
	}

	glView = [[SCREENSAVER_GLVIEW alloc] initWithFrame: NSZeroRect pixelFormat:pixelFormat];

	ScreenSaverView * ssView_ = (ScreenSaverView *)ssView;
	[ssView_ addSubview: glView];
	[glView setFrame:NSMakeRect(0, 0, ssView_.frame.size.width, ssView_.frame.size.height)];

	[ssView_ lockFocus];
	[[glView openGLContext] makeCurrentContext];

	if(settings.retina){
		float deviceFactor = [[ssView_ window] backingScaleFactor];
		pixelScreenCoordScale = deviceFactor;
		[ glView setWantsBestResolutionOpenGLSurface: YES];
	}

	if(settings.glVersionMajor>=3){
		currentRenderer = std::make_shared<ofGLProgrammableRenderer>(this);
	}else{
		currentRenderer = std::make_shared<ofGLRenderer>(this);
	}

	static bool inited = false;
	if(!inited){
		glewExperimental = GL_TRUE;
		GLenum err = glewInit();
		if (GLEW_OK != err){
			ofLogError("ofAppRunner") << "couldn't init GLEW: " << glewGetErrorString(err);
			return;
		}
		inited = true;
	}

	if(settings.glVersionMajor>=3){
		static_cast<ofGLProgrammableRenderer*>(currentRenderer.get())->setup(settings.glVersionMajor,settings.glVersionMinor);
	}else{
		static_cast<ofGLRenderer*>(currentRenderer.get())->setup();
	}

	ofLogNotice("ofxScreenSaverWindow") << "GL Version: " << glGetString(GL_VERSION);
}

void ofxScreenSaverWindow::setVerticalSync(bool enabled){

	if(glView){
		GLint i = enabled ? 1 : 0;
		[[glView openGLContext] setValues:&i forParameter:NSOpenGLCPSwapInterval];
	}
}


void ofxScreenSaverWindow::close(){

	if(glView) {

		currentRenderer.reset(); //delete OF gl context

		[[glView openGLContext] makeCurrentContext];
		[NSOpenGLContext clearCurrentContext];
		[glView removeFromSuperview];
		glView = nil;
	}
}


void ofxScreenSaverWindow::update(){
	events().notifyUpdate();
}


void ofxScreenSaverWindow::draw(){

	[[glView openGLContext] makeCurrentContext];
	currentRenderer->startRender();
	if( bEnableSetupScreen ) currentRenderer->setupScreen();

	events().notifyDraw();

	[[glView openGLContext] flushBuffer];

	currentRenderer->finishRender();
}


void ofxScreenSaverWindow::exitApp(){
	ofLogNotice("ofxScreenSaverWindow") << "terminating ofxScreenSaverWindow based app!";
	OF_EXIT_APP(0);
}


glm::vec2 ofxScreenSaverWindow::getWindowPosition(){
	return {0.f, 0.f};
}


glm::vec2 ofxScreenSaverWindow::getWindowSize(){
	return {width, height};
}


glm::vec2 ofxScreenSaverWindow::getScreenSize(){
	return {width, height};
}



int	ofxScreenSaverWindow::getWidth(){
	return width;
}


int	ofxScreenSaverWindow::getHeight(){
	return height;
}



ofCoreEvents & ofxScreenSaverWindow::events(){
	return *coreEvents;
}

std::shared_ptr<ofBaseRenderer> & ofxScreenSaverWindow::renderer(){
	return currentRenderer;
}

void ofxScreenSaverWindow::enableSetupScreen(){
	bEnableSetupScreen = true;
};

void ofxScreenSaverWindow::disableSetupScreen(){
	bEnableSetupScreen = false;
};

