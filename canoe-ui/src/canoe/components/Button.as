package canoe.components
{
	import canoe.core.Text;
	import canoe.util.ObjectUtil;
	
	import flash.events.MouseEvent;
	
	public class Button extends SkinnableComponent
	{
		private var enabledChanged : Boolean = true;
		private var hovered : Boolean;
		private var down : Boolean;
		
		private var labelProperties : Object = {
			"text" : ""
		};

		
		[Part]
		public var labelDisplay : Text;
		
		
		
		override public function set enabled(v : Boolean) : void
		{
			if(super.enabled != v)
			{
				super.enabled = v;
				enabledChanged = true;
                invalidate();
			}
		}
		
		/**
		 *	获取或设置按钮标签 
		 * @return 
		 * 
		 */		
		public function get label():String
		{
			if(labelDisplay)
			{
				return labelDisplay.text;
			}
			else
			{
				return labelProperties.text;
			}
		}
		
		[Editable]
		public function set label(value:String):void
		{
			if(labelDisplay)
			{
				labelDisplay.text = value;
			}
			labelProperties.text = value;
		}
        
		override protected function partAdded(instance:Object):void
		{
			if(instance == labelDisplay)
			{
				ObjectUtil.overrideProperties(instance, labelProperties);
			}
		}
		
		
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			hovered = true;
			invalidateSkinState();
			
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
            addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		protected function rollOutHandler(event:MouseEvent):void
		{
			hovered = false;
			down = false;
			invalidateSkinState();
			
			removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		protected function mouseUpHandler(event:MouseEvent):void
		{
			down = false;
			onMouseReleased();
			invalidateSkinState();
		}
		
		protected function onMouseReleased() : void
		{
			
		}
		
		protected function mouseDownHandler(event:MouseEvent):void
		{
			down = true;
			invalidateSkinState();
		}
		
		override protected function get currentSkinState():String
		{
			if(!enabled)
			{
				return "disabled";
			}
			
			if(hovered)
			{
				if(down)
				{
					return "down";
				}
				else
				{
					return "hover";
				}
			}
			else
			{
				return "normal";
			}
		}
		
		override public function validate():void
		{
			super.validate();
			
			if(enabledChanged)
			{
				if(enabled)
				{
					addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				}
				else
				{
					down = false;
					hovered = false;
					removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
					removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				}
                
				enabledChanged = false;
			}
		}
	}
}