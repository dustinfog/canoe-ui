package canoe.studio.panel
{
	import flash.display.DisplayObject;
	
	import avmplus.getQualifiedClassName;
	
	import canoe.core.IElement;
	import canoe.studio.editor.DnRController;

	public class DnRDelegate
	{
		private var _target : DnRController;
		private var _children : Array;
		private var _branches : Array;
		private var _descendants : Array;
		public function DnRDelegate(ctrlr : DnRController)
		{
			this.target = ctrlr;
		}
		
		public function get target():DnRController
		{
			return _target;
		}

		public function set target(value:DnRController):void
		{
			_target = value;
		}

		public function get children() : Array
		{
			if(!(target.source.isContainer))
				return undefined;
			
			if(!_children)
			{
				_children = [];
				for (var i : uint = 0; i < target.numChildren; i ++)
				{
					_children.push(new DnRDelegate(target.getChildAt(i) as DnRController));
				}
			}
			
			return _children;
		}
		
		public function get branches() : Array
		{
			if(!(target.source.isContainer))
				return undefined;

			if(!_branches)
			{
				_branches = [this];
				for each(var child : DnRDelegate in children)
				{
					if(child.target.source.isContainer)
					{
						_branches.push(child);
						
						if(child.branches)
							_branches.push.apply(_branches, child.branches);
					}
				}
			}
			
			return _branches;
		}
		
		public function lookUp(ctrlr : DnRController) : DnRDelegate
		{
			if(target == ctrlr) return this;
			if(!children) return null;

			for each(var child : DnRDelegate in children)
			{
				var found : DnRDelegate = child.lookUp(ctrlr);
				if(found)
					return found;
			}
			
			return null;
		}
		
		public function select() : void
		{
			target.designer.selectedCtrlr = target;
		}
		
		public function get name() : String
		{
			return getQualifiedClassName(target.source.display).split("::")[1];
		}
		
		public function toString() : String
		{
			var str : String = name;
			var display : DisplayObject = target.source.display;
			if(display is IElement && IElement(display).id)
			{
				str += " (\"" +  IElement(display).id + "\")";
			}
			
			return str;
		}
	}
}