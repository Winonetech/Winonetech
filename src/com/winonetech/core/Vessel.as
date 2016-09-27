package com.winonetech.core
{
	
	/**
	 * 
	 * 容器基类。
	 * 
	 */
	
	
	import cn.vision.system.Callback;
	import cn.vision.utils.ArrayUtil;
	
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	
	public class Vessel extends Group
	{
		
		/**
		 * 
		 * 构造函数。
		 * 
		 */
		
		public function Vessel()
		{
			super();
			
			waitCreationComplete();
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		protected function executeCallbacks():void
		{
			var l:int = callbacks.length;
			var callback:Callback, result:Boolean;
			
			while (--l >= 0)
			{
				callback = ArrayUtil.shift(callbacks);
				result = callback.call();
				if (!result) ArrayUtil.push(callbacks, callback);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override public function addEventListener(
			$type:String, 
			$listener:Function, 
			$useCapture:Boolean = false, 
			$priority:int = 0, 
			$useWeakReference:Boolean = false):void
		{
			var l1:Object = listeners[$type] = listeners[$type] || {};
			var l2:Array = l1[$useCapture] = l1[$useCapture] || [];
			if (l2.indexOf($listener) == -1)
			{
				l2[l2.length] = $listener;
				super.addEventListener($type, $listener, $useCapture, $priority, $useWeakReference);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override public function removeEventListener(
			$type:String, 
			$listener:Function, 
			$useCapture:Boolean = false):void
		{
			var l1:Object = listeners[$type];
			if (l1)
			{
				var l2:Array = l1[$useCapture];
				if (l2)
				{
					var index:int = l2.indexOf($listener);
					if (index!= -1) 
					{
						super.removeEventListener($type, $listener, $useCapture);
						l2.splice(index, 1);
						if(!l2.length) delete l1[$useCapture];
					}
				}
			}
		}
		
		
		/**
		 * 
		 * 申请一个回调函数，该操作在设置属性时将会非常有用。<br>
		 * 该操作需要一个返回 Boolean 类型的函数，回调函数中需要进行必要条件判断才执行下一步操作；
		 * 调用此操作时，首先在设置属性时会执行一次，如果执行不成功（返回false），则在creationComplete之后再次执行。<br>
		 * 队列执行顺序为默认为后进先出。
		 * 
		 * @param $callback:Function 回调函数。
		 * @param $priority:Boolean (default = true) 加入后执行的顺序，为true时，会放在队列开头，优先执行，为false时会放在队列末尾。
		 * @param $args 回调函数的参数。
		 * 
		 */
		
		protected function applyCallback($callback:Function, $priority:Boolean = true, ...$args):void
		{
			const l:uint = $args ? $args.length : 0;
			const callback:Callback = new Callback($callback, $args);
			const different:Function = function($item:Callback, $index:int = 0, $array:Array = null):Boolean
			{
				var r:Boolean =($item.callback != callback.callback), i:uint;
				if(!r && l)
				{
					r =(l != $item.args.length);
					if(!r)
					{
						for (i = 0; i < l; i++)
							if (r =($args[i] != $item.args[i])) break;
					}
				}
				return r;
			};
			
			if (callback.call())
			{
				if (callbacks.length)
				{
					var i:uint = 0;
					while (i < callbacks.length)
					{
						if(!different(callbacks[i])) callbacks.splice(i, 1);
						else i++;
					}
				}
			}
			else
			{
				//如果队列中不包含该属性回调，则插入队列
				if (callbacks.every(different))
				{
					//优先执行时，会加入数组开头，否则加入数组末尾。
					$priority
						? ArrayUtil.unshift(callbacks, callback)
						: ArrayUtil.push   (callbacks, callback);
				}
			}
		}
		
		
		/**
		 * 
		 * 清楚所有的监听事件。
		 * 
		 */
		
		protected function removeAllEventListeners():void
		{
			for (var l1:String in listeners)
			{
				for each (var l2:Array in listeners[l1])
				{
					for each (var handler:Function in l2)
					{
						super.removeEventListener(l1, handler);
					}
				}
				delete listeners[l1];
			}
		}
		
		
		/**
		 * @private
		 */
		private function waitCreationComplete():void
		{
			var handler:Function = function(e:FlexEvent):void
			{
				removeEventListener(FlexEvent.CREATION_COMPLETE, handler);
				
				executeCallbacks();
			};
			addEventListener(FlexEvent.CREATION_COMPLETE, handler, false, int.MAX_VALUE);
		}
		
		
		/**
		 * @private
		 */
		private const listeners:Object = {};
		
		/**
		 * @private
		 */
		private const callbacks:Array = [];
		
	}
}