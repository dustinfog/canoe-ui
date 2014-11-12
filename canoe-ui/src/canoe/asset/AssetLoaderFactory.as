package canoe.asset
{
	public class AssetLoaderFactory implements IAssetLoaderFactory
	{
		public function createAssetLoader(name:String):IAssetLoader
		{
			return new AssetLoader(name);
		}
	}
}