////////////////////////////////////////////////////////////////////////////////
//
//  IDEUM
//  Copyright 2011-2012 Ideum
//  All Rights Reserved.
//
//  GestureWorks
//
//  File:    InertialFilter.as
//  Authors:  Ideum
//             
//  NOTICE: Ideum permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package com.gestureworks.utils
{
	public class InertialFilter
	{
		private var N:int;
		private var g:Number;
		private var b:Array;
		private var a:Array;
		private var z:Array;	
		
		public function InertialFilter():void
		{
			//initInertialVars();	
        }
		
		//public function initInertialVars(Ts, m, k, c):void //mass_spring_damper_form
			//{
			//N = 4;
			//z = new Array (0.0, 0.0, 0.0, 0.0);
			
			/*
			b0 = k*Ts*Ts + 2*c*Ts;
			a0 = k * Ts * Ts + 2 * c * Ts + 4 * m;
			
			b = [ 1.0, (2*k*Ts*Ts) / b0,  (k*Ts*Ts - 2*c*Ts) / b0 ];
			a = [ 1.0, (2*k*Ts*Ts - 8*m) / a0, (k*Ts*Ts - 2*c*Ts + 4*m) / a0 ];
			g = b0 / a0;
			*/
			//10Hz
			//b = new Array (1.000000000000000, 1.999999938672026, 0.999999985818274, 1.000000000000000, 2.000000061327984, 1.000000014181733);
			//a = new Array (1.000000000000000, -0.567106945360776,  0.114068379927028, 1.000000000000000, -0.765826070175245, 0.504447470244345);
			//g = 0.0252498387864455;
		//}
		
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