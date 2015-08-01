package com.winonetech.utils
{
	
	/**
	 * 
	 * 定义了一些常用URI解析函数。
	 * 
	 */
	
	
	import cn.vision.core.NoInstance;
	import cn.vision.utils.StringUtil;
	
	
	public final class CacheUtil extends NoInstance
	{
		
		/**
		 * 
		 * 根据服务端文件路径解析本地缓存路径。
		 * 
		 * @param $uri:String 服务端文件路径。
		 * @param $prefix:String 前缀。
		 * 
		 * @return 本地缓存路径。
		 * 
		 */
		
		public static function extractURI($uri:String, prefix:String = ""):String
		{
			if(!StringUtil.isEmpty($uri))
			{
				var result:String = "";
				var t:Array = $uri.split("/");
				var l:uint = t.length;
				if (l > 3)
				{
					for (var i:int = 3; i < l; i++)
						result += ("/" +t[i]);
				}
				result = StringUtil.isEmpty(prefix) ? result.substr(1) : prefix + result;
			}
			return result;
		}
		
	}
}