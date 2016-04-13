////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    GestureWorks.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.gestureworks.core
{		 
	/* 
	
	IMPORTANT NOTE TO DEVELOPER **********************************************
	 
	PlEASE DO NOT ERASE OR DEVALUE ANYTHING WHITHIN THIS CLASS IF YOU DO NOT UNDERSTAND IT'S CURRENT VALUE OR PLACE... PERIOD...
	IF YOU HAVE ANY QUESTIONS, ANY AT ALL. PLEASE ASK PAUL LACEY (paul@ideum.com) ABOUT IT'S IMPORTATANCE.
	IF PAUL IS UNABLE TO HELP YOU UNDERSTAND, THEN PLEASE LOOK AND READ THE ACTUAL CODE FOR IT'S PATH.
	SOMETHINGS AT FIRST MAY NOT BE CLEAR AS TO WHAT THE ACTUAL PURPOSE IS, BUT IT IS VALUABLE AND IS USED IF IT IS CURRENTLY WRITTTEN HERE.
	DO NOT TAKE CODE OUT UNLESS YOUR CHANGES ARE VERIEFIED, TESTED AND CONTINUE TO WORK WITH LEGACY BUILDS !
	
	*/	
	
	import com.gestureworks.core.CML;
	import com.gestureworks.core.GML;
	import com.gestureworks.managers.ModeManager;
	import com.gestureworks.utils.CMLLoader;
	import com.gestureworks.utils.GMLParser;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;

	/**
	 * The GestureWorks class is the core class that can be accessed from all classes within.
	 * It can be initialized as a super class, or as an instantiation; var gestureworks:GestureWorks = new GestureWorks();
	 * You can add a .cml path;  cml = ""; or  new GestureWorks("pathToCml");
	 * 
	 * package
	 * {
	 * 		import com.gestureworks.core.GestureWorks;
	 * 		import flash.events.Event;
	 * 		public class Main extends GestureWorks
	 * 		{
	 * 			super();
	 * 			cml = "library/cml/my_application.cml";
	 * 			gml = "library/gml/my_gestures.gml";
	 * 			fullscreen = true;
	 * 		}
	 * 
	 * 		override protected function gestureworksInit():void
	 * 		{
	 * 			trace("GestureWorks has intialized");
	 * 		}
	 * 	}
	 * 
	*/	
	public class GestureWorks extends GestureWorksCore
	{		
		public static var _version:String = "4.1.0";
		/**
		 * Returns the current version of GestureWorks.
		 */		
		public static function get version():String { return _version; }

		public static var _copyright:String = "© 2009-2013 Ideum Inc.\nAll Rights Reserved";
		/**
		 * Returns the current copyright information for GestureWorks.
		 */		
		public static function get copyright():String { return _copyright; }
		/**
		 * Returns whether TUIO is activated.
		 */
		public static var activeTUIO:Boolean;
		/**
		 * Returns whether simulation is activated.
		 */
		public static var activeSim:Boolean;
		/**
		 * Returns whether the motion framework is activated
		 */
		public static var activeMotion:Boolean;		
		/**
		 * Returns whether the sensor framework is activated
		 */
		public static var activeSensor:Boolean;		
		/**
		 * Returns whether native touch is activated
		 */
		public static var activeNativeTouch:Boolean = true;
		/**
		 * Determines if Shift key is down or Up.  For use with simulator.
		 */
		public static var isShift:Boolean;
		/**
		 * Returns whether your device currently has touch support available.
		 */
		public static function get supportsTouch():Boolean { return _supportsTouch; }
		/**
		 * String is the dispatcher for GestureWorks framework.
		 */
		public static var GESTUREWORKS_COMPLETE:String = "gestureworks complete";
		/**
		 * Var = stage.
		 */
		public static var application:Stage;		
		/**
		 * The GestureWorks constructor.
		 * var gestureworks:GestureWorks = new GestureWorks();
		 */
		public function GestureWorks(gmlPath:String = null, cmlPath:String = null)
		{
			super();
			if (gmlPath) gml = gmlPath;
			if (cmlPath) cml = cmlPath;
		}

	}
}