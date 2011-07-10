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
	import by.blooddy.crypto.image.PNG24Encoder;	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	/**
	 * Class for encoding data to AMB format
	 * @author Poluosmak Andrew 
	 */	
	public class SNGEncoder
	{
		/**
		 * Encoding SpriteSheet data to AMB format
		 * 
		 * @param source SpriteSheetCreationUtils object
		 * @return AMB data in ByteArray
		 */
		static public function encodeToAMB(source:SpriteSheetCreationUtils):ByteArray
		{
			source.regenerateBitmapPositions();
			
			var originalBytes:ByteArray = PNG24Encoder.encode(source.originalSource);
			
			// create ABM ByteArray
			var SNG:ByteArray = new ByteArray();
			
			// write version
			SNG.writeUnsignedInt(source.version);
			
			// write frames count
			SNG.writeUnsignedInt(source.totalFrames);
			
			// write item width
			SNG.writeUnsignedInt(source.width);
			
			// write item height
			SNG.writeUnsignedInt(source.height);
			
			// write lenght bytes for original picture
			SNG.writeUnsignedInt(originalBytes.length);
			
			// write original picture 
			SNG.writeBytes(originalBytes, 0, originalBytes.bytesAvailable);
			
			// write xOffset for sheet
			SNG.writeInt(source.minXOffset);
			
			// write yOffset for sheet
			SNG.writeInt(source.minYOffset);
			
			// write spritesheet data
			//AMB.writeBytes(sheetBytes, 0, sheetBytes.bytesAvailable);
			
			for(var i:int = 0; i < source.frameSources.length; i++){
				writeSpriteSheetItem(SNG, source.frameSources[i]);
			}
			
			// compress
			SNG.compress();
			
			return SNG;
		}
		
		/**
		 * Write one item at seuence animation
		 * @param source
		 * @param bitmapdata
		 * @private 
		 */		
		static protected function writeSpriteSheetItem(source:ByteArray, bitmapdata:BitmapData):void
		{
			var chunkBA:ByteArray = PNG24Encoder.encode(bitmapdata);
			source.writeUnsignedInt(chunkBA.length);
			
			chunkBA.position = 0;
			source.writeBytes(chunkBA, 0, chunkBA.bytesAvailable);
		}
		
		/**
		 * Compare two bitmap data object and create new item for sritesheet item.
		 * Use this function for create items to at SpriteSheetCreationUtils object
		 * 
		 * @param source1 previous item sequence. For first item in seuqnce use original image
		 * @param source2 current item sequence
		 * @return BitmapData item
		 */
		static public function compareData(source1:BitmapData, source2:BitmapData):BitmapData
		{
			if(source1.width != source2.width){
				throw new Error( "width of source data should be the same" );
				return null;
			}
			
			if(source1.height != source2.height){
				throw new Error( "height of source data should be the same" );
				return null;
			}
			
			var t1:int = new Date().getTime();
			
			var compared:* = source1.compare(source2) as BitmapData;
			
			if(compared != null && compared != -4){ 
				
				var x:int = 0;
				var y:int = 0;
				var totalWidth:int = (compared as BitmapData).width;
				var totalHeight:int = (compared as BitmapData).height;
				
				var itemSheet:BitmapData = new BitmapData(totalWidth, totalHeight, true, uint.MIN_VALUE);
				
				for(x = 0; x < totalWidth; x++){ 
					for(y = 0; y < totalHeight; y++){						
						if((compared as BitmapData).getPixel32(x, y) != 0){
							itemSheet.setPixel32(x, y, source2.getPixel32(x, y));
						}
					}
				}
				
				return itemSheet;
				
			} else {
				return null;
			}
			
			return null;
		}
	}
}