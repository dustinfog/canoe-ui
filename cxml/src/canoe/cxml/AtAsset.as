package canoe.cxml
{
	import canoe.asset.AssetURI;
	import canoe.binding.BindingUtil;
	import canoe.binding.CXMLAssetBinding;
	import canoe.binding.IBindingExpression;
	import canoe.core.IElement;
	import canoe.managers.AssetManager;
	import canoe.state.BindingOverride;
	import canoe.state.CXMLAssetOverride;
	import canoe.state.State;
	import canoe.util.PropertyProxy;

	public class AtAsset implements IAtProcessor
	{
		public function call(obj:*, prop:String, arguments:Array, state : State, document : IElement):void
		{
			var uri : String = arguments.shift();
			var uriExpr : IBindingExpression = BindingUtil.parseExpression(uri, document);
			
			var assetBinding : CXMLAssetBinding;
			var assetURI : AssetURI;
			if(uriExpr)
			{
				assetBinding = new CXMLAssetBinding(obj, prop, uriExpr);
			}
			else
			{
				assetURI = AssetURI.parse(uri);
			}

            if(state == null)
			{
				if(assetBinding)
				{
					document.registerBinding(assetBinding);
				}
				else
				{
					AssetManager.bind(assetURI, PropertyProxy.getInstance(obj, prop).getter);
				}
			}
			else
			{
				if(assetBinding)
				{
					state.overrides.push(new BindingOverride(assetBinding, document));
				}
				else
				{
					state.overrides.push(new CXMLAssetOverride(obj, prop, assetURI));
				}
			}
		}
	}
}