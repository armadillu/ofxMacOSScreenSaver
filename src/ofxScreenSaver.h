//
//  ofxScreensaverView.h
//  ofxScreensaver
//
//  Created by Marek Bereza on 06/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//  Additions / Modifications by Nick Hardeman.


#include "ofMain.h"
#import "ofxScreenSaverGLView.h"
#include "ofxScreenSaverWindow.h"
#import <ScreenSaver/ScreenSaver.h>

class ofApp;

@interface SCREENSAVER_MAIN_CLASS : ScreenSaverView {

	// add a configure sheet //
	IBOutlet id configSheet;

    BOOL preview;
    BOOL bMainFrame; //main monitor
    BOOL bUseMultiScreen; //from defaults, draw on all screens or only on main?
	BOOL isDisabledMonitor;
	int thisInstance;

	std::shared_ptr<ofxScreenSaverWindow> win;
	std::shared_ptr<ofApp> app;

    NSRect bounds;
	float lastOfFramerate;
}

- (ScreenSaverDefaults *) getDefaults;

+ (BOOL) getConfigureBoolean : (NSString*)index;
+ (int) getConfigureInteger : (NSString*)index;

@end









