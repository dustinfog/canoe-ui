package canoe.studio.extensions
{
	import canoe.managers.IPopUpManager;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;

	public class PopUpManagerImpl implements IPopUpManager
	{
		public function get modalMaskAlpha():Number
		{
			return 0;
		}
		public function set modalMaskAlpha(value:Number):void
		{
		}
		public function get modalMaskColor():uint
		{
			return 0;
		}
		public function set modalMaskColor(value:uint):void
		{
		}
		
		public function initialize(root : Sprite) : void
		{
			
		}

		public function addPopUp(popUp : DisplayObject, layer : String, modal : Boolean = false) : void
		{
			var delegate : UIComponent = new UIComponent();
			delegate.addChild(popUp);
			PopUpManager.addPopUp(delegate, Main(FlexGlobals.topLevelApplication), modal);
		}
		
		public function centerPopUp(popUp : DisplayObject) : void
		{
			
		}
		
		public function isPopUp(object : DisplayObject) : Boolean
		{
			var delegate : UIComponent = object.parent as UIComponent;
			return delegate != null && delegate.isPopUp;
		}
		
		public function isModal(popUp : DisplayObject) : Boolean
		{
			return false;
		}
		
		public function topPopUp(popUp : DisplayObject) : void
		{
			PopUpManager.bringToFront(UIComponent(popUp.parent));
		}
		
		public function removePopUp(popUp : DisplayObject) : void
		{
			if(isPopUp(popUp))
			{
				var delegate : UIComponent = popUp.parent as UIComponent;
				delegate.removeChild(popUp);
				PopUpManager.removePopUp(delegate);
			}
		}
		
		public function attachModal(popUp : DisplayObject) : void
		{
			
		}
		public function dettachModal(popUp : DisplayObject) : void
		{
			
		}
	}
}