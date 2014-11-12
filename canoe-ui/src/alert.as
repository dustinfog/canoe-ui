package 
{
	import canoe.components.Alert;
	
	public function alert(message : String, onOk : Function = null) : void
	{
       Alert.show(message, Alert.OK, onOk); 
	}
}
