package canoe.asset
{
	import canoe.core.CanoeGlobals;
	import canoe.managers.AssetManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	public class AssetLoader extends EventDispatcher implements IAssetLoader
	{
		private static const STATUS_READY : int = 0;
		private static const STATUS_LOADING : int = 1;
		private static const STATUS_LOAD : int = 2;
		
		private var _bytesTotal : int;
		private var _bytesLoaded : int;
		private var _packName : String;

		private var loader : Loader;
		private var bitmapDataDict : Dictionary;
        private var coreData : Object;
		private var retryTimes : int = 2;
        private var status : int;
        private var assetMeta : AssetMeta;
		private var bindingDict : Dictionary;
		private var globalSymbolMeta : SymbolMeta;
		private var symbolMetaDict : Object;
		
		public function get packName() : String
		{
			return _packName;
		}

		public function get bytesTotal() : int
		{
            if(_bytesTotal == 0 && assetMeta)
			{
				_bytesTotal = assetMeta.size;
			}

			return _bytesTotal;
		}

		public function get bytesLoaded() : int
		{
			return _bytesLoaded;
		}

		public function AssetLoader(name : String)
		{
			bitmapDataDict = new Dictionary();

			this._packName = name;
			
			if(AssetManager.assetMetaProvider)
			{
				assetMeta = AssetManager.assetMetaProvider.getAssetMeta(name, CanoeGlobals.locale);
			}

			loader = new Loader();
            loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		}
		
		private function progressHandler(event:ProgressEvent):void
		{
			_bytesTotal = event.bytesTotal;
			_bytesLoaded = event.bytesLoaded;
			
			dispatchEvent(event);
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);

			if(completed && type == Event.COMPLETE)
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function load() : void
		{
			if(status == STATUS_READY)
			{
				var urlRequest : URLRequest = new URLRequest(assetMeta ? assetMeta.url : (packName + ".swf"));

				loader.load(urlRequest);
                status = STATUS_LOADING;
			}
		}

		public function get completed() : Boolean
		{
			return status == STATUS_LOAD;
		}
		
		private function errorHandler(event:IOErrorEvent):void
		{
			if(retryTimes >= 0)
			{
				status = STATUS_READY;
				load();
				retryTimes --;
			}
			else
			{
	            dispatchEvent(event);
			}
		}
		
		private function completeHandler(event:Event):void
		{
			status = STATUS_LOAD;
			
			loadMetaData();
			
           	for(var binding : * in bindingDict) 
			{
				var bitmapData : BitmapData = getBitmapData(bindingDict[binding])
				
				if(binding is Bitmap)
				{
					Bitmap(binding).bitmapData = bitmapData;
				}
				else
				{
					invokeBindingSetter(binding, bitmapData);
				}
			}
			bindingDict = null;
			dispatchEvent(event);
		}
		
		public function getClass(symbolName : String) : Class
		{
			if(!completed) return null;

			var applicationDomain : ApplicationDomain = loader.contentLoaderInfo.applicationDomain;
			return applicationDomain.hasDefinition(symbolName) ? (applicationDomain.getDefinition(symbolName) as Class) : null;
		}
		
		public function getBitmapData(symbolName : String) : BitmapData
		{
			if (!bitmapDataDict[symbolName]){
				bitmapDataDict[symbolName] = createBitmapData(symbolName);
			}
			return bitmapDataDict[symbolName];
		}
		
        public function disposeBitmapData(symbolName : String) : void
		{
			var bitmapData : BitmapData = BitmapData(bitmapDataDict[symbolName]);
            if(bitmapData != null)
			{
				bitmapData.dispose();
				delete bitmapDataDict[symbolName];
			}
		}
		
		public function disposeAll() : void
		{
			for(var name : String in bitmapDataDict)
			{
                disposeBitmapData(name);
			}
		}
		
		public function createBitmapData(symbolName : String) :BitmapData
		{
			var klass : Class = getClass(symbolName);
			return klass ? (new klass(0, 0) as BitmapData) : null;
		}
		
		public function bindBitmap(symbolName : String, bitmap : Bitmap) : void
		{
			if(completed)
			{
				bitmap.bitmapData = getBitmapData(symbolName);
			}
			else
			{
				saveBinding(symbolName, bitmap);
			}
		}
		
		public function unbindBitmap(symbolName : String, bitmap : Bitmap) : void
		{
			removeBinding(symbolName, bitmap);
		}
		
		public function bind(symbolName : String, setter : Function) : void
		{
			if(completed)
			{
				invokeBindingSetter(setter, getBitmapData(symbolName));
			}
			else
			{
				saveBinding(symbolName, setter);
			}
		}
		
		public function unbind(symbolName : String, setter : Function) : void
		{
			removeBinding(symbolName, setter);
		}
		
		private function saveBinding(symbolName : String, target : Object) : void
		{
			if(bindingDict == null)
			{
				bindingDict = new Dictionary();
			}
			
			bindingDict[target] = symbolName;
		}
		
		private function removeBinding(symbolName : String, target : Object) : void
		{
			if(bindingDict == null) return;
			
			if(bindingDict[target] == symbolName)
			{
				delete bindingDict[target];
			}
		}
		
		private function invokeBindingSetter(setter : Function, bitmapData : BitmapData) : void
		{
			if(setter.length == 0)
				setter();
			else if(setter.length == 1)
				setter(bitmapData);
			else
				setter(bitmapData, this);
		}
		
		public function getSymbolMeta(symbolName : String) : SymbolMeta
		{
			return (symbolMetaDict ? symbolMetaDict[symbolName] : null) || globalSymbolMeta;
		}
		
		private function loadMetaData() : void
		{
			var metaClass : Class = getClass("metadata");
			if(metaClass)
			{
				var bytes : ByteArray = ByteArray(new metaClass());
				bytes.uncompress();

				symbolMetaDict = {};
				var metaSrces : Array = bytes.readObject();
				for each(var metaSrc : Object in metaSrces)
				{
					var symbolMeta : SymbolMeta = new SymbolMeta();
					
					for(var key : String in metaSrc)
					{
						var value : * = metaSrc[key];
						if(key == "scale9Grid")
						{
							symbolMeta.scale9Grid = new Rectangle(value[0], value[1], value[2], value[3]);
						}
						else if(key == "corePoint")
						{
							symbolMeta.corePoint = new Point(value[0], value[1]);
						}
						else
						{
							symbolMeta[key] = value;
						}
					}
					
					var symbolName : String = symbolMeta.name;
					if(!symbolName)
					{
						globalSymbolMeta = symbolMeta;
					}
					else
					{
						symbolMetaDict[symbolName] = symbolMeta;
					}
				}
			}
		}
	}
}