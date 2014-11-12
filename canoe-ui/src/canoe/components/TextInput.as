package canoe.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import canoe.core.Text;
	import canoe.util.ObjectUtil;

    [Event(name="change", type="flash.events.Event")]
	[Event(name="complete", type="flash.events.Event")]
	public class TextInput extends SkinnableComponent
	{
		/**
		 *	构造函数 
		 * 
		 */		
        public function TextInput()
		{
			super();
			
			addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
		}
		
		private var focused : Boolean;
		private function focusOutHandler(event:FocusEvent):void
		{
            if(!enabled) return;
			focused = false;
			invalidateSkinState();
		}
		
		private function focusInHandler(event:FocusEvent):void
		{
			if(!enabled) return;
			focused = true;
			invalidateSkinState();	
		}
        
		override protected function get currentSkinState():String
		{
			if(!enabled) return "disabled";
			if(focused)
			{
				return "focused";
			}
			else
			{
				return "normal";
			}
		}
		/**
		 *	输入文本框 
		 */		
		[Part]
		public var textDisplay : Text;
		
		private var textProperties : Object = {
			"text" : ""
		};
		/**
		 *	获取或设置文本的字符串 
		 * @return 
		 * 
		 */		
		public function get text():String
		{
            if(textDisplay)
			{
				return textDisplay.text;
			}
			else
			{
				return textProperties.text;
			}
		}
		
		[Editable]
		public function set text(value:String):void
		{
			if(textDisplay)
			{
				textDisplay.text = value;
			}
			textProperties.text = value;
		}
		/**
		 *	获取或设置为是否password 密码输入框 
		 * @return 
		 * 
		 */		
		public function get displayAsPassword() : Boolean
		{
			if(textDisplay)
			{
				return textDisplay.displayAsPassword;
			}
			else
			{
				return textProperties.displayAsPassword;
			}
		}
		
		[Editable]
		public function set displayAsPassword(v : Boolean) : void
		{
			if(textDisplay)
			{
				textDisplay.displayAsPassword = v;
			}

			textProperties.displayAsPassword = v;
		}
		
		override protected function partAdded(instance:Object):void
		{
			if(instance == textDisplay)
			{
				ObjectUtil.overrideProperties(instance, textProperties);
                textDisplay.addEventListener(Event.COMPLETE, dispatchEvent);
			}
		}
		
		override protected function partRemoved(instance:Object):void
		{
			if(instance == textDisplay)
			{
				ObjectUtil.overrideProperties(instance, textProperties);
				textDisplay.removeEventListener(Event.COMPLETE, dispatchEvent);
			}
		}
	}
}