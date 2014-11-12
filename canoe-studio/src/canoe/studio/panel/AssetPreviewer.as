package canoe.studio.panel
{
	import canoe.components.AssetImage;
	
	import flash.events.Event;
	
	import mx.core.UIComponent;

	public class AssetPreviewer extends UIComponent
	{
		private var assetImage : AssetImage;
		public function AssetPreviewer()
		{
			assetImage = new AssetImage();
			assetImage.addEventListener(Event.COMPLETE, completeHandler);
			addChild(assetImage);
		}
		
		private function completeHandler(event:Event):void
		{
			assetImage.x = 0;
			assetImage.y = 0;
			var contentWidth : Number = assetImage.contentWidth;
			var contentHeight : Number = assetImage.contentHeight;
			
			var scale : Number = Math.min(owner.width / contentWidth, owner.height / contentHeight);
			if(scale > 1)
			{
				scale = 1;
			}

			width = scale * contentWidth;
			height = scale * contentHeight;
			
			assetImage.width = width;
			assetImage.height = height;
		}
		
		protected function resizeHandler(event:Event):void
		{
			
		}
		
		public function get uri():String
		{
			return assetImage.uri;
		}

		public function set uri(value:String):void
		{
			assetImage.uri = value;
		}
	}
}