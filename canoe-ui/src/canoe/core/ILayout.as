package canoe.core
{
	import canoe.components.Container;

	public interface ILayout
	{
		/**
		 * 获取或设置容器 
		 * @param value
		 * 
		 */		
		function set container(value : Container) : void;
		function get container() : Container;
		/**
		 *  
		 * 更新布局
		 */		
		function updateLayout() : void;
		/**
		 *  或是否更新布局
		 * @return 
		 * 
		 */		
		function get updating() : Boolean;
	}
}