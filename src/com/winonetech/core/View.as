package com.winonetech.core
{
	
	/**
	 * 
	 * 视图的基类。
	 * 
	 */
	
	
	import cn.vision.interfaces.IID;
	import cn.vision.interfaces.IName;
	import cn.vision.system.Callback;
	import cn.vision.utils.ArrayUtil;
	import cn.vision.utils.ClassUtil;
	import cn.vision.utils.IDUtil;
	import cn.vision.utils.LogUtil;
	
	import com.winonetech.events.ControlEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	
	/**
	 * 
	 * 开始播放时触发。
	 * 
	 */
	
	[Event(name="play", type="com.winonetech.events.ControlEvent")]
	
	
	/**
	 * 
	 * 结束播放时触发。
	 * 
	 */
	
	[Event(name="stop", type="com.winonetech.events.ControlEvent")]
	
	
	public class View extends Group implements IName, IID
	{
		
		/**
		 * 
		 * 构造函数。
		 * 
		 */
		
		public function View()
		{
			super();
			
			initializeEnvironment();
		}
		
		
		/**
		 * 
		 * 开始播放。
		 * 
		 * @param $evt:Boolean (default = true) 是否发送事件。
		 * 
		 */
		
		public function play($evt:Boolean = true):void
		{
			if(!wt::playing)
			{
				wt::playing = true;
				$evt && dispatchEvent(new ControlEvent(ControlEvent.PLAY));
				
				for each (var view:View in views) view.play($evt);
				
				try
				{
					processPlay();
				}
				catch (e:Error)
				{
					LogUtil.log(e.getStackTrace());
				}
			}
		}
		
		
		/**
		 * 
		 * 结束播放。
		 * 
		 * @param $evt:Boolean (default = true) 是否发送事件。
		 * 
		 */
		
		public function stop($evt:Boolean = true):void
		{
			if (wt::playing)
			{
				wt::playing = false;
				for each (var view:View in views) view.stop($evt);
				
				processStop();
				
				
				$evt && dispatchEvent(new ControlEvent(ControlEvent.STOP));
			}
		}
		
		
		/**
		 * @inheritDic
		 */
		
		public function reset():void
		{
			stop(false);
			
			processReset();
			
			removeAllEventListeners();
			
			for each (var view:View in views) view.reset();
			
			removeAllView();
			
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
		 * 播放处理。
		 * 
		 */
		
		protected function processPlay():void { }
		
		
		/**
		 * 
		 * 结束处理。
		 * 
		 */
		
		protected function processStop():void { }
		
		
		/**
		 * 
		 * 重置处理。
		 * 
		 */
		
		protected function processReset():void { }
		
		
		/**
		 * 
		 * 解析数据。
		 * 
		 */
		
		protected function resolveData():void { }
		
		
		/**
		 * 
		 * 注册子视图。
		 * 
		 * @param $view:View 子视图。
		 * 
		 */
		
		protected function registView($view:View):void
		{
			views[$view.vid] = $view;
		}
		
		
		/**
		 * 
		 * 删除子视图。
		 * 
		 * @param $view:View 子视图。
		 * 
		 */
		
		protected function removeView($view:View):void
		{
			delete views[$view.vid];
		}
		
		
		/**
		 * 
		 * 清除所有子视图。
		 * 
		 */
		
		protected function removeAllView():void
		{
			views = {};
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
			var callback:Callback = new Callback($callback, $args);
			var c:Boolean = callback.call();
			var l:uint = $args ? $args.length : 0;
			var different:Function = function($item:Callback, $index:int = 0, $array:Array = null):Boolean
			{
				var r:Boolean =($item.callback != $callback);
				if(!r && l)
				{
					r =(l != $item.args.length);
					if(!r)
					{
						for (var i:uint = 0; i < l; i++)
							if (r =($args[i] != $item.args[i])) break;
					}
				}
				return r;
			};
			if (c)
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
				if (callbacks.every(different))
				{
					$priority
						? ArrayUtil.unshift(callbacks, callback)
						: ArrayUtil.push   (callbacks, callback);
				}
			}
			
		}
		
		
		/**
		 * @private
		 */
		private function initializeEnvironment():void
		{
			wt::className = ClassUtil.getClassName(this);
			wt::vid = IDUtil.generateID();
			
			clipAndEnableScrolling = true;
			views = {};
			
			var handlerCreated:Function = function($e:FlexEvent):void
			{
				removeEventListener(FlexEvent.CREATION_COMPLETE, handlerCreated, true);
				while (callbacks.length) callbacks.shift().call();
				created = true;
			}
			addEventListener(FlexEvent.CREATION_COMPLETE, handlerCreated, true, 0, false);
		}
		
		/**
		 * @private
		 */
		private function removeAllEventListeners():void
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
		 * inheritDoc
		 */
		
		override public function get className():String
		{
			return wt::className;
		}
		
		
		/**
		 * 
		 * 数据模型。
		 * 
		 */
		[Bindable]
		public function get data():VO
		{
			return wt::data;
		}
		
		/**
		 * @private
		 */
		public function set data($value:VO):void
		{
			wt::data = $value;
			
			resolveData();
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		public function get instanceName():String
		{
			return wt::instanceName;
		}
		
		/**
		 * @private
		 */
		public function set instanceName($value:String):void
		{
			wt::instanceName = $value;
		}
		
		
		/**
		 * 
		 * 是否处于播放状态。
		 * 
		 */
		
		public function get playing():Boolean
		{
			return Boolean(wt::playing);
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		public function get vid():uint
		{
			return wt::vid;
		}
		
		
		/**
		 * @private
		 */
		protected var created:Boolean;
		
		
		/**
		 * @private
		 */
		private var views:Object;
		
		
		/**
		 * @private
		 */
		private const listeners:Object = {};
		
		/**
		 * @private
		 */
		private const callbacks:Array = [];
		
		
		/**
		 * @private
		 */
		wt var className:String;
		
		/**
		 * @private
		 */
		wt var data:VO;
		
		/**
		 * @private
		 */
		wt var instanceName:String;
		
		/**
		 * @private
		 */
		wt var playing:Boolean;
		
		/**
		 * @private
		 */
		wt var vid:uint;
		
	}
}