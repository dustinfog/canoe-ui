package canoe.asset
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public dynamic class SymbolMeta
	{
		public var name : String;
		public var scale9Grid : Rectangle;
		public var corePoint : Point;
		public var sliceRows : uint;
		public var sliceCols : uint;
	}
}