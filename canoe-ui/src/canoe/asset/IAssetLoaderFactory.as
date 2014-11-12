package canoe.asset
{
	public interface IAssetLoaderFactory
	{
		function createAssetLoader(name : String) : IAssetLoader;	
	}
}