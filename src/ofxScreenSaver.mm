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
#include "ofxScreenSaverParameters.h"

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define BUNDLE_ID_STRING_LIT @ STRINGIZE2(BUNDLE_IDENTIFIER)
#define SCREENSAVER_CLASS_STRING_LIT @ STRINGIZE2(SCREENSAVER_MAIN_CLASS)
#define SCREENSAVER_GL_VIEW_STRING @ STRINGIZE2(SCREENSAVER_GLVIEW)

#define GUI_ITEM_TAG_IDs	1000

@implementation SCREENSAVER_MAIN_CLASS

static int numInstances = 0;

static NSString* const MyModuleName = BUNDLE_ID_STRING_LIT;


- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {

	bMainFrame = NO;
	wantsRetina = FALSE;

	self = [super initWithFrame:frame isPreview:isPreview];
	NSLog(@"## %@ init with frame: %.0f %.0f %.0f %.0f ####################################################################", MyModuleName, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height );
	NSLog(@"instance # %d", (int)numInstances);
	thisInstance = numInstances;
	isDisabledMonitor = NO;
	bUseMultiScreen = NO;

	preview = isPreview;
	bounds = frame;

	//load the nib so we can supply all elements to our app
	if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self]){
		NSLog( @"Failed to load configure sheet." );
		NSBeep();
	}else{
		if (!configSheet){
			ofLogError("ofxScreenSaver") << "loaded nib but we don't have access to the config sheet!?";
		}else{
			ofLogNotice("ofxScreenSaver") << "loaded config sheet!";
		}
	}
	numInstances++;
	return self;
}


- (void)recursiveGetControlsInView:(NSView *)view to:(NSMutableArray *)array{
	if([view isKindOfClass:[NSControl class]] && [view tag] < GUI_ITEM_TAG_IDs){ //get all controls that are not default GUI
		[array addObject:view];
	}
	for(NSView *thisView in [view subviews]){
		[self recursiveGetControlsInView:thisView to:array];
	}
}


- (std::map<long,id>) scanAllGui{
	ofLogNotice("ofxScreenSaver") << "scanAllGui()";
	std::map<long,id> ret;
	if(configSheet){
		NSPanel * p = configSheet;
		NSMutableArray * array = [NSMutableArray arrayWithCapacity:10];
		[self recursiveGetControlsInView:[p contentView] to: array];
		for( id control in array){
			int tag = [control tag];
			if(tag > 0 && tag < GUI_ITEM_TAG_IDs){
				ofLogNotice("ofxScreenSaver") << "found GUI item with tag " << tag << " class " << [NSStringFromClass([control class]) cStringUsingEncoding:NSUTF8StringEncoding];
				ret[ tag ] = control;
			}
		}
	}
	return ret;
}


- (void) moveParamsToGuiValues{

	ofLogNotice("ofxScreenSaver") << "moveGuiValuesToParams()";
	std::map<string, ofxScreenSaverParameters::Parameter*> all = ofxScreenSaverParameters::get().getAllParams();
	for(auto it : all){

		ofxScreenSaverParameters::Parameter * p = it.second;
		const string & name = it.first;
		ofJson & pj = p->parameter[SSP_JSON_VALUE_KEY];

		switch (pj.type()) {
			case nlohmann::detail::value_t::number_float:
				[p->uiWidget setFloatValue:pj]; //update gui
				break;

			case nlohmann::detail::value_t::number_integer:
				if([p->uiWidget isKindOfClass:[NSSlider class]]){
					[p->uiWidget setIntValue:pj]; //update gui
				}
				if([p->uiWidget isKindOfClass:[NSPopUpButton class]]){
					[p->uiWidget selectItemAtIndex:(int)pj]; //update gui
				}
				break;

			case nlohmann::detail::value_t::boolean:
				[p->uiWidget setIntValue:pj]; //update gui
				break;

			default:
				ofLogError("ofxScreenSaver") << "Param of unknown type! " << it.first; break;
		}
	}
}


- (void) moveGuiValuesToParams{

	ofLogNotice("ofxScreenSaver") << "moveGuiValuesToParams()";
	std::map<string, ofxScreenSaverParameters::Parameter*> all = ofxScreenSaverParameters::get().getAllParams();

	for(auto it : all){
		ofxScreenSaverParameters::Parameter * p = it.second;
		const string & name = it.first;
		ofJson & pj = p->parameter[SSP_JSON_VALUE_KEY];

		switch (pj.type()) {
			case nlohmann::detail::value_t::number_float:
				pj = [p->uiWidget floatValue]; //update param from current gui
				break;

			case nlohmann::detail::value_t::number_integer:
				if([p->uiWidget isKindOfClass:[NSSlider class]]){
					pj = [p->uiWidget intValue]; //update param from current gui
				}
				if([p->uiWidget isKindOfClass:[NSPopUpButton class]]){
					pj = [p->uiWidget indexOfSelectedItem]; //update param from current gui
				}
				break;

			case nlohmann::detail::value_t::boolean:
				pj = [p->uiWidget intValue]; //update param from current gui
				break;

			default:
				ofLogError("ofxScreenSaver") << "Param of unknown type! " << it.first; break;
		}
	}
}


