package canoe.util
{
	public class Iterator
	{
		private var source : Array;
		private var index : int = -1;
		
		private var removed : Boolean;
		
		public function Iterator(source : Array)
		{
			this.source = source;
		}
		
		public function hasNext() : Boolean
		{
			return index < source.length - 1;
		}
		
		public function next() : *
		{
			if(!hasNext())
			{
				throw new Error("the end");
			}
			
			removed = false;
			return source[++ index];
		}
		
		public function remove() : void
		{
			if(removed){
				throw new Error("current element removed");
			}

			source.splice(index --, 1);
			removed = true;
		}
	}
}