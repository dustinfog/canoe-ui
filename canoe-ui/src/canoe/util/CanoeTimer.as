package canoe.util
{
	import canoe.core.CanoeGlobals;
	
	import flash.display.Stage;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public class CanoeTimer
	{
		private var timer : Timer;
		private var lastTime : int;
		private var entries : Array = [];
		
		public function CanoeTimer(delay : Number = 16)
		{
			timer = new Timer(delay);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
		}
		
		public function get delay() : Number
		{
			return timer.delay;
		}
		
		public function set delay(v : Number) : void
		{
			timer.delay = v;
		}
		
		public function get running() : Boolean
		{
			return timer.running;
		}
		
		public function play() : void
		{
			if(!running)
			{
				lastTime = getTimer();
				timer.start();
			}
		}

		public function run(closure : Closure, repeatCount : int = 0) : void
		{
			entries.push(new TimerEntry(closure, repeatCount));
			play();
		}
		
		public function stop() : void
		{
			timer.stop();
		}

		private function timerHandler(event:TimerEvent):void
		{
			var now : int = getTimer();
			while(now - lastTime > delay && running)
			{
				doTimer();
				lastTime += delay;
			}
		}
		
		private function doTimer() : void
		{
			if(!entries.length)
			{
				stop();
			}
			else
			{
				for(var itr : Iterator = new Iterator(entries); itr.hasNext();)
				{
					var entry : TimerEntry = itr.next();
					if(!entry.invoke(this))
					{
						itr.remove();
					}
				}
			}
		}
	}
}

import canoe.util.CanoeTimer;
import canoe.util.Closure;

class TimerEntry
{
	private var closure : Closure;
	private var repeatCount : int;
	private var tally : int;

	public function TimerEntry(closure : Closure, repeatCount : int)
	{
		this.closure = closure;
		this.repeatCount = repeatCount;
	}
	
	public function invoke(timer : CanoeTimer) : Boolean
	{
		if(repeatCount == 0 || tally < repeatCount)
		{
			return closure.invoke(timer, tally ++);
		}

		return false;
	}
}