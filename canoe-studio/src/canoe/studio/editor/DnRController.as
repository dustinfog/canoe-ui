package canoe.studio.editor
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.MoveEvent;
	import mx.events.ResizeEvent;
	import mx.managers.DragManager;
	
	import avmplus.getQualifiedClassName;
	
	import canoe.cxml.CXMLTranslator;
	import canoe.events.CanoeEvent;
	import canoe.layout.HLayout;
	import canoe.layout.VLayout;
	import canoe.studio.panel.OutlinePanel;
	import canoe.studio.util.XMLUtil;
	
	[Event(name="update", type="canoe.studio.editor.EditorEvent")]
	public class DnRController extends UIComponent
	{	
		private static const HANDLE_SIZE : int = 5;
		
		private static const CENTER : int = 0x00000;
		private static const TOP : int = 0x0001;
		private static const RIGHT : int = 0x0010;
		private static const BOTTOM : int = 0x0100;
		private static const LEFT : int = 0x1000;

		private static const FOCUSED_COLOR : int = 0x0000ff;
		private static const DRAG_IN_COLOR : int = 0xff9900;
		private static const DROP_RECEIVER_COLOR : int = 0x009900;
		private static const BLURED_COLOR : int = 0xcccccc;
		
		private static const EMPTY_BMD : BitmapData = new BitmapData(1, 1, true, 0);
		private static var dropReceiver : DnRController;
		
		public function DnRController()
		{
			super();
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(ResizeEvent.RESIZE, resizeHandler);
			addEventListener(MoveEvent.MOVE, moveHandler);
			addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
		}

		private var _focused : Boolean;
		private var _source : DnRSource;
		private var stickyIsDirty : Boolean = true;
		private var updated : Boolean;
		private var borderIsDirty : Boolean;
		
		protected var initialMouseX : Number;
		protected var initialMouseY : Number;
		protected var initialBounds : Rectangle;
		
		private var mousePosition : int;
		
		public function get focused():Boolean
		{
			return _focused;
		}
		
		override public function get nestLevel():int
		{
			return 1;
		}
		
		public function set focused(value:Boolean):void
		{
			if(focused != value)
			{
				_focused = value;
				invalidateBorder();
			}
		}
		
		public function get designer() : UIDesigner
		{
			if(parent is DnRController)
			{
				return DnRController(parent).designer;
			}
			else if(stage)
			{
				var ancestor : DisplayObjectContainer = parent;
				while(!(ancestor is UIDesigner))
				{
					ancestor = ancestor.parent;	
				}
				
				return ancestor as UIDesigner;
			}
			
			return null;
		}
		
		public function get source():DnRSource
		{
			return _source;
		}
		
		public function set source(value:DnRSource):void
		{
			if(_source != value)
			{
				var display : DisplayObject;
				if(_source != null)
				{
					display = _source.display;
					display.removeEventListener(Event.RESIZE, stick);
					display.removeEventListener(CanoeEvent.SHOW, stick);
					display.removeEventListener(CanoeEvent.HIDE, stick);
					display.removeEventListener(CanoeEvent.MOVE, stick);
					display.removeEventListener(Event.ADDED_TO_STAGE, stick);
					removeEventListener(Event.ADDED_TO_STAGE, stick);
				}
				
				_source = value;
				
				if(_source)
				{
					display = _source.display;
					display.addEventListener(Event.RESIZE, stick);
					display.addEventListener(CanoeEvent.SHOW, stick);
					display.addEventListener(CanoeEvent.HIDE, stick);
					display.addEventListener(CanoeEvent.MOVE, stick);
					display.addEventListener(Event.ADDED_TO_STAGE, stick);
					addEventListener(Event.ADDED_TO_STAGE, stick);
					
					if(display.stage)
					{
						stick();
					}
				}
			}
		}

		private function dragEnterHandler(event:DragEvent):void
		{
			var dragSource : DragSource = event.dragSource;
			
			if(source.isContainer && (dragSource.hasFormat("dnr") || dragSource.hasFormat("asset") || dragSource.hasFormat("cxml") || dragSource.hasFormat("comp")))
			{
				dropReceiver = this;
				if(!(parent is DnRController))
				{
					DragManager.acceptDragDrop(this);
					addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
				}
				invalidateAncestorsBorder();
				addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			}
		}
		
		protected function rollOutHandler(event:MouseEvent):void
		{
			if(parent is DnRController)
			{
				var parentFocuser : DnRController = DnRController(parent);
				dropReceiver = parentFocuser;
				parentFocuser.drawBorder();
			}
			else
			{
				dropReceiver = null;
			}
			
			invalidateAncestorsBorder();
			removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			removeEventListener(DragEvent.DRAG_DROP, dragDropHandler);
		}

		protected function dragDropHandler(event:DragEvent):void
		{
			var dragSource : DragSource = event.dragSource;
			var unstable : DnRSource;

			var ctrlr : DnRController = dragSource.dataForFormat("dnr") as DnRController;
			if(ctrlr)
			{
				unstable = ctrlr.source;
				unstable.detach();
			}
			else
			{
				var xml : XML, nsName : String;
				if(dragSource.hasFormat("asset"))
				{
					var uri : String = dragSource.dataForFormat("asset") as String;
					
					xml = <AssetImage />;
					xml.@uri=uri;
					
					nsName = "canoe.components";
				}
				else if(dragSource.hasFormat("cxml"))
				{
					var className : String =  dragSource.dataForFormat("cxml") as String;
					var indexOfDot : int = className.lastIndexOf(".");
					var baseName : String = className.substring(indexOfDot + 1);
					xml = XML("<" + baseName + " />");
					
					nsName = className.substr(0, indexOfDot);
				}
				else if(dragSource.hasFormat("comp"))
				{
					var comp : Class = dragSource.dataForFormat("comp") as Class;

					var names : Array = getQualifiedClassName(comp).split("::");
					xml = XML("<" + names[1] + " />");
					nsName = names[0];
				}
				
				XMLUtil.setNamespace(xml, nsName, source.xml);
				
				unstable = designer.preproccessSubUI(xml, CXMLTranslator.createWithXML(xml, null));
			}
			
			if(unstable)
			{
				var i : uint, childFocuser : DnRController, nearestFocuser : DnRController, distance : Number;
				var dropX : Number = dropReceiver.mouseX;
				var dropY : Number = dropReceiver.mouseY;
				var minDistance : Number = Number.MAX_VALUE;
				
				var receiver : DnRSource = dropReceiver.source;

				if(receiver.layout is VLayout)
				{
					for(i = 0; i < dropReceiver.numChildren; i ++)
					{
						childFocuser = dropReceiver.getChildAt(i) as DnRController;
						distance = Math.abs(childFocuser.y - dropY);
						if(distance < minDistance)
						{
							minDistance = distance;
							nearestFocuser = childFocuser;
						}
					}
					
					if(nearestFocuser && Math.abs(nearestFocuser.height + nearestFocuser.y - dropY) < minDistance)
					{
						nearestFocuser = null;
					}
				}
				else if(receiver.layout is HLayout)
				{
					for(i = 0; i < dropReceiver.numChildren; i ++)
					{
						childFocuser = dropReceiver.getChildAt(i) as DnRController;
						distance = Math.abs(childFocuser.x - dropX);
						if(distance < minDistance)
						{
							minDistance = distance;
							nearestFocuser = childFocuser;
						}
					}
					
					if(nearestFocuser && Math.abs(nearestFocuser.width + nearestFocuser.x - dropX) < minDistance)
					{
						nearestFocuser = null;
					}
				}
				
				if(nearestFocuser != null)
				{
					receiver.addChildBefore(unstable, nearestFocuser.source);
				}
				else
				{
					receiver.addChild(unstable);
				}
				
				OutlinePanel.instance.refresh();
			}
			dropReceiver = null;
			updated = true;
			invalidateAncestorsBorder();
		}

		protected function moveHandler(event:MoveEvent):void
		{
			for(var i : uint = 0; i < numChildren; i ++)
			{
				var subFocuser : DnRController = getChildAt(i) as DnRController;
				if(subFocuser)
				{
					subFocuser.stick();
				}
			}
		}
		
		protected function resizeHandler(event:Event):void
		{
			invalidateBorder();
		}
		
		protected function mouseDownHandler(event:MouseEvent):void
		{
			if(!focused) return;
			
			if((parent is DnRController) && event.ctrlKey)
			{
				var dragSource : DragSource = new DragSource();
				dragSource.addData(this, "dnr");
				DragManager.doDrag(this, dragSource, event);
				
				return;
			}
			
			initialMouseX = stage.mouseX;
			initialMouseY = stage.mouseY;
			initialBounds = new Rectangle(source.x, source.y, source.width, source.height);
			
			mousePosition = CENTER;
			
			if(mouseY >= height - HANDLE_SIZE)
			{
				mousePosition |= BOTTOM;
			}
			else if(mouseY <= HANDLE_SIZE)
			{
				mousePosition |= TOP;
			}
			
			if(mouseX >= width - HANDLE_SIZE)
			{
				mousePosition |= RIGHT;
			}
			else if(mouseX <= HANDLE_SIZE)
			{
				mousePosition |= LEFT;
			}
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		

		protected function mouseMoveHandler(event : Event) : void
		{
			var targetX : Number = source.x;
			var targetY : Number = source.y;
			var targetWidth : Number = source.width;
			var targetHeight : Number = source.height;
			
			if(mousePosition == CENTER)
			{
				targetX = initialBounds.x + stage.mouseX - initialMouseX;
				targetY = initialBounds.y + stage.mouseY - initialMouseY;
			}
			else
			{
				var offsetX : Number = stage.mouseX - initialMouseX;
				var offsetY : Number = stage.mouseY - initialMouseY;
				if(mousePosition & TOP)
				{
					offsetY = Math.min(offsetY, initialBounds.height - 1);
					
					targetHeight = initialBounds.height - offsetY;
					targetY = initialBounds.y + offsetY;
				}
				else if(mousePosition & BOTTOM)
				{
					offsetY = Math.max(offsetY, 1 - initialBounds.height);
					targetHeight = initialBounds.height + offsetY;
				}
				
				if(mousePosition & LEFT)
				{
					offsetX = Math.min(offsetX, initialBounds.width - 1);
					targetWidth = initialBounds.width - offsetX;
					targetX = initialBounds.x + offsetX;
				}
				else if(mousePosition & RIGHT)
				{
					offsetX = Math.max(offsetX, 1 - initialBounds.width);
					targetWidth = initialBounds.width + offsetX;
				}
			}
			
			tick(targetX, targetY, targetWidth, targetHeight);
		}
		
		internal function tick(targetX : Number, targetY : Number, targetWidth : Number, targetHeight : Number) : void
		{
			source.tick(targetX, targetY, targetWidth, targetHeight);
			updated = true;
			invalidateProperties();
		}
		
		protected function mouseUpHandler(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		protected function stick(event:Event = null):void
		{
			stickyIsDirty = true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(stickyIsDirty && parent && source)
			{
				if(source.visible)
				{
					visible = true;
					var globalCoord : Point = source.localToGlobal(new Point());
					var coord : Point = parent.globalToLocal(globalCoord);	
					
					move(coord.x, coord.y);
					setActualSize(source.width, source.height);
				}
				else
				{
					visible = false;
				}

				stickyIsDirty = false;
			}
			
			if(updated)
			{
				source.commit();
				dispatchEvent(new EditorEvent(EditorEvent.UPDATE));
				updated = false;
			}
			
			if(borderIsDirty)
			{
				drawBorder();
				borderIsDirty = false;
			}
		}
		
		private function drawBorder() : void
		{
			var borderColor : int;
			if(focused)
			{
				borderColor = FOCUSED_COLOR;
			}
			else if(DragManager.isDragging) 
			{
				if(dropReceiver == this)
				{
					borderColor = DROP_RECEIVER_COLOR;
				}
				else if(dropReceiver && contains(dropReceiver))
				{
					borderColor = DRAG_IN_COLOR;
				}
				else
				{
					borderColor = BLURED_COLOR;
				}
			}
			else
			{
				borderColor = BLURED_COLOR;
			}
			
			graphics.clear();
			graphics.lineStyle(1, borderColor);
			graphics.beginBitmapFill(EMPTY_BMD);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			if(focused)
			{
				drawHandle(0, height);
				drawHandle(0, height / 2);
				drawHandle(0, 0);
				drawHandle(width / 2, 0);
				drawHandle(width, 0);
				drawHandle(width, height / 2);
				drawHandle(width, height);
				drawHandle(width / 2, height);
			}
		}
		
		private function drawHandle(x : Number, y : Number) : void
		{
			graphics.beginFill(0xffffff);
			graphics.drawRect(x - HANDLE_SIZE / 2,  y - HANDLE_SIZE / 2, HANDLE_SIZE, HANDLE_SIZE);
			graphics.endFill();
		}
		
		private function invalidateBorder() : void
		{
			borderIsDirty = true;
			invalidateProperties();
		}
		
		private function invalidateAncestorsBorder() : void
		{
			for(var forcuser : DnRController = this; forcuser; forcuser = forcuser.parent as DnRController){
				forcuser.invalidateBorder();
			}
		}
	}
}