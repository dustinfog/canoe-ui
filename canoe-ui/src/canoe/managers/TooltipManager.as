package canoe.managers
{
	import canoe.core.UIElement;
	import canoe.managers.impl.TooltipManagerImpl;

	public class TooltipManager
	{
		private static const impl : ITooltipManager = new TooltipManagerImpl();
		public static function registerToolTipClass(dataClass : Class, tooltipClass : Class) : void
		{
			impl.registerToolTipClass(dataClass, tooltipClass);
		}
		public static function getTooltipClass(dataClass : Class) : *
		{
			return impl.getTooltipClass(dataClass);
		}
		public static function listenTooltip(target : UIElement) : void
		{
			impl.listenTooltip(target);
		}
		public static function ignoreTooltip(target : UIElement) : void
		{
			impl.ignoreTooltip(target);
		}
	}
}