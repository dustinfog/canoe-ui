package canoe.core
{
	public interface IFactory
	{
		
		/**
		 *   创建某一类（由实现 IFactory 的类确定）的实例。
		 * @return 
		 * 
		 */		
		function newInstance() : *;
		/**
		 * 获取 用newInstance创建的实例的属性
		 * @param instance
		 * @param prop
		 * @return 
		 * 
		 */		
		function getProperty(instance : *, prop : String) : *;
	}
}