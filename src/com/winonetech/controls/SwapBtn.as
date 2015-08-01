package com.winonetech.controls
{
	
	/**
	 * 
	 * 交换图片按钮。
	 * 
	 */
	
	import flash.events.MouseEvent;
	
	import mx.controls.Image;
	
	import spark.components.Group;
	
	
	public class SwapBtn extends Group
	{
		
		/**
		 * 
		 * <code>SwapBtn</code>构造函数。
		 * 
		 */
		
		public function SwapBtn()
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
			addElement(bg = new Image);
			addElement(hl = new Image);
			hl.visible       = false;
			hl.mouseEnabled  = false;
			hl.mouseChildren = false;
			bg.setStyle("verticalCenter", 0);
			bg.setStyle("horizontalCenter", 0);
			hl.setStyle("verticalCenter", 0);
			hl.setStyle("horizontalCenter", 0);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		
		/**
		 * @private
		 */
		private function mouseDown(e:MouseEvent):void
		{
			hl.visible = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		/**
		 * @private
		 */
		private function mouseUp(e:MouseEvent):void
		{
			hl.visible = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		
		/**
		 * 
		 * 按钮弹起时显示的图片的路径。
		 * 
		 */
		
		public function set upSource(value:Object):void
		{
			bg.source = value;
		}
		
		
		/**
		 * 
		 * 按钮按下时显示的图片的路径。
		 * 
		 */
		
		public function set downSource(value:Object):void
		{
			hl.source = value;
		}
		
		
		/**
		 * @private
		 */
		private var bg:Image;
		
		/**
		 * @private
		 */
		private var hl:Image;
		
	}
}