- (void) loadSettings{
	ofLogNotice("ofxScreenSaver") << "loadSettings()";
	if([[self getDefaults] objectForKey:@"MultiScreen"]){
		bUseMultiScreen = [[self getDefaults] integerForKey:@"MultiScreen"];
	}
	if([[self getDefaults] objectForKey:@"wantsRetina"]){
		wantsRetina = [[self getDefaults] integerForKey:@"wantsRetina"];
	}

	std::map<string, ofxScreenSaverParameters::Parameter*> all = ofxScreenSaverParameters::get().getAllParams();
	for(auto it : all){

		ofxScreenSaverParameters::Parameter * p = it.second;
		const string & name = it.first;
		ofJson & pj = p->parameter[SSP_JSON_VALUE_KEY];

		switch (pj.type()) {
			case nlohmann::detail::value_t::number_float:
				ofLogNotice("ofxScreenSaver") << "loading FLOAT param '" << name << "' with tag " << p->tag << " as value " << pj;
				if ( [[self getDefaults] objectForKey: [NSString stringWithUTF8String:name.c_str()]] != nil ){
					pj = (float) [[self getDefaults] floatForKey: [NSString stringWithUTF8String:name.c_str()]];
				}else{

				}
				[p->uiWidget setFloatValue:pj]; //update gui
				break;

			case nlohmann::detail::value_t::number_integer:
				ofLogNotice("ofxScreenSaver") << "loading INT param '" << name << "' with tag " << p->tag << " as value " << pj;
				pj = (int) [[self getDefaults] integerForKey: [NSString stringWithUTF8String:name.c_str()]];
				[p->uiWidget setIntValue:pj]; //update gui
				break;

			case nlohmann::detail::value_t::boolean:
				ofLogNotice("ofxScreenSaver") << "loading BOOL param '" << name << "' with tag " << p->tag << " as value " << pj;
				pj = (bool) [[self getDefaults] boolForKey: [NSString stringWithUTF8String:name.c_str()]];
				[p->uiWidget setIntValue:pj]; //update gui
				break;

			default:
				ofLogError("ofxScreenSaver") << "Param of unknown type! " << it.first; break;
		}
	}
}


- (void) saveSettings{
	ofLogNotice("ofxScreenSaver") << "saveSettings()";
	[[self getDefaults] setInteger: bUseMultiScreen forKey:@"MultiScreen"];
	[[self getDefaults] setInteger: wantsRetina forKey:@"wantsRetina"];

	std::map<string, ofxScreenSaverParameters::Parameter*> all = ofxScreenSaverParameters::get().getAllParams();

	for(auto it : all){
		ofxScreenSaverParameters::Parameter * p = it.second;
		const string & name = it.first;
		ofJson & pj = p->parameter[SSP_JSON_VALUE_KEY];

		switch (pj.type()) {
			case nlohmann::detail::value_t::number_float:
				ofLogNotice("ofxScreenSaver") << "saving FLOAT param '" << name << "' with tag " << p->tag << " as value " << pj;
				[[self getDefaults] setFloat: (float)pj forKey:[NSString stringWithUTF8String:name.c_str()]];
				break;

			case nlohmann::detail::value_t::number_integer:
				ofLogNotice("ofxScreenSaver") << "saving INT param '" << name << "' with tag " << p->tag << " as value " << pj;
				[[self getDefaults] setInteger: (int)pj forKey:[NSString stringWithUTF8String:name.c_str()]];
				break;

			case nlohmann::detail::value_t::boolean:
				ofLogNotice("ofxScreenSaver") << "saving BOOL param '" << name << "' with tag " << p->tag << " as value " << pj;
				[[self getDefaults] setBool: (bool)pj forKey:[NSString stringWithUTF8String:name.c_str()]];
				break;

//			case nlohmann::detail::value_t::string:{
//				string val = (string)p->parameter["val"];
//				[[self getDefaults] setObject: [NSString stringWithUTF8String:val.c_str()] forKey:[NSString stringWithUTF8String:name.c_str()]];
//				}break;
			default:
				ofLogError("ofxScreenSaver") << "Param of unknown type! " << it.first; break;
		}
	}

	BOOL saveOK = [[self getDefaults] synchronize];
	if(!saveOK){
		ofLogError("ofxScreenSaver") << "can't save NSUserDefaults!";
	}
}


