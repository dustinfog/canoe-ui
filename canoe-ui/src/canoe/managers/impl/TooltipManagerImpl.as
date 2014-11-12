package canoe.managers.impl
{
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import canoe.components.Tooltip;
	import canoe.core.IFactory;
	import canoe.core.UIElement;
	import canoe.managers.ITooltipManager;
	import canoe.util.Singleton;
	import canoe.util.reflect.ClassReflector;

	public class TooltipManagerImpl implements ITooltipManager
	{
		private static const tooltipClassDict : Dictionary = new Dictionary();
		private static var currentTooltip : Tooltip;
		
		public function registerToolTipClass(dataClass : Class, tooltipClass : *) : void
		{
			tooltipClassDict[dataClass] = tooltipClass;
		}
		
		public function getTooltipClass(dataClass : Class) : * 
		{
			var tooltipClass : Class = tooltipClassDict[dataClass];
			if(!tooltipClass)
			{
				var reflector : ClassReflector = ClassReflector.reflect(dataClass, true);
				var minIndex : int = int.MAX_VALUE;
				for(var tmpClass : * in tooltipClassDict)
				{   
					var index : int = reflector.extendsClasses.indexOf(tmpClass);
					if(index >= 0 && index < minIndex)
					{
						minIndex = index;
						tooltipClass = tooltipClassDict[tmpClass];
					}
				}
			}
			
			return tooltipClass;
		}
		
		public function listenTooltip(target : UIElement) : void
		{
			target.addEventListener(MouseEvent.MOUSE_OVER, target_mouseOverHandler);
		}
		
		public function ignoreTooltip(target : UIElement) : void
		{
			target.removeEventListener(MouseEvent.MOUSE_OVER, target_mouseOverHandler);
		}
		
		private function target_mouseOverHandler(event:MouseEvent):void
		{
			var target : UIElement = UIElement(event.currentTarget);
			var tooltipClass : * = target.tooltipClass;
			
			if(tooltipClass == null)
			{
				throw new Error("please use [UIElement.tooltipClass] or [TooltipManager.registerToolTipClass] assign the tooltip display class");
			}
			
			
			var tooltip : Tooltip = null;
			if(tooltipClass is Class)
			{
				tooltip = Singleton.getInstance(tooltipClass);
			}
			else if(tooltipClass is IFactory)
			{
				tooltipClass = IFactory(tooltipClass).newInstance();
			}
			
			if(tooltip != currentTooltip)
			{
				if(currentTooltip != null)
				{
					currentTooltip.hide();
				}
				
				tooltip.data = target.tooltipData;
				currentTooltip = tooltip;
			}
			
			target.addEventListener(MouseEvent.MOUSE_OUT, target_mouseOutHandler);
		}
		
		private function target_mouseOutHandler(event:MouseEvent):void
		{
			var target : UIElement = UIElement(event.currentTarget);
			target.removeEventListener(MouseEvent.MOUSE_OUT, target_mouseOutHandler);
			if(currentTooltip)
			{
				currentTooltip.hide();
				currentTooltip = null;
			}
		}
	}
}