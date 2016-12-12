package com.winonetech.controls
{
	/**
	 * 
	 * 覆盖TextInput以便代码控制text属性时触发change事件。
	 * 
	 */
	
	
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
		}
		
		
		/**
		 * @private
		 */
		override public function set text(value:String):void
		{
			if (text != value)
			{
				super.text = value;
				
				dispatchEvent(new TextOperationEvent(TextOperationEvent.CHANGE));
			}
		}
		
	}
}