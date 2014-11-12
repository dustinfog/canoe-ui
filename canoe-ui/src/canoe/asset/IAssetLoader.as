package canoe.asset
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.IEventDispatcher;

	public interface IAssetLoader extends IEventDispatcher
	{
		function get packName() : String;
		function get bytesTotal() : int;
		function get bytesLoaded() : int;
		function get completed() : Boolean;
		function load() : void;
		function bindBitmap(symbolName : String, bitmap : Bitmap) : void;
		function unbindBitmap(symbolName : String, bitmap : Bitmap) : void;
		function bind(symbolName : String, setter : Function) : void;
		function unbind(symbolName : String, setter : Function) : void;
		function getBitmapData(symbolName : String) : BitmapData;
		function getSymbolMeta(symbolName : String) : SymbolMeta;
		function disposeBitmapData(symbolName : String) : void;
		function disposeAll() : void;
	}
}