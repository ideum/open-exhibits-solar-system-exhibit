////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    GestureObject.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.objects 
{
		
	public class GestureListObject extends Object 
	{
		// ID
		public var id:int;
		
		///////////////////////////////////////////////////
		// GESTURE EVENT LOGIC SHOULD BE ABLE TO REMOVE 
		// HAS BEEN MOVED TO GESTURE OBJECT
		// SHOULD BE GESTURE SPECIFIC
		///////////////////////////////////////////////////
		// start
		public var start:Boolean = false;

		// active // uses active touch data to esablish gesture object values
		public var active:Boolean = false;

		// release
		public var release:Boolean = false;

		// passive // easing and other passive processes that use cached gesture object values
		public var passive:Boolean = false;

		// complete
		public var complete:Boolean = false;

		
		//////////////////////////////////////////////////////////////
		// a list of dynamic GML cnofigfured gesture property objects
		// for the touchsprite
		//////////////////////////////////////////////////////////////
		
		//property Object List
		public var pOList:Vector.<GestureObject> = new Vector.<GestureObject>();

	}

}