package canoe.state
{
	import canoe.asset.AssetURI;
	import canoe.managers.AssetManager;
	import canoe.util.PropertyProxy;

	public class CXMLAssetOverride implements IOverride
	{
        private var assetURI : AssetURI;
		private var proxy : PropertyProxy;

		public function CXMLAssetOverride(target:Object, prop:String, assetURI : AssetURI)
		{
			proxy = PropertyProxy.getInstance(target, prop);
			this.assetURI = assetURI;
		}
		
		public function apply():void
		{
			AssetManager.bind(assetURI, proxy.setter);
		}
		
		public function remove():void
		{
			AssetManager.unbind(assetURI, proxy.setter);
		}
	}
}