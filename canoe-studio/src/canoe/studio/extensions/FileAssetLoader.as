package canoe.studio.extensions 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	
	import canoe.asset.IAssetLoader;
	import canoe.asset.SymbolMeta;
	import canoe.studio.entity.Project;
	import canoe.util.StringUtil;
	import canoe.util.reflect.Access;
	import canoe.util.reflect.Accessor;
	import canoe.util.reflect.ClassReflector;
	import canoe.util.reflect.Member;
	import canoe.util.reflect.Variable;
	
	[Event(name="complete", type="flash.events.Event")]
	public class FileAssetLoader extends EventDispatcher implements IAssetLoader
	{
		private var _packName : String;

        private var status : int;
		private var globalSymbolMeta : SymbolMeta;
        private const futureDict : Object = {};
		private const symbolMetaDict : Object = {};
		private const metaLoader : Loader = new Loader();
		private var _dir : File;
        /**
		 * @private
		 */
		public function get packName() : String
		{
			return _packName;
		}

		public function get bytesTotal() : int
		{
			return 0;
		}

		public function get bytesLoaded() : int
		{
			return 0;
		}

		public function FileAssetLoader(symbolName : String)
		{
			this._packName = symbolName;
			loadMetaData();
		}
		
		public function get dir() : File
		{
			if(!_dir)
			{
				var basePath : String = Project.currProject.assetPath + File.separator + packName;
				var localeFile : File = new File(basePath + "." + Project.currProject.locale + ".swf");
				
				_dir = localeFile.exists ? localeFile : new File(basePath + ".swf");
			}

			return _dir;
		}
		
		public function loadMetaData() : void
		{
			var metafile : File = dir.resolvePath("metadata.xml");
			if(metafile.exists)
			{
				var fileStream : FileStream = new FileStream();
				fileStream.open(metafile, FileMode.READ);
				var content : String = fileStream.readMultiByte(fileStream.bytesAvailable, "utf-8");
				fileStream.close();
				
				var xml : XML =  XML(content);
				for each(var metaXML : XML in xml.*)
				{
					parseSymbolMeta(metaXML);
				}
				System.disposeXML(xml);
			}
		}
		
		private function parseSymbolMeta(xml : XML) : void
		{
			var symbolMeta : SymbolMeta = new SymbolMeta();
			
			var isGlobal : Boolean = (xml.name() == "global");
			
			var symbolName : String = null;
			
			if(!isGlobal)
			{
				symbolName = xml.@name;
				symbolMeta.symbolName = symbolName;
			}
			
			symbolMeta.quality = xml.@quality;
			symbolMeta.sliceRows = xml.@sliceRows;
			symbolMeta.sliceCols = xml.@sliceCols;
			
			var tstr : String = xml.@scale9Grid;
			var tarr : Array;
			if(tstr)
			{
				tarr = tstr.split(",");
				symbolMeta.scale9Grid = new Rectangle(int(StringUtil.trim(tarr[0])), int(StringUtil.trim(tarr[1])), int(StringUtil.trim(tarr[2])), int(StringUtil.trim(tarr[3])));
			}
			
			tstr = xml.@corePoint;
			if(tstr)
			{
				tarr = tstr.split(",");
				symbolMeta.corePoint = new Point(int(StringUtil.trim(tarr[0])), int(StringUtil.trim(tarr[1])));
			}
			
			if(isGlobal)
			{
				globalSymbolMeta = symbolMeta;
			}
			else
			{
				symbolMetaDict[symbolName] = symbolMeta;
			}
		}
		
		public function load() : void
		{
		}

		public function get completed() : Boolean
		{
			return true;
		}
		
		public function getBitmapData(symbolName : String) : BitmapData
		{
			var future : BitmapDataFuture = futureDict[symbolName];
			return future == null ? null : future.bitmapData;
		}
        
        public function getClass(symbolName : String) : Class
		{
			return null;
		}
		
		public function bindBitmap(symbolName : String, bitmap : Bitmap) : void
		{
			
			doBind(symbolName, bitmap);
		}
		
		public function unbindBitmap(symbolName : String, bitmap : Bitmap) : void
		{
			
			doUnbind(symbolName, bitmap);
		}
		
		public function bind(symbolName : String, setter : Function) : void
		{
			doBind(symbolName, setter);
		}

		public function unbind(symbolName : String, setter : Function) : void
		{
			doUnbind(symbolName, setter);
		}
		
		private function doBind(symbolName : String, binding : *) : void
		{
			var future : BitmapDataFuture = futureDict[symbolName];
			if(future == null)
			{
				future = new BitmapDataFuture(this, symbolName);
				futureDict[symbolName] = future;
			}
			
			future.bind(binding);
		}
		
		private function doUnbind(symbolName : String, binding : *) : void
		{
			var future : BitmapDataFuture = futureDict[symbolName];
			if(future != null)
			{
				future.unbind(binding);
			}
		}
		
		
        public function disposeBitmapData(name : String) : void
		{
			
		}
		
		public function getSymbolMeta(symbolName : String) : SymbolMeta
		{
			var meta : SymbolMeta = symbolMetaDict[symbolName];
			
			if(!meta && globalSymbolMeta)
			{
				meta = cloneSymbolMeta(globalSymbolMeta);
				symbolMetaDict[symbolName] = meta;
			}

			return meta;
		}
		
		private function cloneSymbolMeta(symbolMeta : SymbolMeta) : SymbolMeta
		{
			var reflector : ClassReflector = ClassReflector.reflect(SymbolMeta);
			var newMeta : SymbolMeta = new SymbolMeta();
			for each(var member : Member in reflector.members)
			{
				if((member is Accessor && Accessor(member).access == Access.READWRITE) || (member is Variable))
				{
					newMeta[member.name] = symbolMeta[member.name];
				}
			}

			return newMeta;
		}
		
		public function disposeAll() : void
		{
			
		}
	}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;

