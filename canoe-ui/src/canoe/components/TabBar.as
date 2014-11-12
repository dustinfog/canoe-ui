package canoe.components
{
	import canoe.components.support.ListBase;
	import canoe.layout.HLayout;
	
	public class TabBar extends ListBase
	{
		/**
		 *	构造函数 
		 * 
		 */		
		public function TabBar()
		{
			super();
		
			var hlayout : HLayout = new HLayout();
			hlayout.paddingLeft = 2
			hlayout.gap = 0;
			
			layout = hlayout;
		}
		
		override public function validate():void
		{
			super.validate();
			
			if(dataProvider && dataProvider.length > 0 && selectedIndex == -1)
			{
				selectedIndex = 0;
			}
		}
	}
}