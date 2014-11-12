package canoe.managers.impl
{
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	import canoe.asset.AssetLoaderChannel;
	import canoe.asset.AssetLoaderFactory;
	import canoe.asset.AssetURI;
	import canoe.asset.IAssetLoader;
	import canoe.asset.IAssetLoaderFactory;
	import canoe.asset.IAssetMetaProvider;
	import canoe.managers.IAssetManager;
	
	public class AssetManagerImpl implements IAssetManager
	{
		private const loaderDict : Dictionary = new Dictionary();
		private const channelDict : Object = {};
		private const defaultLoaderFactory : IAssetLoaderFactory = new AssetLoaderFactory();
		private const _defaultChannel : AssetLoaderChannel = new AssetLoaderChannel();
		
		private var _assetLoaderFactory : IAssetLoaderFactory;
		private var _assetMetaProvider : IAssetMetaProvider;
		
		public function get assetMetaProvider():IAssetMetaProvider
		{
			return _assetMetaProvider;
		}

		public function set assetMetaProvider(value:IAssetMetaProvider):void
		{
			_assetMetaProvider = value;
		}

		public function get assetLoaderFactory():IAssetLoaderFactory
		{
			return _assetLoaderFactory || defaultLoaderFactory;
		}
		
		public function set assetLoaderFactory(value:IAssetLoaderFactory):void
		{
			_assetLoaderFactory = value;
		}
		
		public function get defaultChannel() : AssetLoaderChannel
		{
			return _defaultChannel;
		}
		
		public function getAssetLoader(packName : String)  : IAssetLoader
		{
			return loaderDict[packName];
		}
		
		public function createAssetLoader(packName : String) : IAssetLoader
		{
			var loader : IAssetLoader = getAssetLoader(packName);
			
			if(!loader)
			{
				loader = assetLoaderFactory.createAssetLoader(packName);
				loaderDict[packName] = loader;
			}
			
			return loader;
		}
		
		public function addChannel(channelName : String) : AssetLoaderChannel
		{
			var channel : AssetLoaderChannel = channelDict[channelName];
			if(!channel)
			{
				channel = new AssetLoaderChannel();
				channelDict[channelName] = channel;
			}
			
			return channel;
		}
		
		public function getChannel(channelName : String) : AssetLoaderChannel
		{
			return channelDict[channelName];
		}
		
		public function removeChannel(name : String) : AssetLoaderChannel
		{
			var channel : AssetLoaderChannel = getChannel(name);
			if(channel && channel.loadingLoader != null)
			{
				throw new Error("the channel named " + name + " is bussy, can't be removed");
			}
			delete channelDict[name];
			return channel;
		}
		
		public function bind(assetURI : AssetURI, setter : Function) : IAssetLoader
		{
			var channel : AssetLoaderChannel = getChannelByURI(assetURI);
			var assetLoader : IAssetLoader = channel.load(assetURI.packName);
			assetLoader.bind(assetURI.symbolName, setter);
			
			return assetLoader;
		}
		
		public function unbind(assetURI : AssetURI, setter : Function) : IAssetLoader
		{
			var assetLoader : IAssetLoader = getAssetLoader(assetURI.packName);
			if(assetLoader)
			{
				assetLoader.unbind(assetURI.symbolName, setter);
			}
			
			return assetLoader;
		}

		public function bindBitmap(assetURI : AssetURI, bitmap : Bitmap) : IAssetLoader
		{
			var channel : AssetLoaderChannel = getChannelByURI(assetURI);
			var assetLoader : IAssetLoader = channel.load(assetURI.packName);
			assetLoader.bindBitmap(assetURI.symbolName, bitmap);
			
			return assetLoader;
		}
		
		public function unbindBitmap(assetURI : AssetURI, bitmap : Bitmap) : IAssetLoader
		{
			var assetLoader : IAssetLoader = getAssetLoader(assetURI.packName);
			if(assetLoader)
			{
				assetLoader.unbindBitmap(assetURI.symbolName, bitmap);
			}
			
			return assetLoader;
		}
		
		private function getChannelByURI(assetURI : AssetURI) : AssetLoaderChannel
		{
			if(assetURI.channelName)
			{
				var channel : AssetLoaderChannel = getChannel(assetURI.channelName);
				if(!channel)
				{
					throw new Error("there is no AssetChannel named " + assetURI.channelName);
				}
				
				return channel;
			}
			else
			{
				return defaultChannel;
			}
		}
	}
}