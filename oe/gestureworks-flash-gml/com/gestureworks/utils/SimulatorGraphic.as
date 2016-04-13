////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:   SimulatorGraphic.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.utils
{
	import flash.display.Sprite;
	
	public class SimulatorGraphic extends Sprite
	{
		public var id:int;
		public function SimulatorGraphic(color:uint, radius:Number, alpha:Number)
		{			
			graphics.beginFill(color, 1);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
		}
	}
}