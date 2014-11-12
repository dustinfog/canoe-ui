package canoe.sample.utils
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import canoe.util.Closure;
	import canoe.util.ObjectUtil;

	public class HTTPService
	{
		private static var urlLoader:URLLoader;
		private static var queue:Array = [];
		private static var currEntry : RequestEntry;
		
		public static function doGet(url:String, vars:Object = null, callback:Closure = null):void
		{
			doRequest(url, URLRequestMethod.GET, vars, callback);	
		}
		
		public static function doPost(url:String, vars:Object = null, callback:Closure = null):void
		{
			doRequest(url, URLRequestMethod.POST, vars, callback);
		}
		
		private static function doRequest(url : String, method : String, vars : Object, callback : Closure) : void
		{
			var request : URLRequest = new URLRequest(url);
			request.method = method;
			request.data = createURLVariables(vars);
			
			var entry : RequestEntry = new RequestEntry(request, callback);
			
			if(currEntry == null)
			{
				currEntry = entry;
				loadCurrEntry();
			}
			else
			{
				queue.push(entry);
			}
		}
		
		private static function completeHander(evt:Event):void
		{
			var loader:URLLoader = evt.target as URLLoader;
			var data:Object = JSON.parse(loader.data);
			
			if (data.ret > 0)
			{
				alert(data.message);
			}
			else
			{
				currEntry.doComplete(loader.data);
			}
			
			loadNextEntry();
		}
		
		private static function ioErrorHander(evt:Event):void
		{
			alert('rest server io error');
			
			loadNextEntry();
		}
		
		private static function loadNextEntry() : void
		{
			if(queue.length)
			{
				currEntry = queue.shift();
				loadCurrEntry();
			}
			else
			{
				currEntry = null;
			}
		}
		
		private static function loadCurrEntry() : void
		{
			if(urlLoader == null)
			{
				urlLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
				
				urlLoader.addEventListener(Event.COMPLETE, completeHander);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHander);
			}
			
			currEntry.doLoad(urlLoader);
		}
		
		private static function createURLVariables(data : *) : URLVariables
		{
			if(!data || data is URLVariables)
				return data;

			var urlVariables : URLVariables = new URLVariables();
			ObjectUtil.overrideProperties(urlVariables, data);
			return urlVariables;
		}
	}
}
import flash.net.URLLoader;
import flash.net.URLRequest;

import canoe.util.Closure;

class RequestEntry
{
	private var request : URLRequest; 
	private var callback : Closure;

	public function RequestEntry(request : URLRequest, callback : Closure)
	{
		this.request = request;
		this.callback = callback;
	}
	
	public function doLoad(loader : URLLoader) : void
	{
		loader.load(request);
	}

	public function doComplete(data : *) : void
	{
		if(callback)
		{
			callback.invoke(data);
		}
	}
}