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

#define SSP_JSON_VALUE_KEY "val"
#define GET_SSAVER_PARAM(a) 						ofxScreenSaverParameters::get().getParam(a)["val"]
#define GET_SSAVER_PARAM_TYPE(a) 					ofxScreenSaverParameters::getParamTypeName(ofxScreenSaverParameters::get().getParam(a)["val"].type())
#define ADD_SSAVER_PARAM(name, tagID, value) 		ofxScreenSaverParameters::get().addParameter(name, tagID, value)
#define UDPATE_SSAVER_PARAM(nameOrTag, value) 		ofxScreenSaverParameters::get().updateParameter(nameOrTag, value)


class ofxScreenSaverParameters{

public:

	struct Parameter{
		id uiWidget = nil;
		long tag = 0;
		ofJson parameter; //here im being lazy and using an ofJson object as a wildcard container to easily store an int, float, bool or string.
	};

	
	static ofxScreenSaverParameters& get(){
		static ofxScreenSaverParameters instance; // Instantiated on first use.
		return instance;
	}

	static string getParamTypeName(nlohmann::detail::value_t t){
		switch(t){
			case nlohmann::detail::value_t::number_float: return "float";
			case nlohmann::detail::value_t::number_integer: return "int";
			case nlohmann::detail::value_t::boolean: return "bool";
			default: ofLogError("ofxScreenSaverParameters") << "getParameterType() unkonwn type!" << (int) t;
		}
		return "Unkonwn Type!";
	}

	ofxScreenSaverParameters(){};

	template<typename T>
	bool addParameter(const string & name, int tag, T value){
		auto it = paramsByID.find(tag);
		auto it2 = paramsByName.find(name);

		ofJson test;
		test["test"] = value;
		auto type = test["test"].type();
		if (type != nlohmann::detail::value_t::number_float &&
			type != nlohmann::detail::value_t::number_integer &&
			type != nlohmann::detail::value_t::boolean){
			ofLogError("ofxScreenSaverParameters") << "Can't add parameter! Type not supported! only int, float and bool are. " << (int)type ;
			return false;
		}
		if(it == paramsByID.end() && it2 == paramsByName.end()){
			ofLogNotice("ofxScreenSaverParameters") << "Added " << getParamTypeName(type) << " Parameter '" << name << "' with tag " << tag << " and value '" << value << "'";
			Parameter * p = new Parameter();
			p->parameter[SSP_JSON_VALUE_KEY] = value;
			p->tag = tag;
			paramsByID[tag] = p;
			paramsByName[name] = p;
			return true;
		}else{
			ofLogError("ofxScreenSaverParameters") << "Can't add param! Already have one with that tag or name! '" << name << "' tag: " << tag;
			return false;
		}
	}

	// GET PARAM ////////////////////////////////////////////////////////////////////////////////

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
			p->parameter[SSP_JSON_VALUE_KEY] = value;
		}else{
			ofLogError("ofxScreenSaverParameters") << "can't updateParameter with tagID '" << tagID << "' it does not exist!";
		}
	}

	template<typename T>
	void updateParameter(const string & paramName, T value){
		auto it = paramsByName.find(paramName);
		if(it != paramsByName.end()){
			Parameter * p = it->second;
			p->parameter[SSP_JSON_VALUE_KEY] = value;
		}else{
			ofLogError("ofxScreenSaverParameters") << "can't updateParameter named '" << paramName << "' it does not exist!";
		}
	}

	/////////////////////////////////////////////////////////////////////////////////////////////

	void setParamWidgets(std::map<long,id> & allGui){
		ofLogNotice("ofxScreenSaverParameters") << "setParamWidgets()";
		for(auto & it : allGui){
			long tag = it.first;
			auto it2 = paramsByID.find(tag);
			if(it2 != paramsByID.end()){
				Parameter * p = it2->second;
				p->uiWidget = it.second;
				ofLogNotice("ofxScreenSaverParameters") << "Binding GUI for item with tag " << tag;
			}else{
				ofLogError("ofxScreenSaverParameters") << "cant find existing param for tag " << tag;
			}
		}
	}

	std::map<string, ofxScreenSaverParameters::Parameter*> getAllParams(){return paramsByName;}

protected:

	std::map<long, Parameter*> paramsByID; //indexed by tag
	std::map<string, Parameter*> paramsByName; //indexed by name

};

