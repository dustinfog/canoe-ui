package canoe.util
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class HitAreaHelper
	{
		private static const HIT_AREA_CACHE : Dictionary = new Dictionary(true);
		private static const TOLERANCE : Number = 0.5;
		private static const PRECISION : Number = 10;
		
		public function measureHitArea(sprite : Sprite, bitmap : Bitmap) : void
		{
			if(!sprite.contains(bitmap)) return;
			
			var bitmapData : BitmapData = bitmap.bitmapData;
			var tiles : Array = measureTiles(bitmapData);
			
			var hitArea : Sprite = sprite.hitArea;
			if(!hitArea)
			{
				hitArea = new Sprite();
				hitArea.visible = false;
				sprite.hitArea = hitArea;
			}
			
			var g : Graphics = hitArea.graphics;
			g.clear();
			g.beginFill(0);
			
			var hTiles:Array, begin : Boolean;
			for(var i:int = 0;i < tiles.length;i++) {
				hTiles = tiles[i];
				if(!begin && hTiles.length > 0 && hTiles[0] != undefined) {
					g.moveTo(hTiles[0] * PRECISION + PRECISION / 2,i * PRECISION + PRECISION / 2);
					begin = true;
				}
				
				if(begin && hTiles.length > 1)
					g.lineTo(hTiles[1] * PRECISION + PRECISION / 2,i * PRECISION + PRECISION / 2);
			}
			
			for(i = tiles.length - 1;i >= 0;i--) {
				hTiles = tiles[i];
				if(hTiles.length > 0 && hTiles[0] != undefined)
					g.lineTo(hTiles[0] * PRECISION + PRECISION / 2,i * PRECISION + PRECISION / 2);
			}
			
			g.endFill();
			
			var bitmapBounds : Rectangle = bitmap.getBounds(sprite);
			hitArea.x = bitmapBounds.x;
			hitArea.y = bitmapBounds.y;
			if(!hitArea.parent)
			{
				sprite.addChild(hitArea);
			}
		}

		private function measureTiles(bitmapData : BitmapData) : Array
		{
			var tiles : Array = HIT_AREA_CACHE[bitmapData];
			if(tiles) return tiles;
			
			tiles = [];
			
			var hCount : int = bitmapData.width / PRECISION;
			var vCount : int = bitmapData.height / PRECISION;

			var rect : Rectangle = new Rectangle(0, 0, PRECISION, PRECISION);
			for(var i : int = 0; i < vCount; i ++)
			{
				tiles[i] = [];
				var leftLimit : int = 0;
				var pixels : Vector.<uint>, alphaTotal : uint, color : uint;
				for(var j : int = 0; j < hCount; j ++)
				{
					rect.x = PRECISION * j;
					rect.y = PRECISION * i;
					
					pixels = bitmapData.getVector(rect);
					alphaTotal = 0;
					for each(color in pixels)
					{
						alphaTotal += (color >> 24 & 0xFF);
					}
					
					if(alphaTotal / (255 * pixels.length) > TOLERANCE)
					{
						tiles[i][0] = j;
						leftLimit = j;
						break;
					}
				}
				
				for(j = hCount -1; j > leftLimit; j --)
				{
					rect.x = PRECISION * j;
					rect.y = PRECISION * i;
					
					pixels = bitmapData.getVector(rect);
					alphaTotal = 0;
					for each(color in pixels)
					{
						alphaTotal += (color >> 24 & 0xFF);
					}
					
					if(alphaTotal / (255 * pixels.length) > TOLERANCE)
					{
						tiles[i][1] = j;
						break;
					}
				}
			}

			HIT_AREA_CACHE[bitmapData] = tiles;
			return tiles;
		}
	}
}