package canoe.layout.support
{
	public class StraightLayoutBase extends RegularLayoutBase
	{
		private var _gap : Number = 5;
		private var _vAlign : String;
		private var _hAlign : String;
		
		public function get gap():Number
		{
			return _gap;
		}
		
		public function set gap(value:Number):void
		{
			if(_gap != value)
			{
				_gap = value;
				invalidate();
			}
		}	
		
		public function get hAlign():String
		{
			return _hAlign;
		}
		
		public function set hAlign(value:String):void
		{
			if(_hAlign != value)
			{
				_hAlign = value;
				invalidate();
			}
		}
		
		public function get vAlign():String
		{
			return _vAlign;
		}
		
		public function set vAlign(value:String):void
		{
			if(_vAlign != value)
			{
				_vAlign = value;
				invalidate();
			}
		}
	}
}