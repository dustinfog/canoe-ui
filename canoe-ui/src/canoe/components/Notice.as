package canoe.components
{
	internal class Notice
	{
		public function Notice(message : String)
		{
			this.message = message;
		}

		public var message : String;
		public var buttonFlag : int;
		public var onOk : Function;
		public var onCancel : Function;
		
		public function equals(notice : Notice) : Boolean
		{
			return notice != null
				&& message == notice.message
				&& buttonFlag == notice.buttonFlag
				&& onOk == notice.onOk
				&& onCancel == notice.onCancel;
		}
	}
}