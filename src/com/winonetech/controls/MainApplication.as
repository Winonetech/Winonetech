package com.winonetech.controls
{
	
	/**
	 * 
	 * 主程序。
	 * 
	 */
	
	
	import cn.vision.utils.ApplicationUtil;
	import cn.vision.utils.TimerUtil;
	
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import mx.events.ResizeEvent;
	
	import spark.components.WindowedApplication;
	
	
	public class MainApplication extends WindowedApplication
	{
		
		/**
		 * 
		 * <code>MainApplication</code>构造函数。
		 * 
		 */
		
		public function MainApplication()
		{
			super();
			
			initializeEnvironment();
		}
		
		
		/**
		 * @private
		 */
		private function initializeEnvironment():void
		{
			var rect:Rectangle = Screen.mainScreen.bounds;
			width  = rect.width;
			height = rect.height;
			
			timer = new Timer(33);
			timer.addEventListener(TimerEvent.TIMER, handlerTimer);
			timer.start();
			
			addEventListener(Event.CLOSING, handlerClosing);
		}
		
		
		/**
		 * @private
		 */
		private function handlerTimer($e:TimerEvent):void
		{
			var rect:Rectangle = Screen.mainScreen.bounds;
			if (lastWidth && lastHeight)
			{
				if (lastWidth  != rect.width ||
					lastHeight != rect.height)
				{
					width  = lastWidth  = rect.width;
					height = lastHeight = rect.height;
					if (nativeWindow)
					{
						nativeWindow.width  = width;
						nativeWindow.height = height;
					}
					
					dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
				}
			}
			else
			{
				lastWidth  = rect.width;
				lastHeight = rect.height;
			}
		}
		
		/**
		 * @private
		 */
		private function handlerClosing($e:Event):void
		{
			removeEventListener(Event.CLOSING, handlerClosing);
			$e.preventDefault();
			if (onClosing != null) onClosing();
			TimerUtil.callLater(10, ApplicationUtil.exit);
		}
		
		
		/**
		 * 
		 * 关闭窗体回调。
		 * 
		 */
		
		public var onClosing:Function;
		
		
		/**
		 * @private
		 */
		private var lastWidth:Number;
		
		/**
		 * @private
		 */
		private var lastHeight:Number;
		
		/**
		 * @private
		 */
		private var timer:Timer;
		
	}
}