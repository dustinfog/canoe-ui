package canoe.core
{
	public interface IBinding
	{
		/**
		 * 
		 * 申请绑定数据
		 */		
		function apply() : void;
		/**
		 *  取消绑定数据
		 * 
		 */		
		function clear() : void; 
	}
}