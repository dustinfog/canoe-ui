package canoe.studio.extensions
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.TitleWindow;
	
	public class Dialog extends TitleWindow
	{
		public function open(modal : Boolean = false) : void
		{
			if(!isPopUp)
			{
				PopUpManager.addPopUp(this, FlexGlobals.topLevelApplication as DisplayObject, modal);
				PopUpManager.centerPopUp(this);
			}
		}

		public function close() : void
		{
			if(isPopUp && dispatchEvent(new CloseEvent(CloseEvent.CLOSE)))
			{
				PopUpManager.removePopUp(this);
			}
		}
		
		override protected function closeButton_clickHandler(event:MouseEvent):void
		{
			close();
		}
	}
}