package canoe.layout
{
	import canoe.core.IElement;
	import canoe.layout.support.RegularLayoutBase;
	
	public class TileLayout extends RegularLayoutBase
	{
		private var _tileWidth : Number;
		private var _tileHeight : Number;
		private var _hGap : Number = 5;
		private var _vGap : Number = 5;

		private var explicitTileWidth : Number;
		private var explicitTileHeight : Number;
		private var cols : uint;
		
		public function get vGap():Number
		{
			return _vGap;
		}

		public function set vGap(value:Number):void
		{
			if(vGap != value)
			{
				_vGap = value;
				invalidate();
			}
		}

		public function get hGap():Number
		{
			return _hGap;
		}

		public function set hGap(value:Number):void
		{
			if(hGap != value)
			{
				_hGap = value;
				invalidate();
			}
		}

		public function get tileHeight():Number
		{
			return isNaN(explicitTileHeight) ? _tileHeight : explicitTileHeight;
		}

		public function set tileHeight(value:Number):void
		{
			if(explicitTileHeight != value)
			{
				explicitTileHeight = value;
				invalidate();
			}
		}

		public function get tileWidth():Number
		{
			return isNaN(explicitTileWidth) ? _tileWidth : explicitTileWidth;
		}

		public function set tileWidth(value:Number):void
		{
			if(explicitTileWidth != value)
			{
				explicitTileWidth = value;
				invalidate();
			}
		}
		
		override protected function doUpdateLayout() : void
		{
			for(var i : uint = 0; i < layoutElements.length; i ++)
			{
				var child : IElement = layoutElements[i];
				child.measuredWidth = tileWidth;
				child.measuredHeight = tileHeight;
				
				var col : int = i % cols;
				var row : int = i / cols;
				child.x = paddingLeft + col * (tileWidth + hGap);
				child.y = paddingTop + row * (tileHeight + vGap);
			}
		}
		
		override protected function measureSize() : void
		{
			measureTileSize();
			
			container.contentWidth = 0;
			if(container.width != 0)
			{
				var validWidth : Number = container.width - paddingLeft - paddingRight + hGap;
				cols = Math.floor(validWidth / tileWidth) || 1;
				
				var tileRows : uint = Math.ceil(layoutElements.length / cols);
				container.contentHeight = paddingTop + tileRows * (tileHeight + vGap) - vGap + paddingBottom;
			}
			else
			{
				cols = layoutElements.length;
				container.contentHeight = paddingTop + tileHeight + paddingBottom;
			}
			
			container.contentWidth = paddingLeft + cols * (tileWidth + hGap) - hGap + paddingRight;
		}
		
		private function measureTileSize() : void
		{
			if(!isNaN(explicitTileWidth) && !isNaN(explicitTileHeight)) return;
			
			_tileWidth = 0;
			_tileHeight = 0;
			for each(var child : IElement in layoutElements)
			{
				if(isNaN(explicitTileWidth))
				{
					child.measuredWidth = NaN;
					_tileWidth = Math.max(child.measuredWidth, _tileWidth);
				}
				
				if(isNaN(explicitTileHeight))
				{
					child.measuredHeight = NaN;
					_tileHeight = Math.max(child.measuredHeight, _tileHeight);
				}
			}
		}
	}
}