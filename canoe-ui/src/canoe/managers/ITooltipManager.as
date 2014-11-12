package canoe.managers
{
	import canoe.core.UIElement;

	public interface ITooltipManager
	{
		function registerToolTipClass(dataClass : Class, tooltipClass : *) : void;
		function getTooltipClass(dataClass : Class) : *;
		function listenTooltip(target : UIElement) : void;
		function ignoreTooltip(target : UIElement) : void
	}
}