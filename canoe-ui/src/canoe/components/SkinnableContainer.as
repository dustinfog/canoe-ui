package canoe.components
{
	import canoe.core.IContainer;
	import canoe.core.IElement;
	import canoe.core.ILayout;
	import canoe.util.ArrayUtil;
	import canoe.util.ObjectUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class SkinnableContainer extends SkinnableComponent implements IContainer
	{
		/**
		 * 	content 容器 
		 */		
		[Part]
        public var content : Container;
		private var children : Array = [];
		
		private var containerProperties : Object = {};
		/**
		 *	设置或获取布局 
		 * @return 
		 * 
		 */		
		public function get layout():ILayout
		{
			return content ? content.layout : containerProperties.layout;
		}
		
		public function set layout(value:ILayout):void
		{
            if(content)
			{
				content.layout = value;
			}
			containerProperties.layout = value;
		}
		/**
		 *	设置或获取滚动 
		 * @param v
		 * 
		 */		
		public function set clipAndScroll(v : Boolean) : void
		{
			if(content)
			{
				content.clipAndScroll = v;
			}
			
			containerProperties.clipAndScroll = v;
		}

		public function get clipAndScroll() : Boolean
		{
			return content ? content.clipAndScroll : containerProperties.clipAndScroll;
		}

		private function resizeHandler(event:Event):void
		{
			invalidateLayout();
		}
		
        override protected function partAdded(instance:Object):void
		{
			if(instance == content)
			{
				content.removeAll();

				ObjectUtil.overrideProperties(content, containerProperties);
				for(var i : uint = 0; i < children.length; i ++)
				{
					content.addChild(children[i]);
				}
			}
		}
		
		override protected function partRemoved(instance:Object):void
		{
			if(instance == content)
			{
				for(var i : uint = 0; i < children.length; i ++)
				{
					content.removeChild(children[i]);
				}
			}
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			var oldParent : Container = child.parent as Container;
			if(oldParent)
			{
				oldParent.removeChild(child);
			}
			
			if(content)
			{
				content.addChild(child);
			}
			
			if(children.indexOf(child) < 0)
			{
				children.push(child);
			}

			if(child is IElement)
			{
				IElement(child).owner = this;
			}
			return child;
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			var oldParent : Container = child.parent as Container;
			if(oldParent)
			{
				oldParent.removeChild(child);
			}
			
			ArrayUtil.addElementAt(children, child, index);			
			if(content)
			{
				content.addChildAt(child, index);
			}
			
			if(child is IElement)
			{
				IElement(child).owner = this;
			}
			return child;
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			ArrayUtil.removeElements(children, child);
			if(content)
			{
				content.removeChild(child);
			}
			
			if(child is IElement)
			{
				IElement(child).owner = null;
			}
			return child;
		}
		
		public function removeAll() : void
		{
			while(numChildren)
			{
				removeChildAt(0);
			}
		}
		
		override public function removeChildAt(index:int):DisplayObject
		{
			ArrayUtil.removeElementAt(children, index);	
			var child : DisplayObject;
			if(content)
			{
				child = content.removeChildAt(index);
			}
			
			if(child is IElement)
			{
				IElement(child).owner = null;
			}
			return child;
		}
		
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{
			swapChildrenAt(children.indexOf(child1), children.indexOf(child2));
		}
		
		override public function swapChildrenAt(index1:int, index2:int):void
		{
			ArrayUtil.swapElementAt(children, index1, index2);
			
			if(content)
			{
				content.swapChildrenAt(index1, index2);
			}
		}
		
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			ArrayUtil.setElementIndex(children, child, index);
			
			if(content)
			{
				content.setChildIndex(child, index);
			}
		}
		
		override public function getChildIndex(child:DisplayObject):int
		{
			return children.indexOf(child);
		}
		
		override public function getChildAt(index:int):DisplayObject
		{
			return children[index];
		}
		
		override public function getChildByName(name:String):DisplayObject
		{
			if(content)
			{
				return content.getChildByName(name);
			}
			else
			{
				for each(var child : DisplayObject in children)
				{
					if(child.name == name)
					{
						return child;
					}
				}
				
				return null;
			}
		}
		
		override public function get numChildren() : int
		{
			return children.length;
		}
		
		public function invalidateLayout() : void
		{
			if(content)
			{
	            content.invalidateLayout();
			}
		}
		
		public function invalidateLayering() : void
		{
			if(content)
			{
				content.invalidateLayering();
			}
		}
	}
}