package canoe.components
{
	import canoe.asset.AssetURI;
	import canoe.asset.IAssetLoader;
	import canoe.asset.SymbolMeta;
	import canoe.core.Image;
	import canoe.managers.AssetManager;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[Event(name="complete", type="flash.events.Event")]
	public class AssetImage extends Image
	{
		/**
		 *  构造函数 
		 * @param uri
		 * @param pixelSnapping
		 * @param smoothing
		 * 
		 */		
		
		public function AssetImage(uri : String = null, pixelSnapping:String="auto", smoothing:Boolean=false)
		{
			super(null, pixelSnapping, smoothing);
			this.uri = uri;
		}
		
		private var _uri : String;
		private var assetURI : AssetURI;
		private var symbolName : String;
		
		private var _sliceRows : uint = 1;
		private var _sliceCols : uint = 1;
		private var _sliceX : uint = 0;
		private var _sliceY : uint = 0;
		private var _explicitX : Number;
		private var _explicitY : Number;

		/**
		 *	获取Y轴修正值 
		 * @return 
		 * 
		 */		
		public function get explicitY():Number
		{
			return _explicitY;
		}

		/**
		 * 获取x轴修正
		 * @return 
		 * 
		 */		
		public function get explicitX():Number
		{
			return _explicitX;
		}
		
		override public function set x(v : Number) : void
		{
			_explicitX = v;
			super.x = v;
		}
		
		override public function set y(v:Number):void
		{
			_explicitY = v;
			super.y = v;
		}

		/**
		 * 获取或设置 y轴切片索引 
		 * @return 
		 * 
		 */		
		public function get sliceY():uint
		{
			return _sliceY;
		}
		
		[Editable]
		public function set sliceY(value:uint):void
		{
			if(sliceY != value)
			{
				_sliceY = value;
				measureClipRect();
			}
		}

		/**
		 *	获取或设置x轴切片索引 
		 * @return 
		 * 
		 */		
		public function get sliceX():uint
		{
			return _sliceX;
		}
		
		[Editable]
		public function set sliceX(value:uint):void
		{
			if(sliceX != value)
			{
				_sliceX = value;
				measureClipRect();
			}
		}

		/**
		 *	获取或设置切片的列数 
		 * @return 
		 * 
		 */		
		public function get sliceCols():uint
		{
			return _sliceCols || 1;
		}

		public function set sliceCols(value:uint):void
		{
			if(sliceCols != value)
			{
				_sliceCols = value;
				measureClipRect();
			}
		}

		/**
		 *	获取或设置切片的行数 
		 * @return 
		 * 
		 */		
		public function get sliceRows():uint
		{
			return _sliceRows || 1;
		}

		public function set sliceRows(value:uint):void
		{
			if(sliceRows != value)
			{
				_sliceRows = value;
				measureClipRect();
			}
		}
		
		override public function set bitmapData(v : BitmapData) : void
		{
			super.bitmapData = v;
			measureClipRect();
		}
		
		/**
		 *	获取或设置uri 图片地址 
		 */		
		[Editable]
		public function get uri():String
		{
			return _uri;
		}

		public function set uri(value:String):void
		{
			if(uri != value)
			{
				_uri = value;
				
				var newAssetURI : AssetURI = (uri == null ? null : AssetURI.parse(uri));
				
				if(newAssetURI == null || !newAssetURI.equals(assetURI))
				{
					if(assetURI != null)
					{
						AssetManager.unbind(assetURI, bindHandler);
						symbolName = null;
					}

					if(newAssetURI != null)
					{
						symbolName = newAssetURI.symbolName;
						AssetManager.bind(newAssetURI, bindHandler);
					}

					assetURI = newAssetURI;
				}
			}
		}
		
		private function bindHandler(symbol : BitmapData, assetLoader : IAssetLoader) : void
		{
			bitmapData = symbol;

			var symbolMeta : SymbolMeta = assetLoader.getSymbolMeta(symbolName);
			if(symbolMeta)
			{
				scale9Grid = symbolMeta.scale9Grid;
				sliceRows = symbolMeta.sliceRows;
				sliceCols = symbolMeta.sliceCols;
				var corePoint : Point = symbolMeta.corePoint;
				if(corePoint)
				{
					if(isNaN(explicitX))super.x = - corePoint.x;
					if(isNaN(explicitY))super.y = - corePoint.y;
				}
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function measureClipRect() : void
		{
			if(bitmapData)
			{
				if(sliceRows > 1 || sliceCols > 1)
				{
					var actualSliceX : uint = Math.min(sliceX, sliceCols - 1);
					var actualSliceY : uint = Math.min(sliceY, sliceRows - 1);
					
					var sliceWidth : Number = bitmapData.width / sliceCols;
					var sliceHeight : Number = bitmapData.height / sliceRows;
					
					clipRect = newRectangle(actualSliceX * sliceWidth, actualSliceY * sliceHeight, sliceWidth, sliceHeight);
				}
				else
				{
					clipRect = null;
				}
			}
		}
		
		private var tmpRect : Rectangle = new Rectangle();
		private function newRectangle(x : Number, y : Number, width : Number, height : Number) : Rectangle
		{
			tmpRect.x = x;
			tmpRect.y = y;
			tmpRect.width = width;
			tmpRect.height = height;
			
			return tmpRect;
		}
		
		override public function toString() : String
		{
			return super.toString() + " uri:" + uri;
		}
	}
}