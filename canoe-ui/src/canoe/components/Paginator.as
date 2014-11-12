package canoe.components
{
	import canoe.components.support.Range;
	import canoe.events.CanoeEvent;
	
	import flash.events.Event;
	
	public class Paginator extends Range
	{
		/**
		 *	构造函数。 
		 * 
		 */			
		public function Paginator()
		{
			super();
			continuousEnabled = false;
			addEventListener(CanoeEvent.VALUE_COMMIT, valueCommitHandler, false); 
			
			minimum = 1;
			maximum = 1;
			value = 1;
		}
		
		private var _dataProvider : Array;
		private var _pageSize : int = 5;
		private var _items : Array;
		
		/**
		 * 	获取数据内容Array
		 * @return 
		 * 
		 */		
		public function get items():Array
		{
			return _items;
		}
		/**
		 *	 获取或设置页面大小
		 */		
		[Editable]
		public function get pageSize():int
		{
			return _pageSize;
		}

		public function set pageSize(value:int):void
		{
			if(pageSize != value)
			{
				_pageSize = value;
				calcLimit();
			}
		}

		/**
		 *	获取或设置绑定的数据
		 * @return 
		 * 
		 */		
		public function get dataProvider():Array
		{
			return _dataProvider;
		}
		
		[Editable]
		public function set dataProvider(value:Array):void
		{
			_dataProvider = value;
			calcLimit();
		}	
		
		protected function valueCommitHandler(event:Event):void
		{
			if(dataProvider)	
			{
				var startIndex : int = (value - 1) * pageSize;
				var endIndex : int = value * pageSize;
				
				_items = dataProvider.slice(startIndex, endIndex);
			}
		}
		
		private function calcLimit() : void
		{
			if(dataProvider)
			{
				minimum = 1;
				maximum = Math.ceil(dataProvider.length / pageSize);
			}
		}
	}
}