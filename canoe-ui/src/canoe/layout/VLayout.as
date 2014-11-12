package canoe.layout
{
	import canoe.core.IElement;
	import canoe.core.ILayout;
	import canoe.layout.support.StraightLayoutBase;

	public class VLayout extends StraightLayoutBase implements ILayout
	{
		private var childrenHeight : Number;
		
		override protected function doUpdateLayout() : void
		{
			var maxTop : Number;
			if(hAlign == HAlign.CENTER)
			{
				maxTop = (container.height - childrenHeight) / 2;
			}
			else if(hAlign == HAlign.RIGHT)
			{
				maxTop = container.height - childrenHeight - paddingRight;
			}
			else
			{
				maxTop = paddingTop;
			}
			
			for(var i : uint = 0; i < layoutElements.length; i ++)
			{
				if(i != 0)
				{
					maxTop += gap;
				}
				
				var child : IElement = layoutElements[i];
				child.y = maxTop;
				maxTop += child.measuredHeight;
				
				if(hAlign == HAlign.CENTER)
				{
					child.x = (container.width - child.measuredWidth) / 2;
				}
				else if(hAlign == HAlign.RIGHT)
				{
					child.x = container.width - paddingRight - child.measuredWidth;
				}
				else
				{
					child.x = paddingRight;
					
					if(hAlign == HAlign.STRETCH)
					{
						child.measuredWidth = container.width - paddingLeft - paddingRight;
					}
				}
			}
		}
		
		override protected function measureSize() : void
		{
			measureWidth();
			measureHeight();
		}

		private function measureHeight() : void
		{
			childrenHeight = 0;
			for(var i : uint = 0; i < layoutElements.length; i ++)
			{
				if(i != 0)
				{
					childrenHeight += gap;
				}
				
				var child : IElement = layoutElements[i];
				child.measuredHeight = NaN;
				childrenHeight += child.measuredHeight;
			}

			container.contentHeight = childrenHeight + paddingTop + paddingBottom;
		}
		
		private function measureWidth() : void
		{
			var maxChildWidth : Number = 0;
			for each(var child : IElement in layoutElements)
			{
				child.measuredWidth = NaN;
				maxChildWidth = Math.max(maxChildWidth, child.measuredWidth);
			}
			container.contentWidth = paddingLeft + paddingRight + maxChildWidth;
		}
	}
}