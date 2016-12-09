package com.winonetech.controls
{
	/**
	 * 
	 * 覆盖TextInput以便代码控制text属性时触发change事件。
	 * 
	 */
	
	
	import flash.display.InteractiveObject;
	import flash.events.FocusEvent;
	import flash.geom.Point;
	
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;
	
	
	public final class Field extends TextInput
	{
		
		/**
		 * 
		 * <code>Field</code>构造函数。
		 * 
		 */
		
		public function Field()
		{
			super();
			
			addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, textInput_mouseFocusChangeHandler, false, 0, true);
		}
		
		
		/**
		 * @private
		 */
		private function textInput_mouseFocusChangeHandler(e:FocusEvent):void
		{
			dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT));
			
			//获取当前鼠标位置下的物件列表。
			var iobjs:Array = stage.getObjectsUnderPoint(new Point(stage.mouseX, stage.mouseY));
			//设定焦点
			stage.focus = InteractiveObject(iobjs[iobjs.length - 1].parent);
		}
		
	}
}