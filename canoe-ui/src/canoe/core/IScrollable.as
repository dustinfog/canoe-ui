package canoe.core
{
	public interface IScrollable extends IElement
	{
		function get maxScrollLeft():Number;
		function get maxScrollTop():Number;
        function get scrollPageSizeH() : Number;
		function get scrollPageSizeV() : Number;
		function get scrollLeft():Number;
		function set scrollLeft(value:Number):void;
		function get scrollTop():Number;
		function set scrollTop(value:Number):void;
	}
}