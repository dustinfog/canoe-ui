package canoe.managers
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import canoe.managers.impl.PopUpManagerImpl;
	import canoe.util.Singleton;

	public class PopUpManager
	{
		private static var _impl : IPopUpManager;
		private static function get impl() : IPopUpManager
		{
			if(_impl == null)
			{
				_impl = Singleton.getInstance(IPopUpManager, false) || new PopUpManagerImpl();
			}
			
			return _impl;
		}

		public static function get modalMaskAlpha():Number
		{
			return impl.modalMaskAlpha;
		}

		public static function set modalMaskAlpha(value:Number):void
		{
			impl.modalMaskAlpha = value;
		}

		public static function get modalMaskColor():uint
		{
			return impl.modalMaskColor;
		}

		public static function set modalMaskColor(value:uint):void
		{
            impl.modalMaskColor = value; 
		}

		public static function initialize(root : Sprite) : void
		{
			impl.initialize(root);	
		}
		
		public static function addPopUp(popUp : DisplayObject, layer : String, modal : Boolean = false) : void
		{
			impl.addPopUp(popUp, layer, modal);
		}
        
		public static function centerPopUp(popUp : DisplayObject) : void
		{
			impl.centerPopUp(popUp);	
		}
        
		public static function isPopUp(object : DisplayObject) : Boolean
		{
			return impl.isPopUp(object);
		}
		
		public static function isModal(popUp : DisplayObject) : Boolean
		{
			return impl.isModal(popUp); 
		}
		
		public static function topPopUp(popUp : DisplayObject) : void
		{
			impl.topPopUp(popUp);	
		}
		
		public static function removePopUp(popUp : DisplayObject) : void
		{
			impl.removePopUp(popUp);	
		}
		
		public static function attachModal(popUp : DisplayObject) : void
		{
			impl.attachModal(popUp);	
		}
		
		public static function dettachModal(popUp : DisplayObject) : void
		{
			impl.dettachModal(popUp);	
		}
	}
}