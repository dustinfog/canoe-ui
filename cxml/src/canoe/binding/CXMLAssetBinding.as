package canoe.binding
{
	import canoe.asset.AssetURI;
	import canoe.managers.AssetManager;
	import canoe.util.PropertyProxy;
	import canoe.core.IBinding;

	public class CXMLAssetBinding implements IBinding
	{
		public function CXMLAssetBinding(host : Object, property : String, uriExpr : IBindingExpression)
		{
			proxy = PropertyProxy.getInstance(host, property);
			this.uriExpr = uriExpr;
		}

		private var proxy : PropertyProxy;
		private var uriExpr : IBindingExpression;
		private var assetURI : AssetURI;

		public function apply():void
		{
			assetURI = AssetURI.parse(String(uriExpr.getValue()));			
			AssetManager.bind(assetURI, proxy.setter);
		}
		
		public function clear() : void
		{
			AssetManager.unbind(assetURI, proxy.setter);
		}
	}
}