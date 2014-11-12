package canoe.core
{
	public interface IItemRenderer extends IElement
	{
		/**
		 *  获取或设置是否选中 
		 * @param v
		 * 
		 */		
        function set selected(v : Boolean) : void;
		function get selected() : Boolean;
	}
}