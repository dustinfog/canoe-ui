package canoe.studio.editor
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import canoe.core.IContainer;
	import canoe.core.IElement;
	import canoe.core.ILayout;

	public class DnRSource extends EventDispatcher
	{
		private var _xml : XML;
		private var _display : DisplayObject;

		public function get display():DisplayObject
		{
			return _display;
		}

		public function set display(value:DisplayObject):void
		{
			_display = value;
		}

		public function get xml():XML
		{
			return _xml;
		}

		public function set xml(value:XML):void
		{
			_xml = value;
		}
		
		public function get x() : Number
		{
			return display.x;
		}
		
		public function get y() : Number
		{
			return display.y;
		}
		
		
		public function get width() : Number
		{
			return display.width;
		}
		
		public function get height() : Number
		{
			return display.height;
		}

		public function get isContainer() : Boolean
		{
			return display is IContainer;
		}
		
		public function get visible() : Boolean
		{
			return display.visible;
		}
		
		public function localToGlobal(point : Point) : Point
		{
			return display.localToGlobal(point);
		}
		
		public function addChild(child : DnRSource) : void
		{
			IContainer(display).addChild(child.display);
			xml.appendChild(child.xml);
		}
		
		public function addChildBefore(child : DnRSource, refChild : DnRSource) : void
		{
			var container : IContainer = display as IContainer;
			
			container.addChildAt(child.display, container.getChildIndex(refChild.display));
			xml.insertChildBefore(refChild.xml, child.xml);
		}
		
		public function get layout() : ILayout
		{
			var container : IContainer = display as IContainer;
			if(container)
			{
				return container.layout;
			}
			
			return null;
		}
		
		public function detach() : void
		{
			delete xml.parent().*[xml.childIndex()];
			display.parent.removeChild(display);
		}
		
		private var ticked : Boolean;
		private var tickedX : Number;
		private var tickedY : Number;
		private var tickedWidth : Number;
		private var tickedHeight : Number;
		
		public function tick(x : Number, y : Number, width : Number, height : Number) : void
		{
			tickedX = x;
			tickedY = y;
			tickedWidth = width;
			tickedHeight = height;
			
			ticked = true;
		}
		
		public function commit() : void
		{
			if(!ticked) return;

			var element : IElement = display as IElement;
			
			updateX(element);
			updateY(element);
			updateWidth(element);
			updateHeight(element);
			
			ticked = false;
		}		
		private function updateX(element : IElement) : void
		{
			if(element.x != tickedX || (tickedWidth != element.width && !element.autoLeft && !element.autoRight && xml.@width.length() == 0))
			{
				var newRight : Number;
				if(!element || element.autoLeft)
				{
					if(!element || element.autoRight)
					{
						display.x = tickedX;
						setProperty(xml, "x", tickedX);
					}
					else
					{
						newRight = element.right - tickedX + element.x;
						element.right = newRight;
						setProperty(xml, "right", newRight);
					}
				}
				else
				{
					if(!element.autoRight && xml.@width.length() == 0)
					{
						if(tickedWidth != element.width)
						{
							newRight = element.right - tickedWidth + element.width;
						}
						else
						{
							newRight = element.right - tickedX + element.x;
						}
					}
					
					element.left = tickedX;
					element.x = tickedX;
					setProperty(xml, "left", tickedX);
					
					if(!isNaN(newRight))
					{
						element.right = newRight;
						setProperty(xml, "right", newRight);
					}
				}
			}
		}
		
		private function updateY(element : IElement) : void
		{
			if(display.y != tickedY || (tickedHeight != element.height && !element.autoTop && !element.autoBottom && xml.@height.length() == 0))
			{
				var newBottom : Number;
				if(!element || element.autoTop)
				{
					if(!element || element.autoBottom)
					{
						element.y = tickedY;
						setProperty(xml, "y", tickedY);
					}
					else
					{
						newBottom = element.bottom - tickedY + element.y;
						element.bottom = newBottom;
						setProperty(xml, "bottom", newBottom);
					}
				}
				else
				{
					if(!element.autoBottom && xml.@height.length() == 0)
					{
						if(tickedHeight != element.height)
						{
							newBottom = element.bottom - tickedHeight + element.height;
						}
						else
						{
							newBottom = element.bottom - tickedY + element.y;
						}
					}
					
					element.top = tickedY;
					element.y = tickedY;
					setProperty(xml, "top", tickedY);
					
					if(!isNaN(newBottom))
					{
						element.bottom = newBottom;
						setProperty(xml, "bottom", newBottom);
					}
				}
			}
		}
		
		private function updateWidth(element : IElement) : void
		{
			if(element.width != tickedWidth && (!element || xml.@width.length() || element.autoLeft || element.autoRight))
			{
				element.width = tickedWidth;
				setProperty(xml, "width", tickedWidth);
			}
		}
		
		private function updateHeight(element : IElement) : void
		{
			if(element.height != tickedHeight && (!element || xml.@height.length() || element.autoTop || element.autoBottom))
			{
				element.height = tickedHeight;
				setProperty(xml, "height", tickedHeight);
			}
		}
		
		private function setProperty(xml : XML, prop : String, value : Number) : void
		{
			if(!isNaN(value))
			{
				xml["@" + prop] = value;
			}
			else
			{
				delete xml["@" + prop];
			}
		}
	}
}