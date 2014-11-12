package canoe.binding
{
	import canoe.asset.AssetURI;
	import canoe.managers.AssetManager;
	import canoe.core.IBinding;

	public class AssetBinding implements IBinding
	{
		private var setter : Function;
		private var uriGetter : Function;
		private var assetURI : AssetURI;

		public function AssetBinding(setter : Function, uriGetter : Function)
		{
			this.setter = setter;
			this.uriGetter = uriGetter;
		}
		/**
		 *  绑定数据 
		 * 
		 */
		public function apply():void
		{
			assetURI = AssetURI.parse(uriGetter());			
			AssetManager.bind(assetURI, setter);
		}
		/**
		 *   取消绑定数据
		 * 
		 */		
		public function clear() : void
		{
			AssetManager.unbind(assetURI, setter);
		}
	}
}