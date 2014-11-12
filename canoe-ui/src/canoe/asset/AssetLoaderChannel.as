package canoe.asset 
{
	import canoe.managers.AssetManager;
	import canoe.util.ArrayUtil;
	import canoe.util.Iterator;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.Dictionary;

	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
    [Event(name="open", type="flash.events.Event")]
	public class AssetLoaderChannel extends EventDispatcher
	{
		private const queue : Array = [];
		private const callbackDict : Dictionary = new Dictionary();
		private var _loadingLoader : IAssetLoader;
		private var bytesTotal : int;
		private var bytesLoaded : int;
        private var _loadersTotal : int;
        private var _loadersLoaded : int;

		public function get loadingLoader() : IAssetLoader
		{
			return _loadingLoader;
		}
        
		public function get loadersTotal() : int
		{
			return _loadersTotal;
		}
        
		public function get loadersLoaded() : int
		{
			return _loadersLoaded;
		}

        public function loadAll(urls : Array, loadedCallback : Function = null) : void
		{
			urls = urls.concat();
			for(var itr : Iterator = new Iterator(urls); itr.hasNext();)
			{
				var url : String = itr.next();
				
				var assetLoader : IAssetLoader = load(url);
				if(!assetLoader || assetLoader.completed)
				{
					itr.remove();
				}
			}
			
            if(loadedCallback != null)
			{
				if(urls.length == 0)
				{
					loadedCallback();
				}
				else
				{
					callbackDict[urls] = loadedCallback;
				}
			}
		}

		public function load(name : String) : IAssetLoader
		{
            if(name == null) return null;

			var assetLoader : IAssetLoader = AssetManager.getAssetLoader(name);
			
			if(!assetLoader)
			{
				assetLoader = AssetManager.createAssetLoader(name);
				assetLoader.addEventListener(ProgressEvent.PROGRESS, assetLoader_progressHandler);
				assetLoader.addEventListener(Event.COMPLETE, assetLoader_completeHandler);
				assetLoader.addEventListener(IOErrorEvent.IO_ERROR, assetLoader_completeHandler);
				
				if(_loadingLoader == null)
				{
					_loadingLoader = assetLoader;
					assetLoader.load();

					bytesTotal = assetLoader.bytesTotal;
					bytesLoaded = 0;
                    _loadersTotal = 1;
					_loadersLoaded = 0;
                    dispatchEvent(new Event(Event.OPEN));
				}
				else
				{
					queue.push(assetLoader);
                    bytesTotal += assetLoader.bytesTotal;
					_loadersTotal ++;
				}
			}
			
			return assetLoader;
		}
		
		private function assetLoader_progressHandler(event:ProgressEvent):void
		{
			var queueEvent : ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
			queueEvent.bytesTotal = bytesTotal;
			queueEvent.bytesLoaded = bytesLoaded + event.bytesLoaded;
			dispatchEvent(queueEvent);
		}
		
		private function assetLoader_completeHandler(event:Event):void
		{
            var packName : String = _loadingLoader.packName;

			bytesLoaded += _loadingLoader.bytesTotal;
			_loadersLoaded ++;
			
			_loadingLoader.removeEventListener(Event.COMPLETE, assetLoader_completeHandler);
			_loadingLoader.removeEventListener(IOErrorEvent.IO_ERROR, assetLoader_completeHandler);
			_loadingLoader.removeEventListener(ProgressEvent.PROGRESS, assetLoader_progressHandler);
			
			if(queue.length != 0)
			{
				_loadingLoader = queue.shift();
				_loadingLoader.load();
			}
			else
			{
				var queueEvent:Event=new Event(Event.COMPLETE);
				dispatchEvent(queueEvent);
				
				_loadingLoader = null;
			}

			for(var key : * in callbackDict)
			{
				var urls : Array = key;
				
				ArrayUtil.removeElements(urls, packName);
				
				if(urls.length == 0)
				{
					(callbackDict[urls] as Function)();
					delete callbackDict[urls];
				}
			}
		}
	}
}