package canoe.managers
{
	import flash.display.Bitmap;
	
	import canoe.asset.AssetLoaderChannel;
	import canoe.asset.AssetURI;
	import canoe.asset.IAssetLoader;
	import canoe.asset.IAssetLoaderFactory;
	import canoe.asset.IAssetMetaProvider;

	public interface IAssetManager
	{
		function get assetMetaProvider():IAssetMetaProvider;
		function set assetMetaProvider(value:IAssetMetaProvider):void
		function get assetLoaderFactory():IAssetLoaderFactory;		
		function set assetLoaderFactory(value:IAssetLoaderFactory):void;
		function get defaultChannel() : AssetLoaderChannel;
		function getAssetLoader(packName : String)  : IAssetLoader;
		function createAssetLoader(packName : String) : IAssetLoader;
		function addChannel(channelName : String) : AssetLoaderChannel;
		function getChannel(channelName : String) : AssetLoaderChannel;
		function removeChannel(name : String) : AssetLoaderChannel;
		function bind(assetURI : AssetURI, setter : Function) : IAssetLoader;
		function unbind(assetURI : AssetURI, setter : Function) : IAssetLoader;
		function bindBitmap(assetURI : AssetURI, bitmap : Bitmap) : IAssetLoader;
		function unbindBitmap(assetURI : AssetURI, bitmap : Bitmap) : IAssetLoader;
	}
}