package canoe.core
{
	import flash.display.DisplayObject;

	public interface IContainer extends IElement
	{
		/**
		 *  获取或设置布局
		 * @return 
		 * 
		 */		
		function get layout():ILayout;
		function set layout(value:ILayout):void;
		/**
		 *  显示时是否将超出大小的部分裁掉
		 * @param v
		 * 
		 */		
		function set clipAndScroll(v : Boolean) : void;
		function get clipAndScroll() : Boolean;
		/**
		 *  使布局失效，以使得在本次渲染之前重新布局子元素。由子元素调用 
		 * 
		 */		
		function invalidateLayout() : void;
		/**
		 *  使层叠顺序失效，在子元素的depth变化时由子元素调用
		 * 
		 */		
		function invalidateLayering() : void;
		/**
		 *  确定指定显示对象是 DisplayObjectContainer 实例的子项还是该实例本身。 
		 * @param child
		 * @return 
		 * 
		 */		
		function contains(child:DisplayObject):Boolean;
		/**
		 *将一个 DisplayObject 子实例添加到该 DisplayObjectContainer 实例中。   
		 * @param child
		 * @return 
		 * 
		 */		
		function addChild(child:DisplayObject):DisplayObject;
		/**
		 *  
		 *   将一个 DisplayObject 子实例添加到该 DisplayObjectContainer 实例的指定的index中。
		 * @param child
		 * @param index
		 * @return 
		 * 
		 */		
		function addChildAt(child:DisplayObject, index:int):DisplayObject;
		/**
		 *  从 DisplayObjectContainer 实例的子列表中删除指定的 child DisplayObject 实例。 
		 * @param child
		 * @return 
		 * 
		 */		
		function removeChild(child:DisplayObject):DisplayObject;
		/**
		 * 从 DisplayObjectContainer 的子列表中指定的 index 位置删除子 DisplayObject。
		 * @param index
		 * @return 
		 * 
		 */		
		function removeChildAt(index:int):DisplayObject;
		/**
		 *  交换两个指定子对象的 Z 轴顺序（从前到后顺序）。 
		 * @param child1
		 * @param child2
		 * 
		 */		
		function swapChildren(child1:DisplayObject, child2:DisplayObject):void;
		/**
		 *  在子级列表中两个指定的索引位置，交换子对象的 Z 轴顺序（前后顺序）。 
		 * @param index1
		 * @param index2
		 * 
		 */		
		function swapChildrenAt(index1:int, index2:int):void;
		/**
		 *  更改现有子项在显示对象容器中的位置。
		 * @param child
		 * @param index
		 * 
		 */		
		function setChildIndex(child:DisplayObject, index:int):void;
		/**
		 * 返回 DisplayObject 的 child 实例的索引位置。
		 * @param child
		 * @return 
		 * 
		 */		
		function getChildIndex(child:DisplayObject):int;
		/**
		 * 返回位于指定索引处的子显示对象实例。
		 * @param index
		 * @return 
		 * 
		 */		
		function getChildAt(index:int):DisplayObject;
		/**
		 * 删除全部的子对象 
		 * 
		 */		
		function removeAll() : void
		/**
		 *  获取子对象的数量 
		 * @return 
		 * 
		 */		
		function get numChildren() : int;
	}
}