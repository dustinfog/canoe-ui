package canoe.managers
{
	import flash.display.Bitmap;
	
	import canoe.asset.AssetLoaderChannel;
	import canoe.asset.AssetURI;
	import canoe.asset.IAssetLoader;
	import canoe.asset.IAssetLoaderFactory;
	import canoe.asset.IAssetMetaProvider;
	import canoe.managers.impl.AssetManagerImpl;

	public class AssetManager{
		private static const impl : IAssetManager = new AssetManagerImpl();

		public static function get assetMetaProvider():IAssetMetaProvider
		{
			return impl.assetMetaProvider;
		}
		
		public static function set assetMetaProvider(value:IAssetMetaProvider):void
		{
			impl.assetMetaProvider = value;
		}
		
		public static function get assetLoaderFactory():IAssetLoaderFactory
		{
			return impl.assetLoaderFactory;
		}
		
		public static function set assetLoaderFactory(value:IAssetLoaderFactory):void
		{
			impl.assetLoaderFactory = value;
		}
		
		public static function get defaultChannel() : AssetLoaderChannel
		{
			return impl.defaultChannel;
		}
		
		public static function getAssetLoader(packName : String)  : IAssetLoader
		{
			return impl.getAssetLoader(packName);
		}
		
		public static function createAssetLoader(packName : String) : IAssetLoader
		{
			return impl.createAssetLoader(packName);
		}
		
		public static function addChannel(channelName : String) : AssetLoaderChannel
		{
			return impl.addChannel(channelName);
		}
		
		public static function getChannel(channelName : String) : AssetLoaderChannel
		{
			return impl.getChannel(channelName); 
		}
		
		public static function removeChannel(name : String) : AssetLoaderChannel
		{
			return impl.removeChannel(name);
		}
		
		public static function bind(assetURI : AssetURI, setter : Function) : IAssetLoader
		{
			return impl.bind(assetURI, setter);
		}
		
		public static function unbind(assetURI : AssetURI, setter : Function) : IAssetLoader
		{
			return impl.unbind(assetURI, setter);
		}
		
		public static function bindBitmap(assetURI : AssetURI, bitmap : Bitmap) : IAssetLoader
		{
			return impl.bindBitmap(assetURI, bitmap);
		}
		
		public static function unbindBitmap(assetURI : AssetURI, bitmap : Bitmap) : IAssetLoader
		{
			return impl.unbindBitmap(assetURI, bitmap);
		}
	}
}