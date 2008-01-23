/*
 * Copyright 2007 (c) Tim Knip, ascollada.org.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 
package org.ascollada.core 
{
	import org.ascollada.ASCollada;
	import org.ascollada.core.DaeAnimationCurve;
	import org.ascollada.core.DaeEntity;
	import org.ascollada.core.DaeInput;
	import org.ascollada.core.DaeSampler;
	import org.ascollada.core.DaeSource;
	import org.ascollada.types.DaeAddressSyntax;
	import org.ascollada.utils.Logger;
	
	/**
	 * 
	 */
	public class DaeChannel extends DaeEntity
	{	
		/** source - required */
		public var source:String;
		
		/** target - required */
		public var target:String;
		
		/** some info on the target attribute */
		public var syntax:DaeAddressSyntax;
		
		/** */
		public var input:Array;
		
		/** */
		public var output:Array;
		
		/** */
		public var interpolations:Array;
		
		/** */
		public var curves:Array;
		
		/**
		 * 
		 * @param	node
		 *  
		 * @return
		 */
		public function DaeChannel( node:XML ):void
		{
			super( node );
			
			this.curves = new Array();
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		override public function read( node:XML ):void
		{							
			if( node.localName() != ASCollada.DAE_CHANNEL_ELEMENT )
				throw new Error( "expected a '" + ASCollada.DAE_CHANNEL_ELEMENT + "' element" );
				
			super.read( node );
			
			this.source = getAttribute(node, ASCollada.DAE_SOURCE_ATTRIBUTE);
			this.target = getAttribute(node, ASCollada.DAE_TARGET_ATTRIBUTE);
			
			this.syntax = DaeAddressSyntax.parseAnimationTarget(this.target);
		}
		
		/**
		 * 
		 */
		public function createCurves(numCurves:uint = 12):void
		{
			var i:int, j:int;
			
			this.curves = new Array();
				
			var targetObject:String = this.target.split("/")[1];
			if( targetObject.indexOf(".") != -1 )
				targetObject = targetObject.split(".")[0];
				
			switch( targetObject )
			{
				case "transform":
					break;
				case "rotateX":
					numCurves = 1;
					break;
				case "rotateY":
					numCurves = 1;
					break;
				case "rotateZ":
					numCurves = 1;
					break;
				default:
					return;
			}
			
			for( i = 0; i < numCurves; i++ )
				this.curves.push( new DaeAnimationCurve() );
				
			if( this.output[0] is Array )
			{
				for( i = 0; i < this.output.length; i++ )
				{				
					for( j = 0; j < this.curves.length; j++ )
					{
						this.curves[j].keys[i] = this.input[i];
						this.curves[j].keyValues[i] = this.output[i][j];
					}
				}
			}
			else if( numCurves == 1 )
			{
				for( i = 0; i < this.output.length; i++ )
				{				
					this.curves[0].keys[i] = this.input[i];
					this.curves[0].keyValues[i] = this.output[i];
				}
			}
		}
		
		/**
		 * 
		 * @param	dt
		 */
		public function update( dt:Number ):Array
		{
			if( !this.curves ) return null;
			var arr:Array = new Array( this.curves.length );
			for( var i:int = 0; i < this.curves.length; i++ )
				arr[i] = this.curves[i].evaluate(dt);
			return arr;
		}
	}
}