- (void) startAnimation {

	ofLogNotice("ofxScreenSaver") << "____ startAnimation ____ " << thisInstance;

	app = std::make_shared<ofApp>();
	static bool paramsAreSetup = false;
	if(!paramsAreSetup){ //make sure we only create SSaver params once
		app->setupParameters(); //ask ofApp host to define its parameters for GUI
		paramsAreSetup = true;
	}

	[self loadSettings]; //read defaults here
	[self moveParamsToGuiValues];

	std::map<long,id> allGui = [self scanAllGui];
	ofxScreenSaverParameters::get().setParamWidgets(allGui); //bind the params to ghe GUI controls in the NIB we loaded

	static std::map<id, bool> isSetup; //make sure we dont setup twice (for each instance)

	auto it = isSetup.find(self);
	if(true || it == isSetup.end()){

		isSetup[self] = true;

		//NSRect frame = [[self window] frame];
		NSRect frame = bounds;

		if ( ((int)frame.origin.x == 0 && (int)frame.origin.y == 0 ) || preview ) {
			ofLogNotice("ofxScreenSaver") << "this is the main screen #" << thisInstance;
			bMainFrame = YES;
		}

		bool needsDrawGL = preview || bMainFrame || bUseMultiScreen;
		isDisabledMonitor = !needsDrawGL;

		if(!isDisabledMonitor) {

			ofxScreenSaverWindowSettings settings = ofxScreenSaverWindowSettings(wantsRetina);
			app->supplyWindowSettings(settings, preview); //ask our guest app for what window settings it wants

			float deviceFactor = [[self window] backingScaleFactor];
			float retina = wantsRetina ? deviceFactor : 1;
			settings.setSize(bounds.size.width * retina, bounds.size.height * retina);

			ofRectangle r = ofRectangle(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

			ofInit();
			win = std::make_shared<ofxScreenSaverWindow>();
			ofGetMainLoop()->addWindow(win);
			win->setup(settings, self);

			app->viewCreated(preview, r, retina);

			string npath = [[[NSBundle bundleForClass:[self class]] resourcePath] UTF8String] + string("/data/");
			ofSetDataPathRoot( npath );

			ofGetMainLoop()->run(win, app);

			lastOfFramerate = ofGetTargetFrameRate();
			if(lastOfFramerate > 0.0){
				[self setAnimationTimeInterval:1/lastOfFramerate];
			}else{
				[self setAnimationTimeInterval:1/60.0];
			}
		}else{
			ofLogNotice("ofxScreenSaver") << "start anim : disabled Monitor " << thisInstance;
		}
	}else{
		ofLogWarning("ofxScreenSaver") << "skipping setup of " << self << " as we already are setup! " << thisInstance;
	}

	[super startAnimation];
}


- (void)stopAnimation {
	ofLogNotice("ofxScreenSaver") << "____ stopAnimation ____ " << thisInstance;
	//ofGetMainLoop()->shouldClose(0);
	//ofGetMainLoop()->exit();
	//win->close();
	ofLogNotice("ofxScreenSaver") << " win use_count: " << win.use_count() << " app use_count: " << app.use_count();
	win = nullptr;
	app = nullptr;
	ofLogNotice("ofxScreenSaver") << " win use_count: " << win.use_count() << " app use_count: " << app.use_count();
	[super stopAnimation];
}


- (void)drawRect:(NSRect)rect {
	[[NSColor blackColor] set];
	NSRectFill(rect);
    [super drawRect:rect];
}


- (void)setFrameSize:(NSSize)newSize{
	ofLogNotice("ofxScreenSaver") << "setFrameSize()";
	[super setFrameSize:newSize];
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
//	if(!app.get()){
//		ofLogError("ofxScreensaver") << "too early for hasConfigureSheet! " << thisInstance ;
//		return YES;
//	}
	return YES;
}


- (NSWindow *)configureSheet {

	ofLogNotice("ofxScreenSaver") << "configureSheet()";
	if (!configSheet){
		NSLog( @"loading configure sheet..." );
		if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self]){
			NSLog( @"Failed to load configure sheet." );
			NSBeep();
		}
	}

	//update settings b4 we present
	[retinaButton setIntValue: wantsRetina];
	[multiMonitorButton setIntValue: bUseMultiScreen];
	[self moveParamsToGuiValues];

	return configSheet;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction) okClick: (id)sender{
	ofLogNotice("ofxScreenSaver") << "okClick()";

	wantsRetina = [retinaButton intValue];
	bUseMultiScreen = [multiMonitorButton intValue];
	[self moveGuiValuesToParams];
	[self saveSettings];
	[[NSApplication sharedApplication] endSheet:configSheet];
	app->reloadSSaverSettings();

}


- (IBAction)cancelClick:(id)sender {
	ofLogNotice("ofxScreenSaver") << "cancelClick()";
	[self loadSettings]; //undo all changes!
	[[NSApplication sharedApplication] endSheet:configSheet];
}




- (void)dealloc {
	NSLog(@"DEALLOC : bMainFrame = %i preview = %i thisInstance: %d xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", bMainFrame, preview, thisInstance);
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
