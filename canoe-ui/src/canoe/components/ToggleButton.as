package canoe.components
{
	import flash.events.Event;

	[Event(name="change", type="flash.events.Event")]
	public class ToggleButton extends Button
	{
		private var _selected : Boolean;	
		private var oldSelected : Boolean;
		/**
		 *	获取或设置是否选中 
		 * @return 
		 * 
		 */		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		[Editable]
		public function set selected(value:Boolean):void
		{
			if(selected != value)
			{
				_selected = value;
				invalidateSkinState();
			}
		}
		
		override protected function onMouseReleased():void
		{
			selected = !selected;
		}

		override protected function	get currentSkinState():String
		{
			if(selected)
			{
				return super.currentSkinState + "AndSelected";
			}
			else
			{
				return super.currentSkinState;
			}
		}
		
		
		override public function validate():void
		{
			super.validate();
			
			if(oldSelected != selected)
			{
				dispatchEvent(new Event(Event.CHANGE));
				oldSelected = selected;
			}
		}
	}
}
