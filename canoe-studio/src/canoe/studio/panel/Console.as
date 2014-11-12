package canoe.studio.panel
{
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import mx.controls.TextArea;
	
	public class Console extends TextArea
	{
		private static var _instance : Console;
		public static function get instance() : Console
		{
			return _instance;
		}
		
		public function Console()
		{
			super();

			setStyle("fontFamily", "Courier New,simsun");
			setStyle("fontSize", 12);
			
			_instance = this;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			textField.type = TextFieldType.DYNAMIC;
			
			wordWrap = false;
		}
		
		public function output(str : String) : void
		{
			outputMessage(str, 0x000000);
		}
		
		public function error(str : String) : void
		{
			var lastChar : String = str.charAt(str.length - 1);
			if(lastChar != "\r" || lastChar != "\n")
			{
				str += "\n";
			}
			outputMessage(str, 0xff0000);
		}
		
		private function outputMessage(str : String, color : int) : void
		{
			var textFormat : TextFormat = textField.defaultTextFormat;
			textFormat.color = color;
			
			var startIndex : int = textField.text.length;
			str = str.replace(/\r\n/g, "\n");
			textField.appendText(str);
			textField.setTextFormat(textFormat, startIndex, startIndex + str.length);
			textField.scrollV = textField.maxScrollV;
		}
	}
}