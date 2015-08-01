package com.winonetech.utils
{
	
	/**
	 * 
	 * 弹窗工具。
	 * 
	 */
	
	
	import cn.vision.core.NoInstance;
	import cn.vision.data.Tip;
	
	import mx.controls.Alert;
	
	
	public final class TipUtil extends NoInstance
	{
		
		/**
		 * 
		 * 弹窗提示，在控件中选择一个按钮或按下 Esc 或 Enter 键时，将关闭该控件。
		 * 
		 * @param $tip:Tip 提示数据结构。
		 * @param $flags:uint (default = 4) 显示的按钮。有效值为 Alert.OK、Alert.CANCEL、Alert.YES 和 Alert.NO。
		 * 默认值为 Alert.OK。使用按位 OR 运算符可显示多个按钮。例如，传递 (Alert.YES | Alert.NO) 显示“是”和“否”按钮。
		 * 无论按怎样的顺序指定按钮，它们始终按照以下顺序从左到右显示：“确定”、“是”、“否”、“取消”。
		 * @param $handler:Function (default = null) 按下任意按钮时将调用的事件处理函数。传递给此处理函数的事件对象
		 * 是 CloseEvent 的一个实例；此对象的 detail 属性包含 Alert.OK、Alert.CANCEL、Alert.YES、Alert.NO 值。
		 * @param $default:uint (default = 4) 指定默认按钮的位标志。您可以指定一个值，并且只能是 Alert.OK、
		 * Alert.CANCEL、Alert.YES 或 Alert.NO 中的一个值。默认值为 Alert.OK。按 Enter 键触发默认按钮，与单击此按钮
		 * 的效果相同。按 Esc 键触发“取消”或“否”按钮，与选择相应按钮的效果相同。
		 * 
		 */
		
		public static function tip($tip:Tip, $flags:uint = 4, $handler:Function = null, $default:uint = 4):Alert
		{
			return Alert.show($tip.content, $tip.title, $flags, null, $handler, null, $default, null);
		}
		
	}
}