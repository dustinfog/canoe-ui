package canoe.layout.support
{
	public class RegularLayoutBase extends LayoutBase
	{
		private var _paddingLeft : Number = 5;
		private var _paddingRight : Number = 5;
		private var _paddingTop : Number = 5;
		private var _paddingBottom : Number = 5;
		
		public function get paddingBottom():Number
		{
			return _paddingBottom;
		}
		
		public function set paddingBottom(value:Number):void
		{
			if(_paddingBottom != value)
			{
				_paddingBottom = value;
				invalidate();
			}
		}
		
		public function get paddingTop():Number
		{
			return _paddingTop;
		}
		
		public function set paddingTop(value:Number):void
		{
			if(_paddingTop != value)
			{
				_paddingTop = value;
				invalidate();
			}
		}
		
		public function get paddingRight():Number
		{
			return _paddingRight;
		}
		
		public function set paddingRight(value:Number):void
		{
			if(_paddingRight != value)
			{
				_paddingRight = value;
				invalidate();
			}
		}
		
		public function get paddingLeft():Number
		{
			return _paddingLeft;
		}
		
		public function set paddingLeft(value:Number):void
		{
			if(_paddingLeft != value)
			{
				_paddingLeft = value;
				invalidate();
			}
		}
	}
}