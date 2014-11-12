package canoe.sample.view{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import canoe.core.CanoeGlobals;
	import canoe.events.CanoeEvent;
	import canoe.util.Singleton;

	public class MainView extends _MainView{

		override protected function create():void{
			super.create();
			
			data = 1;
			button.addEventListener(MouseEvent.CLICK, button_clickHandler);
			paginator.addEventListener(CanoeEvent.VALUE_COMMIT, paginator_valueCommitedHandler);
			loginView.addEventListener(MouseEvent.CLICK, login_clickHandler);
			
			list.addEventListener(CanoeEvent.INDEX_CHANGED, indexChangedHandler);			
			rbg.addEventListener(CanoeEvent.VALUE_COMMIT, rgb_valueCommitHandler);
		}
		
		protected function rgb_valueCommitHandler(event:Event):void
		{
			trace("###", rbg.value);
		}
		
		protected function indexChangedHandler(event:CanoeEvent):void
		{
			list.refresh();
		}
		
		protected function paginator_valueCommitedHandler(event:CanoeEvent):void
		{
			list.dataProvider = paginator.items;
		}
		
		protected function button_clickHandler(event:MouseEvent):void
		{
			TestView(Singleton.getInstance(TestView)).open();
		}
		
		protected function login_clickHandler(event:MouseEvent):void
		{
			var main : Main = CanoeGlobals.application as Main;
			main.switchView(LoginView);
		}
	}
}
