package
{
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import canoe.components.Application;
	import canoe.components.Button;
	import canoe.managers.AssetManager;
	import canoe.managers.TextStyleManager;
	
	
	[SWF(frameRate="60")]
	public class Main extends Application
	{
		override protected function create() : void
		{
			super.create();

			_preset();
			
			TextStyleManager.instance.load(new URLRequest("style.css"));
			AssetManager.assetMetaProvider = new AssetMetaProvider();
			
			var button : Button = new Button();
			button.label = "hello,world";
			button.addEventListener(MouseEvent.CLICK, button_clickHandler);
			addChild(button);
		}
		
		protected function button_clickHandler(event:MouseEvent):void
		{
			alert("hello,world");
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

		if(name == "lang")
			assetMeta.url = name + "." + locale + ".swf";
		else
			assetMeta.url = name + ".swf";
		
		return assetMeta;
	}
}
