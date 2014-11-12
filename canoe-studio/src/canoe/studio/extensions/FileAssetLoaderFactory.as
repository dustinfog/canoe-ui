package canoe.studio.extensions 
{
	import canoe.asset.IAssetLoader;
	import canoe.asset.IAssetLoaderFactory;
	
	public class FileAssetLoaderFactory implements IAssetLoaderFactory
	{
		public function createAssetLoader(name:String):IAssetLoader
		{
			return new FileAssetLoader(name);
		}
	}
}