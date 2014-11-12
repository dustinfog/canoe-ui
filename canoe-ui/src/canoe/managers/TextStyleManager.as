package canoe.managers
{
	import canoe.managers.impl.TextStyleManagerImpl;

	public class TextStyleManager
	{
		public static const instance : ITextStyleManager = new TextStyleManagerImpl();
	}
}