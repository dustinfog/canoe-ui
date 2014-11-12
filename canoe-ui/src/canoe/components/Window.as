package canoe.components
{
	import canoe.core.CanoeGlobals;
	import canoe.core.Text;
	import canoe.managers.PopUpLayer;
	import canoe.managers.PopUpManager;
	import canoe.util.ArrayUtil;
	import canoe.util.ObjectUtil;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	[Event(name="close", type="flash.events.Event")]
	public class Window extends SkinnableContainer
	{
		private static var openedWindows : Array = [];
		/**
		 * 
		 *  关闭所有窗口
		 */		
		public static function closeAll() : void
		{
			while(openedWindows.length)
			{
				Window(openedWindows[0]).close();
			}
		}
		/**
		 *  窗口标题
		 */		
		[Part]
		public var titleDisplay : Text;
		private var titleDisplayProperties : Object = {};
		/**
		 *  拖动区域 
		 */		
		[Part]
		public var moveArea : InteractiveObject;
		/**
		 *  关闭按钮 
		 */		
		[Part]
		public var closeButton : Button;
		
		private var _exclusive : Boolean;
		
		private var _modal : Boolean;
		
		private var _title : String;
		
		private var _centered : Boolean = true;
		
		/**
		 *  设置或获取是否窗口居中显示
		 * @return 
		 * 
		 */		
		public function get centered():Boolean
		{
			return _centered;
		}
		
		[Editable]
		public function set centered(value:Boolean):void
		{
			if(centered != value)
			{
				_centered = value;
				if(value && PopUpManager.isPopUp(this))
				{
					PopUpManager.centerPopUp(this);
				}
			}
		}
		/**
		 *  设置是否弹出窗口
		 * @return 
		 * 
		 */		
		public function get isPopUp():Boolean
		{
			return PopUpManager.isPopUp(this);
		}

		/**
		 *  获取或设置标题 
		 * @return 
		 * 
		 */		
		public function get title():String
		{
			return titleDisplay ? titleDisplay.text : titleDisplayProperties.text;
		}
		
		[Editable]
		public function set title(value:String):void
		{
			if(titleDisplay)
			{
				titleDisplay.text = value;
			}
			titleDisplayProperties.text = value;
		}

		/**
		 *  获取或设置模态窗口打开。
		 * @return 
		 * 
		 */		
		public function get modal():Boolean
		{
			return _modal;
		}
		
		[Editable]
		public function set modal(value:Boolean):void
		{
			if(modal != value)
			{
				_modal = value;
				
				if(PopUpManager.isPopUp(this))
				{
					if(value)
					{
						PopUpManager.attachModal(this);
					}
					else
					{
						PopUpManager.dettachModal(this);
					}
				}
			}
		}
		/**
		 *   获取或设置排他，排他窗口打开时，其他窗口自动关闭，
		 * @return 
		 * 
		 */
		public function get exclusive():Boolean
		{
			return _exclusive;
		}
		
		[Editable]
		public function set exclusive(value:Boolean):void
		{
			_exclusive = value;
		}

		/**
		 *	打开弹出窗口 
		 * 
		 */		
		public function open() : void
		{
			if(exclusive)
			{
				closeAll();
			}

			openedWindows.push(this);
			if(PopUpManager.isPopUp(this))
			{
				PopUpManager.topPopUp(this);
			}
			else
			{
				PopUpManager.addPopUp(this, PopUpLayer.LAYER_WINDOWS, modal);
			}
			
			if(centered)
			{
				PopUpManager.centerPopUp(this);
			}
		}
		/**
		 *	 关闭弹出窗口
		 * 
		 */		
		public function close() : void
		{
			if(dispatchEvent(new Event(Event.CLOSE, false, true)))
			{
				ArrayUtil.removeElements(openedWindows, this);
				PopUpManager.removePopUp(this);
			}
		}
		
		override protected function partAdded(instance:Object):void
		{
			if(instance == titleDisplay)
			{
				ObjectUtil.overrideProperties(titleDisplay, titleDisplayProperties);
			}
			else if(instance == moveArea)
			{
				moveArea.addEventListener(MouseEvent.MOUSE_DOWN, moveArea_mouseDownHandler);
			}
			else if(instance == closeButton)
			{
				closeButton.addEventListener(MouseEvent.CLICK, closeButton_clickHandler);
			}
			else
			{
				super.partAdded(instance);
			}
		}
		
		override protected function partRemoved(instance:Object):void
		{
			if(instance == moveArea)
			{
				moveArea.removeEventListener(MouseEvent.MOUSE_DOWN, moveArea_mouseDownHandler);
			}
			else if(instance == closeButton)
			{
				closeButton.removeEventListener(MouseEvent.CLICK, closeButton_clickHandler);
			}
			else
			{
				super.partRemoved(instance);
			}
		}
		
		protected function closeButton_clickHandler(event:MouseEvent):void
		{
			close();
		}
		
		protected function moveArea_mouseDownHandler(event:MouseEvent):void
		{
			PopUpManager.topPopUp(this);

			startDrag(false, new Rectangle(0, 0, CanoeGlobals.root.stage.stageWidth - width, CanoeGlobals.root.stage.stageHeight - height));
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}
		
		protected function stage_mouseUpHandler(event:MouseEvent):void
		{
			stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}
	}
}