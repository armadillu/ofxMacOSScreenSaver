//
//  ofxScreensaverView.m
//  ofxScreensaver
//
//  Created by Marek Bereza on 06/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Additions / Modifications by Nick Hardeman.

#include "ofMain.h"
#import "ofxScreenSaver.h"
#include "ofApp.h"


#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define BUNDLE_ID_STRING_LIT @ STRINGIZE2(BUNDLE_IDENTIFIER)
#define SCREENSAVER_CLASS_STRING_LIT @ STRINGIZE2(SCREENSAVER_MAIN_CLASS)
#define SCREENSAVER_GL_VIEW_STRING @ STRINGIZE2(SCREENSAVER_GLVIEW)


@implementation SCREENSAVER_MAIN_CLASS

static int numInstances = 0;
static BOOL isOfSetup = FALSE;

static NSString* const MyModuleName = BUNDLE_ID_STRING_LIT;


- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {

	bMainFrame = NO;

	self = [super initWithFrame:frame isPreview:isPreview];
	NSLog(@"## init with frame: %.0f %.0f %.0f %.0f ####################################################################", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height );
	NSLog(@"isPreview: %d", (int)isPreview);
	NSLog(@"instance # %d", (int)numInstances);
	thisInstance = numInstances;

	isDisabledMonitor = NO;

	preview = isPreview;
	bounds = frame;


	//TODO! read defaults here
	bUseMultiScreen = false;

	numInstances++;

	return self;
}


- (void)startAnimation {

	ofLogNotice("ofxScreenSaver") << "___ startAnimation ___" << thisInstance;

	NSRect frame = [[self window] frame];

	if ( ((int)frame.origin.x == 0 && (int)frame.origin.y == 0 ) || preview ) {
		ofLogNotice("ofxScreenSaver") << "this is the main screen #" << thisInstance;
		bMainFrame = YES;
	}

	bool needsDrawGL = preview || bMainFrame || bUseMultiScreen;
	isDisabledMonitor = !needsDrawGL;

	if(!isDisabledMonitor) {

		ofLogNotice("ofxScreenSaver") << "start anim : creating app & window " << thisInstance;

		app = std::make_shared<ofApp>();

		ofxScreenSaverWindowSettings settings;
		app->setupWindowSettings(settings); //ask our guest app for what window settings it wants

		float deviceFactor = [[self window] backingScaleFactor];
		float retina = settings.retina? deviceFactor : 1;
		settings.setSize(bounds.size.width * retina, bounds.size.height * retina);

		ofInit();
		win = std::make_shared<ofxScreenSaverWindow>();
		ofGetMainLoop()->addWindow(win);
		win->setup(settings, self);

		string npath = [[[NSBundle bundleForClass:[self class]] resourcePath] UTF8String] + string("/data/");
		ofSetDataPathRoot( npath );

		ofGetMainLoop()->run(win, std::move(app));

		lastOfFramerate = ofGetTargetFrameRate();
		if(lastOfFramerate > 0.0){
			[self setAnimationTimeInterval:1/lastOfFramerate];
		}else{
			[self setAnimationTimeInterval:1/60.0];
		}
	}else{
		ofLogNotice("ofxScreenSaver") << "start anim : disabled Monitor " << thisInstance;
	}

	[super startAnimation];
}


- (void)stopAnimation {
	ofLogNotice("ofxScreenSaver") << "startAnimation " << thisInstance;
	if(app != nullptr) {
		app = nullptr;
	}

	[super stopAnimation];
}


- (void)drawRect:(NSRect)rect {
	if(isDisabledMonitor){
		[[NSColor orangeColor] set];
		NSRectFill(rect);
	}
    [super drawRect:rect];
}


- (void)setFrameSize:(NSSize)newSize{
	ofLogNotice("ofxScreenSaver") << "setFrameSize";
	[super setFrameSize:newSize];
//	if(win.get() && win->getGlView()){
//		[win->getGlView() setFrameSize:newSize];
//	}
}


- (void)animateOneFrame {

	if(!isDisabledMonitor){
		ofGetMainLoop()->loopOnce();

		//see if the ofApp set a different framerate, apply that new framerate to our NSOpenGLView
		float ofFramerateNow = ofGetTargetFrameRate();
		if(fabs(lastOfFramerate - ofFramerateNow > 0.1)){
			lastOfFramerate = ofFramerateNow;
			[self setAnimationTimeInterval:1/lastOfFramerate];
			ofLogNotice("ofxScreenSaver") << "ofApp changed framerate! adapting! new target fps: " << ofFramerateNow;
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)hasConfigureSheet{
	return NO;
}


- (NSWindow *)configureSheet {

	ScreenSaverDefaults *defaults;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
	
	if (!configSheet){
		if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self]){
			NSLog( @"Failed to load configure sheet." );
			NSBeep();
		}
	}

	return configSheet;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction) okClick: (id)sender{

	ScreenSaverDefaults *defaults;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
	
	// Update our defaults
    
	// Save the settings to disk
	[defaults synchronize];
    
	// Close the sheet
	[[NSApplication sharedApplication] endSheet:configSheet];
}


- (IBAction)cancelClick:(id)sender {
	[[NSApplication sharedApplication] endSheet:configSheet];
}


- (void)dealloc {
	NSLog(@"ofxScreenSaver :: dealloc : bMainFrame = %i preview = %i thisInstance: %d xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", bMainFrame, preview, thisInstance);
//    if(ssApp != NULL) {
//        NSLog(@"ofxScreenSaver :: calling exit_cb xxxxxxxxx");
//        ssApp->exit_cb();
//        delete ssApp;
//        ssApp = NULL;
//    }

	//[super dealloc];
}

- (ScreenSaverDefaults *)getDefaults {
	return [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
}


+ (BOOL) getConfigureBoolean : (NSString*)index {
	ScreenSaverDefaults *defaults;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];

	return (bool)[defaults boolForKey:index];
}


+ (int) getConfigureInteger : (NSString*)index {
	ScreenSaverDefaults *defaults;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
	return (int)[defaults integerForKey:index];
}

@end


