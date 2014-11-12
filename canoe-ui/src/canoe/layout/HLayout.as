package canoe.layout
{
	import canoe.core.IElement;
	import canoe.core.ILayout;
	import canoe.layout.support.StraightLayoutBase;

	public class HLayout extends StraightLayoutBase implements ILayout
	{
        private var childrenWidth : Number;

		override protected function doUpdateLayout() : void
		{
			var maxLeft : Number;
			if(hAlign == HAlign.CENTER)
			{
				maxLeft = (container.width - childrenWidth) / 2;
			}
			else if(hAlign == HAlign.RIGHT)
			{
				maxLeft = container.width - childrenWidth - paddingRight;
			}
			else
			{
				maxLeft = paddingLeft;
			}
			
			for(var index : uint = 0; index < layoutElements.length; index ++)
			{
				var child : IElement = layoutElements[index];
				if(index != 0)
				{
					maxLeft += gap;
				}
				
				child.x = maxLeft;
				maxLeft += child.measuredWidth;
				
				if(vAlign == VAlign.MIDDLE)
				{
					child.y = (container.height - child.measuredHeight) / 2;
				}
				else if(vAlign == VAlign.BOTTOM)
				{
					child.y = container.height - paddingBottom - child.measuredHeight;
				}
				else
				{
					child.y = paddingTop;
					
					if(vAlign == VAlign.STRETCH)
					{
						child.measuredHeight = container.height - paddingTop - paddingBottom;
					}
				}
			}
		}
		
		override protected function measureSize() : void
		{
			measureWidth();
			measureHeight();
		}
		
		private function measureWidth() : void
		{
			childrenWidth = 0;
			
			for(var i : uint = 0; i < layoutElements.length; i ++)
			{
				var child : IElement = layoutElements[i];
				child.measuredWidth = NaN;
				
				if(i != 0)
				{
					childrenWidth += gap;
				}
				
				childrenWidth += child.measuredWidth;
			}

			container.contentWidth = childrenWidth + paddingLeft + paddingRight;
		}

		private function measureHeight() : void
		{
			var maxChildHeight : Number = 0;
			for each(var child : IElement in layoutElements)
			{
				child.measuredHeight = NaN;
				maxChildHeight = Math.max(maxChildHeight, child.measuredHeight);
			}
			container.contentHeight = paddingTop + paddingBottom + maxChildHeight;
		}
	}
}