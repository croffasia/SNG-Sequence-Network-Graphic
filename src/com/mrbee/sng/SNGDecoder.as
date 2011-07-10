/******************************************************************
 * SNG - Sequence Network Graphic
 * Copyright (C) 2011 Mr.Bee, LLC
 * For more information see http://www.mrbee.com.ua
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this lib.
 ****************************************************************/
package com.mrbee.sng
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;
	
	/**
	 * Class for decoding AMB data format
	 * @author Andrew 
	 */	
	public class SNGDecoder
	{
		/**
		 * Finish decoding callback. Callback must accept one parametr - ambContent:AMBObject
		 */		
		private var _callback:Function;
		
		/**
		 * @private 
		 */		
		private var _AMB:SNGObject;
		
		/**
		 * Decoding AMB data format
		 * @param source ByteArray source
		 * @param callback finish decoding callback. Callback must accept one parametr - ambContent:AMBObject
		 */		
		public function decode(source:ByteArray, callback:Function):void
		{
			_callback = callback;
			
			source.uncompress();
			
			_AMB = new SNGObject();
			
			// set position to 0 byte
			source.position = 0;
			
			// read version
			_AMB.version = source.readUnsignedInt();
				
			// read frames count
			_AMB.totalFrames = source.readUnsignedInt();
			
			// read item width
			_AMB.width = source.readUnsignedInt();
			
			// read item height
			_AMB.height = source.readUnsignedInt();
						
			// read original item bytes
			var originalBytes:uint = source.readUnsignedInt();
			
			// write spritesheet data
			var originalByteArray:ByteArray = new ByteArray();
			source.readBytes(originalByteArray, 0, originalBytes);
			
			// load original bitmap
			var loaderOriginal:Loader = new Loader();
			loaderOriginal.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{
				
				Loader(e.currentTarget.loader).removeEventListener(e.type, arguments.callee); 				
				_AMB.firstData = ((e.currentTarget as LoaderInfo).content as Bitmap).bitmapData;				
				
			});
			loaderOriginal.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loaderOriginal.loadBytes(originalByteArray);
			
			// read xOffset items
			_AMB.xOffset = source.readUnsignedInt();
			
			// read yOffset items
			_AMB.yOffset = source.readUnsignedInt();
			
			// decode sheet items
			decodeSpriteSheetContent(source);
		}	
		
		/**
		 * Decode all sheet items bitmap
		 * @param source
		 * @private 
		 */		
		protected function decodeSpriteSheetContent(source:ByteArray):void
		{
			if(source.bytesAvailable > 0){
				var itemLength:uint = source.readUnsignedInt();
				var itemByteArray:ByteArray = new ByteArray();
				source.readBytes(itemByteArray, 0, itemLength);
				
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{
				
					Loader(e.currentTarget.loader).removeEventListener(e.type, arguments.callee); 
					
					_AMB.sheetItems.push(((e.currentTarget as LoaderInfo).content as Bitmap).bitmapData);					
					decodeSpriteSheetContent(source);
					
				});
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.loadBytes(itemByteArray);
			} else {
				_callback(_AMB);						
				_callback = null;
			}
		}
		
		/**
		 * @private 
		 */
		protected function onError(event:IOErrorEvent):void
		{
			Loader(event.currentTarget.loader).removeEventListener(event.type, onError);
			trace("Error load: "+event.errorID+" "+event.text);
		}
	}
}