import canoe.asset.SymbolMeta;
import canoe.studio.entity.Project;
import canoe.studio.extensions.FileAssetLoader;
import canoe.studio.util.BitmapDataUtil;
import canoe.util.ArrayUtil;

class BitmapDataFuture
{
	private static const ERROR_BITMAPDATA : BitmapData = new BitmapData(10, 10, true, 0x88ff0000);
	
	private var assetLoader : FileAssetLoader;
	private var symbolName : String;
    private var loader : Loader;
    private var _bitmapData : BitmapData;
	private var bindings : Array;
	
	public function BitmapDataFuture(assetLoader : FileAssetLoader, symbolName : String) : void
	{
		this.symbolName = symbolName;
		this.assetLoader = assetLoader;
		bindings = [];
        var pathBase : String = symbolName.replace(".", File.separator);
		var path : String;
		for each(var extention : String in [".png", ".jpg", ".gif", "jpeg"])
		{
			var pathTmp : String = pathBase + extention;
			var file : File = assetLoader.dir.resolvePath(pathTmp);
			if(file.exists)
			{
				path = file.nativePath;
				break;
			}
		}
		
		if(path != null)
		{
			loader = new Loader();
	        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, completeHandler);
			loader.load(new URLRequest(path));
		}
		else
		{
			completeHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR));	
		}
	}
	
    public function get bitmapData() : BitmapData
	{
		return _bitmapData;
	}
	
	public function bind(binding : Object) : void
	{
		if(bitmapData)
		{
			applyBinding(binding);
		}
		else
		{
			bindings.push(binding);
		}
	}
	
	public function unbind(binding : Object) : void
	{
		ArrayUtil.removeElements(bindings, binding);
	}
	
	private function applyBinding(binding : Object) : void
	{
		if(binding is Bitmap)
		{
			Bitmap(binding).bitmapData = bitmapData;
		}
		else if(binding is Function)
		{
			var setter : Function = binding as Function;
			if(setter.length == 0)
			{
				setter();
			}
			else if(setter.length == 1)
			{
				setter(bitmapData);
			}
			else
			{
				setter(bitmapData, assetLoader);
			}
		}
	}
	
	private function completeHandler(event : Event) : void
	{
		if(event is IOErrorEvent)
		{
			_bitmapData = ERROR_BITMAPDATA;
		}
		else
		{
			_bitmapData = Bitmap(loader.content).bitmapData;
			
			var symbolMeta : SymbolMeta = assetLoader.getSymbolMeta(symbolName);
			
			if(symbolMeta)
			{
				var scale : Number = 1;
				if(symbolMeta.scale)
				{
					scale = symbolMeta.scale;
					_bitmapData = BitmapDataUtil.scale(_bitmapData, scale, scale);
				}
				
				if(symbolMeta.corePoint)
				{
					var oldPoint : Point = symbolMeta.corePoint;
					
					var rect : Rectangle = BitmapDataUtil.getColorBounds(_bitmapData);
					_bitmapData = BitmapDataUtil.getSubBitmapData(_bitmapData, rect);
					
					symbolMeta.corePoint = new Point((int) (oldPoint.x * scale) - rect.x,
						(int) (oldPoint.y * scale) - rect.y);
				}
			}
		}
		
		for each(var binding : * in bindings)
		{
			applyBinding(binding);
		}
		
		bindings = null;
	}
}