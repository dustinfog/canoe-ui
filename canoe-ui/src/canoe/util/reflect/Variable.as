package canoe.util.reflect
{
	public class Variable extends Field
	{
		public function setValue(object : Object, value : Object) : void
		{
			object[name] = value;
		}
	}
}