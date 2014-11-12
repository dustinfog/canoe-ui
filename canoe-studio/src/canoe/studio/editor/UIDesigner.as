package canoe.studio.editor
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	
	import canoe.cxml.CXMLTranslator;
	import canoe.studio.panel.OutlinePanel;
	import canoe.util.EventUtil;
	import canoe.util.ObjectPool;
	
	public class UIDesigner extends UIComponent
	{
		public function UIDesigner()
		{
			super();
			
			canvas = new UIComponent();
			addChild(canvas);
			addEventListener(Event.CHANGE, EventUtil.stopPropagation);
			addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			addEventListener(ResizeEvent.RESIZE, resizeHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 1);
		}

		protected function mouseDownHandler(event:MouseEvent):void
		{
			if(previewMode) return;
			
			stage.focus = this;
			var mouseCtrlr : DnRController;
			if(event.target == this)
			{
				mouseCtrlr = DnRController(display2CtrlrDict[ui]);
			}
			else if(event.target is DnRController)
			{
				mouseCtrlr = DnRController(event.target);
			}
			else
			{
				mouseCtrlr = getAncestorCtrlr(DisplayObject(event.target));
			}
			
			selectedCtrlr = mouseCtrlr;
		}
		
		protected function resizeHandler(event:ResizeEvent):void
		{
			graphics.clear();
			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
		}
		
		private var ui : DisplayObject;
		private var canvas : UIComponent;
		private var _xml : XML;
		private var _previewMode : Boolean;
		private var display2CtrlrDict : Dictionary;
		private var disposing : Boolean;
		private var _selectedCtrlr : DnRController;
		
		public function get previewMode():Boolean
		{
			return !canvas.visible;
		}

		public function set previewMode(value:Boolean):void
		{
			canvas.visible = !value;
			
			if(!value)
			{
				stage.focus = this;
			}
		}
		
		public function get rootDnRController() : DnRController
		{
			return display2CtrlrDict[ui];
		}
		
		[Bindable(event="selectedCtrlrChanged")]
		public function get selectedCtrlr():DnRController
		{
			return _selectedCtrlr;
		}
		
		public function set selectedCtrlr(value:DnRController):void
		{
			if(selectedCtrlr != value)
			{
				if(selectedCtrlr != null)
					selectedCtrlr.focused = false;
				
				if(value)
					value.focused = true;
				_selectedCtrlr = value;
				OutlinePanel.instance.selectedDnRController = value;
				dispatchEvent(new Event("selectedCtrlrChanged"));
			}
		}

		public function get xml():XML
		{
			return _xml;
		}

		public function set xml(value:XML):void
		{
			if(ui || xml)
			{
				dispose();
			}

			_xml = value;

			if(xml != null)
			{
				ui = CXMLTranslator.createWithXML(xml, null, preproccessSubUI);
				ui.addEventListener(Event.RESIZE, ui_resizeHandler);
				addChildAt(ui, 0);
			}
		}
		
		public function dispose() : void
		{
			disposing = true;
			if(xml)
			{
				System.disposeXML(xml);
				_xml = null;
			}
			
			if(ui)
			{
				ui.removeEventListener(Event.RESIZE, ui_resizeHandler);
				removeChild(ui);
				ui = null;
			}
			display2CtrlrDict = new Dictionary();
			disposing = false;
		}
		
		protected function ui_resizeHandler(event:Event):void
		{
			minWidth = ui.width + ui.x;
			minHeight = ui.height + ui.y;
		}
		
		internal function preproccessSubUI(subXml : XML, object : *) : DnRSource
		{
			if(!(object is DisplayObject)) return null;
			
			var displayObject : DisplayObject = object as DisplayObject;
			var ctrlr : DnRController = new DnRController();
			var source : DnRSource = new DnRSource();
			source.display = displayObject;
			source.xml = subXml;
			
			ctrlr.source = source;

			display2CtrlrDict[displayObject] = ctrlr;
			
			displayObject.addEventListener(Event.ADDED_TO_STAGE, subUI_addedToStageHandler, false, int.MAX_VALUE);
			displayObject.addEventListener(Event.REMOVED_FROM_STAGE, subUI_removedFromStageHandler);
			
			return source;
		}
		
		protected function subUI_removedFromStageHandler(event:Event):void
		{
			var displayObject : DisplayObject = DisplayObject(event.currentTarget);
			var ctrlr : DnRController = display2CtrlrDict[displayObject];
			ctrlr.parent.removeChild(ctrlr);

			if(disposing)
			{
				if(selectedCtrlr == ctrlr)
				{
					ctrlr.focused = false;
					selectedCtrlr = null;
				}
				
				ctrlr.source = null;

				delete display2CtrlrDict[displayObject];
				ObjectPool.collect(ctrlr);
				displayObject.removeEventListener(Event.ADDED_TO_STAGE, subUI_addedToStageHandler);
				displayObject.removeEventListener(Event.REMOVED_FROM_STAGE, subUI_removedFromStageHandler);
			}
		}
		
		protected function subUI_addedToStageHandler(event:Event):void
		{
			var displayObject : DisplayObject = DisplayObject(event.currentTarget);
			var ctrlr : DnRController = display2CtrlrDict[displayObject];

			if(displayObject.parent == this)
			{
				canvas.addChild(ctrlr);
			}
			else
			{
				getAncestorCtrlr(displayObject.parent).addChild(ctrlr);
			}
		}
		
		private function getAncestorCtrlr(displayObject : DisplayObject) : DnRController
		{
			var ctrlr : DnRController = null;
			do
			{
				ctrlr = display2CtrlrDict[displayObject];
				displayObject = displayObject.parent;
			}
			while(ctrlr == null);
			
			return ctrlr;
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if(selectedCtrlr)
			{
				var source : DnRSource = selectedCtrlr.source;
				var delta : Number = 1;
				if(event.shiftKey)
				{
					delta = 10;
				}
			
				var targetX : Number = source.x;
				var targetY : Number = source.y;
				var targetWidth : Number = source.width;
				var targetHeight : Number = source.height;
				
				if(event.keyCode == Keyboard.UP)
				{
					targetY -= delta;
					selectedCtrlr.tick(targetX, targetY, targetWidth, targetHeight);
					event.stopPropagation();
				}
				else if(event.keyCode == Keyboard.DOWN)
				{
					targetY += delta;
					selectedCtrlr.tick(targetX, targetY, targetWidth, targetHeight);
					event.stopPropagation();
				}
				else if(event.keyCode == Keyboard.LEFT)
				{
					targetX -= delta;
					selectedCtrlr.tick(targetX, targetY, targetWidth, targetHeight);
					event.stopPropagation();
				}
				else if(event.keyCode == Keyboard.RIGHT)
				{
					targetX += delta;
					selectedCtrlr.tick(targetX, targetY, targetWidth, targetHeight);
					event.stopPropagation();
				}
				else if(event.keyCode == Keyboard.DELETE)
				{
					if(source.display != ui)
					{
						source.detach();
						OutlinePanel.instance.refresh();
					}
				}
			}
		}
	}
}