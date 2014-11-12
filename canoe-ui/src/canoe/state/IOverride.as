package canoe.state
{
	public interface IOverride
	{
		function apply() : void;
		function remove() : void;
	}
}