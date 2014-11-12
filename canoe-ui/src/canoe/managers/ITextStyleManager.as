package canoe.managers
{
	import canoe.core.Text;
	
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import canoe.core.TextStyle;
	
	[Event(name="textStyleUpdated", type="canoe.events.CanoeEvent")]
	public interface ITextStyleManager extends IEventDispatcher
	{
		function set defaultStyle(v : TextStyle) : void;
		function get defaultStyle() : TextStyle;
		function setStyle(name : String, style : TextStyle) : void;
		function getStyle(name : String) : TextStyle;
		function load(url : URLRequest):void;
		function applyTextStyle(text : Text) : void;
		function transform(style : TextStyle) : TextFormat;
	}
}