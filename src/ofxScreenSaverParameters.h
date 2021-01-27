//
//  ofxScreenSaverParameters.h
//  ScreenSaverOF
//
//  Created by Oriol Ferrer Mesià on 27/01/2021.
//Copyright © 2021 Oriol Ferrer Mesià. All rights reserved.
//

#pragma once
#include "ofMain.h"


#if defined(__OBJC__)
#import <Cocoa/Cocoa.h>
#else
typedef void* id;
#endif

#define JSON_VAL_KEY "val"

#define GET_SSAVER_PARAM(a) 						ofxScreenSaverParameters::get().getParam(a)["val"]
#define GET_SSAVER_PARAM_TYPE(a) 					ofxScreenSaverParameters::get().getParam(a).type()
#define ADD_SSAVER_PARAM(name, tagID, value) 		ofxScreenSaverParameters::get().addParameter(name, tagID, value)
#define UDPATE_SSAVER_PARAM(nameOrTag, value) 		ofxScreenSaverParameters::get().updateParameter(nameOrTag, value)


class ofxScreenSaverParameters{

public:
	
	static ofxScreenSaverParameters& get(){
		static ofxScreenSaverParameters instance; // Instantiated on first use.
		return instance;
	}

	ofxScreenSaverParameters(){};

	template<typename T>
	bool addParameter(const string & name, int tag, T value){
		auto it = paramsByID.find(tag);
		auto it2 = paramsByName.find(name);
		if(it == paramsByID.end() && it2 == paramsByName.end()){
			ofLogNotice("ofxScreenSaverParameters") << "Added Parameter '" << name << "' with tag " << tag << " and value '" << value << "'";
			Parameter * p = new Parameter();
			p->parameter[JSON_VAL_KEY] = value;
			paramsByID[tag] = p;
			paramsByName[name] = p;
			return true;
		}else{
			ofLogError("ofxScreenSaverParameters") << "Can't add param! Already have one with that tag or name! '" << name << "' tag: " << tag;
			return false;
		}
	}

	// GET PARAM ////////////////////////////////////////////////////////////////////////////////

//	template<typename T>
//	T getParameter(long tagID){
//		auto it = paramsByID.find(tagID);
//		if(it != paramsByID.end()){
//			Parameter * p = it->second;
//			return p->parameter[JSON_VAL_KEY];
//		}else{
//			ofLogError("ofxScreenSaverParameters") << "can't getParameter with tagID '" << tagID << "' it does not exist!";
//		}
//		return T();
//	}
//
//	template<typename T>
//	T getParameter(const string & paramName){
//		auto it = paramsByName.find(paramName);
//		if(it != paramsByName.end()){
//			Parameter * p = it->second;
//			return p->parameter[JSON_VAL_KEY];
//		}else{
//			ofLogError("ofxScreenSaverParameters") << "can't getParameter with name '" << paramName << "' it does not exist!";
//		}
//		return T();
//	}

	ofJson& getParam(long tagID){
		auto it = paramsByID.find(tagID);
		if(it != paramsByID.end()){
			Parameter * p = it->second;
			return p->parameter;
		}else{
			ofLogError("ofxScreenSaverParameters") << "can't getParameter with tagID '" << tagID << "' it does not exist!";
		}
		static ofJson j;
		return j;
	}

	ofJson& getParam(const string & paramName){
		auto it = paramsByName.find(paramName);
		if(it != paramsByName.end()){
			Parameter * p = it->second;
			return p->parameter;
		}else{
			ofLogError("ofxScreenSaverParameters") << "can't getParameter with Name '" << paramName << "' it does not exist!";
		}
		static ofJson j;
		return j;
	}

	// UPDATE PARAM /////////////////////////////////////////////////////////////////////////////

	template<typename T>
	void updateParameter(long tagID, T value){
		auto it = paramsByID.find(tagID);
		if(it != paramsByID.end()){
			Parameter * p = it->second;
			p->parameter[JSON_VAL_KEY] = value;
		}else{
			ofLogError("ofxScreenSaverParameters") << "can't updateParameter with tagID '" << tagID << "' it does not exist!";
		}
	}

	template<typename T>
	void updateParameter(const string & paramName, T value){
		auto it = paramsByName.find(paramName);
		if(it != paramsByName.end()){
			Parameter * p = it->second;
			p->parameter[JSON_VAL_KEY] = value;
		}else{
			ofLogError("ofxScreenSaverParameters") << "can't updateParameter named '" << paramName << "' it does not exist!";
		}
	}


protected:

	struct Parameter{
		id uiWidget = nil;
		long tag = 0;
		ofJson parameter;
	};

	std::map<long, Parameter*> paramsByID; //indexed by tag
	std::map<string, Parameter*> paramsByName; //indexed by name

};


#undef JSON_VAL_KEY
