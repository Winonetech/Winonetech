package com.winonetech.controls
{
	
	/**
	 * 
	 * 图片按钮。<br>
	 * 按下时对颜色通道增加了.1的高亮效果。
	 * 
	 */
	
	
	import cn.vision.utils.ColorUtil;
	
	import flash.events.MouseEvent;
	
	import spark.components.Image;
	
	
	public class ImageButton extends Image
	{
		
		/**
		 * 
		 * <code>ImageButton</code>构造函数。
		 * 
		 */
		
		public function ImageButton()
		{
			super();
			
			initializeEnvironment();
		}
		
		
		/**
		 * @private
		 */
		private function initializeEnvironment():void
		{
			buttonMode = true;
			mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_DOWN, handlerMouseDown);
		}
		
		
		/**
		 * @private
		 */
		private function handlerMouseDown($e:MouseEvent):void
		{
			ColorUtil.highlight(this, .1);
			stage.addEventListener(MouseEvent.MOUSE_UP, handlerMouseUp, false, 0, true);
		}
		
		/**
		 * @private
		 */
		private function handlerMouseUp($e:MouseEvent):void
		{
			ColorUtil.normalize(this);
			if (stage)
			stage.removeEventListener(MouseEvent.MOUSE_UP, handlerMouseUp);
		}
		
		public var extra:Object;
		
	}
}