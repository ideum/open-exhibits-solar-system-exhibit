////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    MousePoint.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.utils
{
	public class MousePoint
	{
		public static var mousePoints:Array = new Array();
		
		private static var _mousePointID:int=899;
		public static function get mousePointID():int
		{
			return _mousePointID;
		}
		public static function set mousePointID(value:int):void
		{
			_mousePointID=value; 
		}
		
		public static function getID():int
		{
			/*for (var i:int = 0; i < mousePoints.length; i++ )
			{
				if (i != mousePoints[i]) break;
			}
			
			mousePointID=i;
			
			mousePoints.push(mousePointID);*/
			
			if (mousePointID == 999) mousePointID = 899;
			
			mousePointID++;
			
			return mousePointID;
		}
		
		public static function removeID():void
		{
			mousePointID--;
		}

	}
}