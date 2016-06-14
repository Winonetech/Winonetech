package com.winonetech.core
{
	
	/**
	 * 
	 * 数据结构基类，支持文件存储API。
	 * <AIR Only>
	 * 
	 */
	
	
	import cn.vision.collections.Map;
	import cn.vision.events.pattern.CommandEvent;
	
	import com.winonetech.events.ControlEvent;
	import com.winonetech.tools.Cache;
	
	
	/**
	 * 
	 * 与该VO相关的文件下载完毕时触发。
	 * 
	 */
	
	[Event(name="ready", type="com.winonetech.events.ControlEvent")]
	
	
	[Bindable]
	public class VO extends WO
	{
		
		/**
		 * 
		 * <code>VO</code>构造函数。
		 * 
		 * @param $data:Object (default = null) 初始化的数据，可以是XML，JSON格式的数据，或Object。
		 * 
		 */
		
		public function VO($data:Object = null, $name:String = "vo")
		{
			initialize();
			super($data, $name);
		}
		
		
		/**
		 * 初始化操作。
		 * @private
		 */
		private function initialize():void
		{
			cach = new Map;
		}
		
		
		/**
		 * 
		 * 文件是否存在。
		 * 
		 */
		
		protected function exist($url:String):Boolean
		{
			return Cache.exist($url);
		}
		
		
		/**
		 * 
		 * 注册需要缓存的文件地址。
		 * 
		 * @param $args 一个或多个需要注册的缓存文件地址。
		 * 
		 */
		
		wt function registCache(...$args):void
		{
			for each (var item:* in $args)
			{
				var cache:Cache = (item is String) ? Cache.cache(item) : item;
				if (cache && ! cach[cache.saveURL] && ! Cache.exist(cache.saveURL))
				{
					cache.addEventListener(CommandEvent.COMMAND_END, handlerCacheEnd);
					cach[cache.saveURL] = cache;
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private function handlerCacheEnd($e:CommandEvent):void
		{
			var cache:Cache = Cache($e.command);
			cache.removeEventListener(CommandEvent.COMMAND_END, handlerCacheEnd);
			
			delete cach[cache.saveURL];
			if (ready) dispatchEvent(new ControlEvent(ControlEvent.READY));
		}
		
		
		/**
		 * 
		 * 缓存文件列表。
		 * 
		 */
		
		public function get caches():Map
		{
			return cach;
		}
		
		
		/**
		 * 
		 * 需要加载的相关文件的个数。
		 * 
		 */
		
		public function get numFiles():uint
		{
			return cach.length;
		}
		
		
		/**
		 * 
		 * 数据相关文件已加载完毕。
		 * 
		 */
		
		public function get ready():Boolean
		{
			return ! cach.length;
		}
		
		
		/**
		 * @private
		 */
		private var cach:Map;
		
	}
}