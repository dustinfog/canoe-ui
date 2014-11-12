package canoe.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import canoe.core.Text;

	public class Alert extends Window
	{
		public static const OK : int = 1;
		public static const CANCEL : int = 2;
		
		private static const instance : Alert = new Alert();
		/**
		 * 
		 * @param message
		 * @param buttonFlag Alert 控件中放置的按钮。有效值为 Alert.OK、Alert.CANCEL。默认值为 Alert.OK。使用按位 OR 运算符可显示多个按钮。
		 * @param onOk
		 * @param onCancel
		 * 
		 */
		public static function show(message : String, buttonFlag : int = OK, onOk : Function = null, onCancel: Function = null) : void
		{
			var notice : Notice = new Notice(message);
			notice.onOk = onOk;
			notice.onCancel = onCancel;
			notice.buttonFlag = buttonFlag;
			instance.attachNotice(notice);
		}
		
		[Part]
		public var okButton : Button;
		[Part]
		public var cancelButton : Button;
		[Part]
		public var messageDisplay : Text;
		
		private var noticeQueue : Array = [];
		private var currentNotice : Notice;
		/**
		 *  构造函数 
		 * 
		 */		
		public function Alert()
		{
			super();
			
			modal = true;
			addEventListener(Event.CLOSE, closeHandler);
		}
		
		override protected function partAdded(instance:Object):void
		{
			if(instance == okButton)
			{
				okButton.addEventListener(MouseEvent.CLICK, okButton_clickHandler);
				if(currentNotice) okButton.visible = ((currentNotice.buttonFlag & OK) > 0); 
			}
			else if(instance == cancelButton)
			{
				cancelButton.addEventListener(MouseEvent.CLICK, cancelButton_clickHandler);
				if(currentNotice) cancelButton.visible = ((currentNotice.buttonFlag & CANCEL) > 0);
			}
			else if(instance == messageDisplay)
			{
				if(currentNotice) messageDisplay.text = currentNotice.message;
			}
			else
			{
				super.partAdded(instance)
			}
		}
		
		override protected function partRemoved(instance:Object):void
		{
			if(instance == okButton)
			{
				okButton.removeEventListener(MouseEvent.CLICK, okButton_clickHandler);
			}
			else if(instance == cancelButton)
			{
				cancelButton.removeEventListener(MouseEvent.CLICK, cancelButton_clickHandler);
			}
			else
			{
				super.partRemoved(instance);
			}
		}
		
		protected function okButton_clickHandler(event:MouseEvent):void
		{
			if(currentNotice.onOk != null)
			{
				currentNotice.onOk();
			}

			close();
		}
		
		protected function cancelButton_clickHandler(event : MouseEvent) : void
		{
			if(currentNotice.onCancel != null)
			{
				currentNotice.onCancel();
			}
			
			close();
		}
		
		override protected function closeButton_clickHandler(event:MouseEvent):void
		{
			if(currentNotice.buttonFlag & CANCEL)
			{
				cancelButton_clickHandler(event);	
			}
			else
			{
				okButton_clickHandler(event);
			}
		}

		protected function closeHandler(event:Event):void
		{
			if(noticeQueue.length)
			{
				setCurrentNotice(noticeQueue.shift());
				event.preventDefault();
			}
			else
			{
				setCurrentNotice(null);
			}
		}
		
		private function setCurrentNotice( v : Notice) : void
		{
			if(currentNotice != v)
			{
				currentNotice = v;
				
				if(v)
				{
					if(messageDisplay) messageDisplay.text = currentNotice.message;
					if(okButton) okButton.visible = ((currentNotice.buttonFlag & OK) > 0); 
					if(cancelButton) cancelButton.visible = ((currentNotice.buttonFlag & CANCEL) > 0);

					open();
				}
			}
		}
		
		protected function attachNotice(notice : Notice) : void
		{
			if(!currentNotice)
			{
				setCurrentNotice(notice);
			}
			else
			{
				var similar : Boolean;
				if(noticeQueue.length > 0)
				{
					similar = Notice(noticeQueue[noticeQueue.length - 1]).equals(notice);
				}
				else
				{
					similar = currentNotice.equals(notice);
				}
				
				if(!similar)
				{
					noticeQueue.push(notice);
				}
			}
		}
	}
}