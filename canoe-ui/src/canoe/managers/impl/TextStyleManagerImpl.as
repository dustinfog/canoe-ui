package canoe.managers.impl
{
	import canoe.core.Text;
	import canoe.events.CanoeEvent;
	import canoe.managers.ITextStyleManager;
	import canoe.core.TextStyle;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.text.TextFormat;
	
	[Event(name="textStyleUpdated", type="canoe.events.CanoeEvent")]
	public class TextStyleManagerImpl extends EventDispatcher implements ITextStyleManager
	{
		private const styleSheet : StyleSheet = new StyleSheet();
		private var _defaultStyle : TextStyle;
		
		public function set defaultStyle(v : TextStyle) : void
		{
			_defaultStyle = v;
			dispatchUpdatedEvent();
		}
		
		public function get defaultStyle() : TextStyle
		{
			return _defaultStyle;
		}
		
		public function setStyle(name : String, style : TextStyle) : void
		{
			styleSheet.setStyle(name, style);
			dispatchUpdatedEvent();
		}
		
		public function getStyle(name : String) : TextStyle
		{
			var style : Object = styleSheet.getStyle(name);
			if(style != null && style["constructor"] != TextStyle)
			{
				style = TextStyle.inheritFrom(style);
				styleSheet.setStyle(name, style);
			}
			
			return TextStyle(style);
		}
		
		public function load(url : URLRequest):void
		{
			var loader : URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loader_completeHandler);
			loader.load(url);
		}
		
		public function transform(style : TextStyle) : TextFormat
		{
			return styleSheet.transform(style);
		}
		
		public function applyTextStyle(text : Text) : void
		{
			var style : TextStyle = TextStyle.inheritFrom(defaultStyle); 
			var styleName : String = text.styleName;
			if(styleName)
			{
				style.inherits(styleSheet.getStyle(styleName));
			}
			
			if(text.style)
			{
				style.inherits(text.style);
			}

			text.defaultTextFormat = transform(style);
		}

		private function loader_completeHandler(event : Event) : void
		{
			var loader : URLLoader = URLLoader(event.currentTarget);
			styleSheet.parseCSS(loader.data);
			var style : Object = styleSheet.getStyle("*");
			if(style)
			{
				defaultStyle = TextStyle.inheritFrom(style);
			}
			
			dispatchUpdatedEvent();
		}
		
		private function dispatchUpdatedEvent() : void
		{
			dispatchEvent(new CanoeEvent(CanoeEvent.TEXT_STYLE_UPDATED));
		}
	}
}