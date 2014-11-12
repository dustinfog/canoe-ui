package canoe.asset
{
	public interface IAssetMetaProvider
	{
		function getAssetMeta(name : String, locale : String) : AssetMeta
	}
}