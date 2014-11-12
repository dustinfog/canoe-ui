package canoe.layout
{
	import canoe.core.IElement;
	import canoe.core.ILayout;
	import canoe.layout.support.LayoutBase;
	
	public class BasicLayout extends LayoutBase implements ILayout
	{
		override protected function doUpdateLayout() : void
		{
			for each(var child : IElement in layoutElements)
			{
				arrangeVertical(child);
				arrangeHorizontal(child);
			}
		}
		
		override protected function measureSize() : void
		{
			var contentWidth : Number = 0;
			var contentHeight : Number = 0;
			
			for each(var child : IElement in layoutElements)
			{
				child.measuredWidth = NaN;
				child.measuredHeight = NaN;
				
				if(isNaN(child.hCenter))
				{
					var refWidth : Number, childWidth : Number;
					if(child.autoRight)
					{
						refWidth = child.measuredWidth + child.left;
					}
					else
					{
						var left : Number = child.autoLeft ? 0 : child.left;
						refWidth = child.right + left + child.measuredWidth;
					}
					
					contentWidth = Math.max(contentWidth, refWidth);
				}
				else
				{
					contentWidth = Math.max(contentWidth, child.measuredWidth + Math.abs(child.hCenter));
				}
				
				if(isNaN(child.vCenter))
				{
					var refHeight : Number;
					if(child.autoBottom)
					{
						refHeight = child.measuredHeight + child.top;
					}
					else
					{
						var top : Number = child.autoTop ? 0 : child.top;
						refHeight = child.bottom + top + child.measuredHeight;
					}
					
					contentHeight = Math.max(contentHeight, refHeight);
				}
				else
				{
					contentHeight = Math.max(contentHeight, child.measuredHeight + Math.abs(child.vCenter));
				}
			}
			
			container.contentWidth = contentWidth;
			container.contentHeight = contentHeight;
		}
		
		private function arrangeHorizontal(child : IElement) : void
		{
			var hCenter : Number = child.hCenter;
			if(!isNaN(hCenter))
			{
				child.x = (container.width - child.measuredWidth) / 2 + hCenter;
			}
			else if(!child.autoLeft)
			{
				child.x = child.left;
				
				if(!child.autoRight)
				{
					child.measuredWidth = container.width - child.x - child.right;
				}
			}
			else if(!child.autoRight)
			{
				child.x = container.width - child.measuredWidth - child.right;
			}
		}
		
		private function arrangeVertical(child : IElement) : void
		{
			var vCenter : Number = child.vCenter;
			
			if(!isNaN(vCenter))
			{
				child.y = (container.height - child.measuredHeight) / 2 + vCenter;
			}
			else if(!child.autoTop)
			{
				child.y = child.top;
				
				if(!child.autoBottom)
				{
					child.measuredHeight = container.height - child.y - child.bottom;
				}
			}
			else if(!child.autoBottom)
			{
				child.y = container.height - child.measuredHeight - child.bottom;
			}
		}
	}
}