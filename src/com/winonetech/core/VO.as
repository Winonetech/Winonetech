package com.winonetech.core
{
	
	/**
	 * 
	 * 数据结构基类。
	 * 
	 */
	
	
	import adobe.utils.XMLUI;
	
	import cn.vision.collections.Map;
	import cn.vision.core.VSEventDispatcher;
	import cn.vision.events.pattern.CommandEvent;
	import cn.vision.utils.ClassUtil;
	import cn.vision.utils.ObjectUtil;
	import cn.vision.utils.XMLUtil;
	
	import com.winonetech.events.ControlEvent;
	import com.winonetech.tools.Cache;
	import com.winonetech.utils.ConvertUtil;
	
	
	/**
	 * 
	 * 与该VO相关的文件下载完毕时触发。
	 * 
	 */
	
	[Event(name="ready", type="com.winonetech.events.ControlEvent")]
	
	
	[Bindable]
	public class VO extends VSEventDispatcher
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
			super();
			
			initialize($data, $name);
		}
		
		
		/**
		 * 
		 * 解析转换数据。
		 * 
		 */
		
		public function parse($data:Object):void
		{
			if ($data)
			{
				wt::raw = $data;
				if ($data is String)
				{
					var src:String = String($data);
					data = XMLUtil.validate(src)
						?  XMLUtil.convert(XML(src), Object)
						:  JSON.parse(src);
				}
				else if ($data is XML)
				{
					data = XMLUtil.convert($data, Object);
				}
				else
				{
					data = ObjectUtil.clone($data);
				}
			}
			else data = {};
		}
		
		
		/**
		 * 
		 * XML格式缓存数据。
		 * 
		 */
		
		public function toXML():String
		{
			return ObjectUtil.convertXML(data, name);
		}
		
		
		/**
		 * 
		 * json格式缓存数据。
		 * 
		 */
		
		public function toJSON():String
		{
			return JSON.stringify(data);
		}
		
		
		/**
		 * 初始化操作。
		 * @private
		 */
		private function initialize($data:Object, $name:String):void
		{
			name = $name;
			stor = Store.instance;
			disc = {}, rela = {};
			cach = new Map;
			parse($data);
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
		 * 获取属性。
		 * 
		 * @param $name:String 属性名称。
		 * @param $type:Class 数据类型。
		 * @param $qualified:Boolean 是否获取完全限定名。
		 * 
		 * @return * 属性值。
		 * 
		 */
		
		protected function getProperty($name:String, $type:Class = null, $qualified:Boolean = false):*
		{
			var convert:Function = ConvertUtil["to" + ClassUtil.getClassName($type, $qualified)] || ConvertUtil.toString;
			return disc[$name] || (disc[$name] = convert(data[$name]));
		}
		
		
		/**
		 * 
		 * 设置属性。
		 * 
		 * @param $name:String 属性名称。
		 * @param $value:* 属性值。
		 * 
		 */
		
		protected function setProperty($name:String, $value:*):void
		{
			data[$name] = $value;
			delete disc[$name];
		}
		
		
		/**
		 * 
		 * 根据id获取相关数据结构。
		 * 
		 * @param $type:Class 数据类型。
		 * @param $id:String
		 * 
		 * @return * 数据结构。
		 * 
		 */
		
		protected function getRelation($type:Class, $id:String = null):*
		{
			var name:String = stor.retrieveName($type);
			if (!(rela[name] && rela[name][$id]))
			{
				rela[name] = rela[name] || {};
				rela[name][$id] = rela[name][$id] || stor.retrieveData($id, $type);
			}
			return rela[name][$id];
		}
		
		
		/**
		 * 
		 * 清除关联数据结构。
		 * 
		 */
		
		protected function clsRelation($type:Class):void
		{
			delete rela[stor.retrieveName($type)];
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
			if (Cache.exist(cache.saveURL)) 
			{
				delete cach[cache.saveURL];
				if (ready) dispatchEvent(new ControlEvent(ControlEvent.READY));
			}
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
		 * id
		 * 
		 */
		
		public function get id():String
		{
			return getProperty("id");
		}
		
		/**
		 * @private
		 */
		public function set id($id:String):void
		{
			setProperty("id", $id);
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
		 * 父级VO实例。
		 * 
		 */
		
		public function get parent():VO
		{
			return wt::parent;
		}
		
		/**
		 * @private
		 */
		public function set parent($value:VO):void
		{
			wt::parent = $value;
		}
		
		
		/**
		 * 
		 * 原始数据。
		 * 
		 */
		
		public function get raw():*
		{
			return wt::raw;
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
		 * 
		 * 存储原始数据。
		 * 
		 */
		
		protected var data:Object;
		
		
		/**
		 * 
		 * 存储转换后的数据。
		 * 
		 */
		
		protected var disc:Object;
		
		
		/**
		 * 
		 * 名称
		 * 
		 */
		
		protected var name:String = "vo";
		
		
		/**
		 * 存储关联数据结构。
		 * @private
		 */
		private var rela:Object;
		
		/**
		 * @private
		 */
		private var stor:Store;
		
		/**
		 * @private
		 */
		private var cach:Map;
		
		
		/**
		 * @private
		 */
		wt var parent:VO;
		
		/**
		 * @private
		 */
		wt var raw:*;
		
	}
}