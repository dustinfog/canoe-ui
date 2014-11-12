package 
{
	import canoe.components.Alert;

	public function confirm(message : String, onOk : Function = null, onCancel : Function = null) : void
	{
		Alert.show(message, Alert.OK | Alert.CANCEL, onOk, onCancel); 
	}
}
