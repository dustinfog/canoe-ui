package canoe.util
{
	public class Closure
	{
		private var func : Function;
		private var args : Array;
		public function Closure(func : Function, ... args)
		{
			this.func = func;
			this.args = args;
		}
		
		public function invoke(... gapArgs) : *
		{
			var actualArgs : Array = args;
			
			while(func.length > actualArgs.length && gapArgs.length > 0)
			{
				if(actualArgs == args)
					actualArgs = args.concat();

				actualArgs.push(gapArgs.shift());
			}
			
			return func.apply(null, actualArgs);
		}
	}
}