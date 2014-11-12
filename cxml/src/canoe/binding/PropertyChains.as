package canoe.binding
{
	import canoe.util.ArrayUtil;
	import canoe.util.ObjectUtil;

	public class PropertyChains implements IBindingExpression
	{
		public function PropertyChains(chains : Array, document : Object)
		{
			this.document = document;
			this.chains = chains;
		}

		private var _chains : Array;
		private var document : Object;
		public function get chains():Array
		{
			return _chains;
		}

		public function set chains(value:Array):void
		{
			_chains = value;
		}
		
		public function getValue() : Object
		{
			return ObjectUtil.getPropertyRecursive(document, chains) || "{" + chains.join(".") + "}";
		}
		
		public function equals(v : PropertyChains) : Boolean
		{
			return ArrayUtil.equals(chains, v.chains);
		}
	}
}