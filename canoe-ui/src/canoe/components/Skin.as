package canoe.components
{
	import flash.events.Event;
	
	import canoe.events.StateEvent;
	import canoe.util.FilterUtil;
	
	public class Skin extends Container
	{
		/**
		 *	构造函数 
		 * 
		 */		
        public function Skin()
		{
			super();
			addEventListener(StateEvent.STATE_CHANGE, stateChangeHandler);
		}
		
		protected function stateChangeHandler(event:Event):void
		{
			if(host && !host.enabled)
			{
				FilterUtil.addFilters(this, FilterUtil.grayFilter);
			}
			else
			{
				FilterUtil.removeFilters(this, FilterUtil.grayFilter);
			}	
		}
		/**
		 *	获取父类 作为 SkinableComponet
		 * @return 
		 * 
		 */        
		public function get host():SkinnableComponent
		{
			return parent as SkinnableComponent;
		}

		override public function invalidate() : void
		{
			super.invalidate();
			if(host)
			{
				host.invalidate();
			}
		}
		
		override public function invalidateParentLayout():void
		{
			super.invalidateParentLayout();
			if(host)
			{
				host.invalidateParentLayout();
			}
		}
	}
}