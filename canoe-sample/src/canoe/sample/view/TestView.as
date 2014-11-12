package canoe.sample.view{
	import canoe.events.CanoeEvent;
	
	import flash.events.MouseEvent;

	public class TestView extends _TestView{

		override protected function create():void{
			super.create();
			
			tabBar.addEventListener(CanoeEvent.INDEX_CHANGED, tabBar_indexChangedHandler);
			alertButton.addEventListener(MouseEvent.CLICK, alertButton_clickHandler);
		}
		
		protected function alertButton_clickHandler(event:MouseEvent):void
		{
			confirm("背首诗吧？", function() : void{
				alert("千山鸟飞绝，\n万径人踪灭，\n孤舟蓑笠翁，\n独钓寒江雪");
				alert("这首诗体现了诗人吃饱了撑的没事儿干，跑冰窟窿里钓鱼去的闲情雅致");
				confirm("服不服？", null, function(): void
				{
					alert("真没品");
				});
			});
		}
		
		protected function tabBar_indexChangedHandler(event:CanoeEvent):void
		{
			viewStack.selectedIndex = tabBar.selectedIndex;
		}
	}
}
