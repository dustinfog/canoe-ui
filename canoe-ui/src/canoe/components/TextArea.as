package canoe.components
{
	import flash.events.Event;

    [Event(name="change", type="flash.events.Event")]
	
	/**
	 *	构造函数 
	 */	
	public class TextArea extends TextInput
	{
		/**
		 *	纵向滚动条vscrollbar 
		 */		
		[Part]
		public var vScrollBar : VScrollBar;
		
		/**
		 *	横向滚动条hsrcollbar 
		 */		
        [Part]
		public var hScrollBar : HScrollBar;
        
		override protected function partAdded(instance:Object):void
		{
            super.partAdded(instance);
			
			if(textDisplay)
			{
				if(vScrollBar)
				{
					vScrollBar.scrollable = textDisplay;
				}
				
				if(hScrollBar)
				{
					hScrollBar.scrollable = textDisplay;
				}
			}
		}

		override protected function partRemoved(instance:Object):void
		{
			if(instance == vScrollBar)
			{
				vScrollBar.scrollable = null;
			}
			else if(instance == hScrollBar)
			{
				hScrollBar.scrollable = null;
			}
			else
			{
				super.partRemoved(instance);
			}
		}
	}
}