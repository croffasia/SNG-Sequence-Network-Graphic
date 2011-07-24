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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class SNGAnimator extends Sprite
	{
		public static const DEFAULT_STATE:String = "all";
		
		/**
		 * @private 
		 */
		private var _ambObject:SNGObject;
		
		/**
		 * @private 
		 */
		private var _currentFrame:int = 1;
		
		/**
		 * @private 
		 */
		private var _sourceBitmap:Bitmap;
		
		/**
		 * cached frames
		 * @private 
		 */		
		private var _cached:Dictionary = new Dictionary(true);
		
		/**
		 * Animation states
		 * @private 
		 */	
		private var _states:Dictionary = new Dictionary(true); 
		
		/**
		 * Current played state
		 * @private 
		 */	
		private var _currentState:String = DEFAULT_STATE;
		
		/**
		 * Constructor
		 * @param object SNGObject for animation
		 */
		public function SNGAnimator(object:SNGObject)
		{
			_ambObject = object;
			
			_sourceBitmap = new Bitmap();
			
			var bd:BitmapData = new BitmapData(_ambObject.width  + _ambObject.xOffset, _ambObject.height + _ambObject.yOffset, true, uint.MIN_VALUE);
			bd.draw(_ambObject.firstData);
			
			_sourceBitmap.bitmapData = bd;
			_sourceBitmap.smoothing = true;

			addChild(_sourceBitmap);	
			
			_states[DEFAULT_STATE] = {start: 1, end: _ambObject.totalFrames};
		}
		
		/**
		 * Add new state for playing partial animation 
		 * @param name state name
		 * @param startFrame start frame
		 * @param endFrame finish frame 
		 */		
		public function addState(name:String, startFrame:int, endFrame:int):void
		{
			if(startFrame <= 0 || startFrame >= _ambObject.totalFrames)
				return;
			
			if(endFrame <= 0 || endFrame > _ambObject.totalFrames)
				return;			
			
			_states[name] = {start: startFrame, end: endFrame};
		}
		
		/**
		 * Get state information
		 */
		public function getStateInfo(name:String = ""):Object
		{
			if(name == "")
				name = _currentState;
			
			return _states[name];
		}
		
		/**
		 * Play state
		 * @param name 
		 */		
		public function playState(name:String):void
		{
			if(_states[name] != null){
				
				stop();				
				
				_currentState = name;
				
				play(_states[name].start);
			}
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function get height():Number
		{
			if(_ambObject != null)
				return _ambObject.height;
			else
				return super.height; 
		}
		
		/**
		 * @inheritDoc 
		 */
		override public function get width():Number
		{
			if(_ambObject != null)
				return _ambObject.width;
			else
				return super.width; 
		}

		/**
		 * Play animation
		 * @param frame 
		 */		
		public function play(frame:Number = -1):void
		{
			if(frame > 0 && frame <= _ambObject.totalFrames)
				_currentFrame = frame;
				
			if(!hasEventListener(Event.ENTER_FRAME))
				addEventListener(Event.ENTER_FRAME, onEnterFrame);			
		}
		
		/**
		 * Stop playing 
		 */		
		public function stop():void 
		{
			if(hasEventListener(Event.ENTER_FRAME))
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);				
		}

		/**
		 * @private 
		 */
		protected function onEnterFrame(event:Event):void
		{
			draw();
			
			_currentFrame++; 
									
			if(_currentFrame > _states[_currentState].end){
				_currentFrame =  _states[_currentState].start;
			}
			
			if(_ambObject.totalFrames < _currentFrame){
				if(_currentState == DEFAULT_STATE)
					_currentFrame = _states[DEFAULT_STATE].start;
			}
		}
		
		/**
		 * @private 
		 */
		protected function draw():void
		{
			if(_cached[_currentFrame] == null){
				if(_ambObject != null && _sourceBitmap != null){
					var bytes:ByteArray = _ambObject.sheetItems[_currentFrame - 1].getPixels(_ambObject.sheetItems[_currentFrame - 1].rect);
					bytes.position = 0;
					
					var bytes2:ByteArray = _sourceBitmap.bitmapData.getPixels(new Rectangle(_ambObject.xOffset, _ambObject.yOffset, _ambObject.sheetItems[_currentFrame - 1].rect.width, _ambObject.sheetItems[_currentFrame - 1].rect.height));
					bytes2.position = 0;
					
					var pixel:uint;
					var pos:int = 0;
					while(bytes.bytesAvailable > 0){
						pixel = bytes.readUnsignedInt();						
						if(pixel != 0){
							// set position in previous byte
							bytes2.position = bytes.position - 4;
							bytes2.writeUnsignedInt(pixel);
						}
					}
					
					bytes2.position = 0;					
					_sourceBitmap.bitmapData.setPixels(new Rectangle(_ambObject.xOffset, _ambObject.yOffset, _ambObject.sheetItems[_currentFrame - 1].rect.width, _ambObject.sheetItems[_currentFrame - 1].rect.height), bytes2);
		
					_cached[_currentFrame] = _sourceBitmap.bitmapData.clone();
					
					_sourceBitmap.smoothing = true;
				}
			} else {
				_sourceBitmap.bitmapData = _cached[_currentFrame];
				_sourceBitmap.smoothing = true;
			}
		}
		
		/**
		 * Animation Frame Rate
		 * @return int 
		 */		
		public function get frameRate():int
		{
			return this.stage.frameRate;
		}
		
		/**
		 * @private 
		 */
		public function set frameRate(value:int):void
		{
			this.stage.frameRate = value;
		}
		
		/**
		 * Total frames
		 * @rerutn int 
		 */
		public function get totalFrames():int
		{
			return _ambObject.totalFrames;
		}

		/**
		 * Current frame
		 * @private 
		 */
		public function get currentFrame():int
		{
			return _currentFrame;
		}
	}
}