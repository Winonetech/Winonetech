package com.winonetech.core
{
	
	/**
	 * 
	 * 视图的基类。
	 * 
	 */
	
	
	import cn.vision.interfaces.IID;
	import cn.vision.interfaces.IName;
	import cn.vision.utils.ClassUtil;
	import cn.vision.utils.IDUtil;
	import cn.vision.utils.LogUtil;
	
	import com.winonetech.events.ControlEvent;
	
	import flash.geom.Rectangle;
	
	
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
	
	
	/**
	 * 
	 * 结束播放时触发。
	 * 
	 */
	
	[Event(name="ready", type="com.winonetech.events.ControlEvent")]
	
	
	public class View extends Vessel implements IName, IID
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
		
		public function play($evt:Boolean = true, $force:Boolean = false):void
		{
			if(!wt::playing || $force)
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
		
		public function stop($evt:Boolean = true, $rect:Rectangle = null, $force:Boolean = false):void
		{
			if (wt::playing || $force)
			{
				wt::playing = false;
				
				stopRect = $rect;
				
				stopForce = $force;
				
				processStop();
				
				for each (var item:View in views)
				{
					var rect:Rectangle = new Rectangle(item.x, item.y, item.width, item.height);
					var bool:Boolean = $rect ? $rect.intersects(rect) : false;
					if ((!$rect) || bool)
					{
						item.stop($evt);
						stops[item.vid] = item;
					}
				}
				
				$evt && dispatchEvent(new ControlEvent(ControlEvent.STOP));
			}
		}
		
		
		/**
		 * 
		 * 恢复原状。
		 * 
		 */
		
		public function resume():void
		{
			processResume();
			
			for each (var item:View in stops) item.resume();
			
			stops = {};
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
		 * 恢复处理。
		 * 
		 */
		
		protected function processResume():void { }
		
		
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
			stops = {};
		}
		
		
		/**
		 * 
		 * 发送rady。
		 * 
		 */
		
		protected function dispatchReady():void
		{
			wt::ready = true;
			dispatchEvent(new ControlEvent(ControlEvent.READY))
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
			stops = {};
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
			wt::ready = false;
			
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
		 * 
		 * 是否在缓动过程中。
		 * 
		 */
		
		public function get tweening():Boolean
		{
			return wt::tweening as Boolean;
		}
		
		
		/**
		 * 
		 * 是否已经准备完毕。
		 * 
		 */
		
		public function get ready():Boolean
		{
			return wt::ready as Boolean;
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		public function get vid():uint
		{
			return wt::vid;
		}
		
		
		/**
		 * 
		 * 是否在缓动过程中。
		 * 
		 */
		
		protected var stopRect:Rectangle;
		
		
		/**
		 * 
		 * 是否在缓动过程中。
		 * 
		 */
		
		protected var stopForce:Boolean;
		
		
		/**
		 * @private
		 */
		private var views:Object;
		
		/**
		 * @private
		 */
		private var stops:Object;
		
		
		/**
		 * @private
		 */
		wt var tweening:Boolean;
		
		/**
		 * @private
		 */
		wt var ready:Boolean;
		
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