////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    NoiseFilter.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.utils
{
	public class NoiseFilter
	{
		private var N:int;
		private var g:Number;
		private var b:Array;
		private var a:Array;
		private var z:Array;	
		
		public function NoiseFilter():void
		{
			initFilterVars();	
        }
		
		public function initFilterVars():void
			{
			N = 4;
			z = new Array (0.0, 0.0, 0.0, 0.0);
			
			//10Hz
			//b = new Array (1.000000000000000, 1.999999938672026, 0.999999985818274, 1.000000000000000, 2.000000061327984, 1.000000014181733);
			//a = new Array (1.000000000000000, -0.567106945360776,  0.114068379927028, 1.000000000000000, -0.765826070175245, 0.504447470244345);
			//g = 0.0252498387864455;
			
			//5Hz
			//b = new Array (1.000000000000000, 1.999999938672026, 0.999999985818274, 1.000000000000000, 2.000000061327984, 1.000000014181733);
			//a = new Array (1.000000000000000, -1.212812092620223, 0.384004162286556, 1.000000000000000, -1.479798894397214, 0.688676953053858);
			//g = 0.00223489169808233;
			
			//2Hz
			b = new Array (1.000000000000000, 1.999999938672026, 0.999999985818274, 1.000000000000000, 2.000000061327984, 1.000000014181733);
			a = new Array (1.000000000000000, -1.641069737235577, 0.677732211380365, 1.000000000000000, -1.812115400351030, 0.852599136358978);
			//g =  0.0000927646202923116;
			g =  9.27646202923116e-05;
		}
		
		public function next(value:Number):Number {
					
			var y0:Number = value;

			for (var i:int = 0; i < N; i += 2) 
				{
				var z0:Number;
				var k:int = 3*i/2
				{
				z0 = 1.0*y0 - a[k+1]*z[i+0] - a[k+2]*z[i+1];
				y0 = b[k+0]*z0 + b[k+1]*z[i+0] + b[k+2]*z[i+1];
				z[i+1] = z[i+0];
				z[i+0] = z0;
				}
			}
			return y0 * g;
		}
	}
}