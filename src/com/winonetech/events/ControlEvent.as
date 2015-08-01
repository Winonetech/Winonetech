package com.winonetech.events
{
	
	/**
	 * 
	 * 播放控制相关事件。
	 * 
	 */
	
	
	import cn.vision.core.VSEvent;
	
	
	public final class ControlEvent extends VSEvent
	{
		
		/**
		 * 
		 * <code>ControlEvent</code>构造函数。
		 * 
		 * @param $type:String 事件的类型，可以作为 ControlEvent.type 访问。
		 * @param $bubbles:Boolean (default = false) 确定 ControlEvent 对象是否参与事件流的冒泡阶段。默认值为 false。
		 * @param $cancelable:Boolean (default = false) 确定是否可以取消 ControlEvent 对象。默认值为 false。
		 * 
		 */
		
		public function ControlEvent($type:String, $bubbles:Boolean = false, $cancelable:Boolean = false)
		{
			super($type, $bubbles, $cancelable);
		}
		
		
		/**
		 * 
		 * 开始播放时触发。<br>
		 * BEGIN常量定义BEGIN事件的<code>type</code>属性值。
		 * 
		 * @default play
		 * 
		 */
		
		public static const PLAY:String = "play";
		
		
		/**
		 * 
		 * 结束播放时触发。<br>
		 * END常量定义END事件的<code>type</code>属性值。
		 * 
		 * @default stop
		 * 
		 */
		
		public static const STOP:String = "stop";
		
		
		/**
		 * 
		 * 准备完毕时触发。<br>
		 * READY常量定义READY事件的<code>type</code>属性值。
		 * 
		 * @default ready
		 * 
		 */
		
		public static const READY:String = "ready";
		
	}
}