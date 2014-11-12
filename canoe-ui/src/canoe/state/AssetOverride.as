package canoe.state
{
	import canoe.asset.AssetURI;
	import canoe.managers.AssetManager;

	public class AssetOverride implements IOverride
	{
		private var assetURI : AssetURI;
		private var setter : Function;

		public function AssetOverride(setter : Function, assetURI : AssetURI)
		{
			this.setter = setter;
			this.assetURI = assetURI;
		}
		
		public function apply():void
		{
			AssetManager.bind(assetURI, setter);
		}
		
		public function remove():void
		{
			AssetManager.unbind(assetURI, setter);
		}
	}
}