package
{
	import flash.net.URLRequest;
	
	import canoe.components.Application;
	import canoe.layout.HLayout;
	import canoe.managers.AssetManager;
	import canoe.managers.TextStyleManager;
	import canoe.sample.view.MainView;
	import canoe.util.Singleton;
	
	
	[SWF(frameRate="60")]
	public class Main extends Application
	{
		private var currentView : *;	
		
		override protected function create() : void
		{
			super.create();

			layout = new HLayout();
			_preset();
			
			TextStyleManager.instance.load(new URLRequest("style.css"));
			
			AssetManager.assetMetaProvider = new AssetMetaProvider();
			switchView(MainView);
		}
		
		public function switchView(viewClass : Class) : void
		{
			if(!(currentView is viewClass))
			{
				if(currentView)
				{
					removeChild(currentView);
				}
				
				currentView = Singleton.getInstance(viewClass);
				addChild(currentView);
			}
		}
	}
}
import canoe.asset.AssetMeta;
import canoe.asset.IAssetMetaProvider;

class AssetMetaProvider implements IAssetMetaProvider
{
	public function getAssetMeta(name : String, locale : String) : AssetMeta
	{
		var assetMeta : AssetMeta = new AssetMeta();

		if(name == "skin")
			assetMeta.url = name + "." + locale + ".swf";
		else
			assetMeta.url = name + ".swf";
		
		return assetMeta;
	}
}
