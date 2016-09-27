package com.winonetech.utils
{
	
	/**
	 * 
	 * 字符串转换工具。
	 * 
	 * 
	 */
	
	import cn.vision.utils.ColorUtil;
	
	
	public final class ConvertUtil
	{
		
		/**
		 * 
		 * 转换字符串为Boolean，字符串如果为 "True", "true", "1" ，则返回true，否则返回false。
		 * 
		 * @param $value 转换的字符串。
		 * 
		 * @return Boolean
		 * 
		 * @see com.winonetech.consts.ConvertConsts.TO_BOOL
		 * 
		 */
		
		public static function toBoolean($value:String):Boolean
		{
			return ! (!$value || $value == "False" || $value == "false" || $value == "0" || $value == "");
		}
		
		
		/**
		 * 
		 * 转换字符串为整数。
		 * 
		 * @param $value 转换的字符串。
		 * 
		 * @return int
		 * 
		 * @see com.winonetech.consts.ConvertConsts.TO_INT
		 * 
		 */
		
		public static function toint($value:String):int
		{
			return int($value);
		}
		
		
		/**
		 * 
		 * 转换字符串为数值。
		 * 
		 * @param $value 转换的字符串。
		 * 
		 * @return Number
		 * 
		 * @see com.winonetech.consts.ConvertConsts.TO_NUMBER
		 * 
		 */
		
		public static function toNumber($value:String):Number
		{
			var num:Number = Number($value);
			return isNaN(num) ? 0 : num;
		}
		
		
		/**
		 * 
		 * 转换字符串为字符串。
		 * 
		 * @param $value 转换的字符串。
		 * 
		 * @return String
		 * 
		 * @see com.winonetech.consts.ConvertConsts.TO_STRING
		 * 
		 */
		
		public static function toString($value:String):String
		{
			return $value;
		}
		
		
		/**
		 * 
		 * 转换字符串为日期。<br>
		 * 该类型返回的Date格式包含完整的日期，时间。
		 * 
		 * @param $value 转换的字符串。
		 * 
		 * @return Date Date格式日期。
		 * 
		 * @see com.winonetech.consts.ConvertConsts.TO_DATE
		 * 
		 */
		
		public static function toDate($value:String):Date
		{
			return $value ? new Date($value.split("-").join("/")) : new Date;
		}
		
		
		/**
		 * 
		 * 转换字符串为正整数，包含颜色值的转换，如以#开头，会转为16进制0x开头。
		 * 
		 * @param $value 转换的字符串。
		 * 
		 * @return uint
		 * 
		 */
		
		public static function touint($value:String):uint
		{
			if ($value && $value.charAt(0) == "#") $value = "0x" + $value.substr(1);
			return uint($value);
		}
		
		
		/**
		 * 
		 * 不做转换。
		 * 
		 * @param $value 转换的值。
		 * 
		 * @return Object
		 * 
		 */
		
		public static function toObject($value:*):Object
		{
			return $value;
		}
		
	}
}