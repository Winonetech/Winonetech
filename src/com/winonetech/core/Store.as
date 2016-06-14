package com.winonetech.core
{
	
	/**
	 * 
	 * 缓存数据。
	 * 
	 */
	
	
	import cn.vision.collections.Map;
	import cn.vision.core.VSObject;
	import cn.vision.errors.SingleTonError;
	import cn.vision.utils.ArrayUtil;
	import cn.vision.utils.ClassUtil;
	import cn.vision.utils.StringUtil;
	
	import flash.utils.Dictionary;
	
	
	public final class Store extends VSObject
	{
		
		/**
		 * 
		 * 构造函数。
		 * 
		 */
		
		public function Store()
		{
			if(!instance)
			{
				super();
				
				initialize();
			}
			else throw new SingleTonError(this);
		}
		
		
		/**
		 * 
		 * 清空数据缓存。
		 * 
		 * @param ...$args  一个或多个数据类型，必须为Class的实例，如为空，则清空所有。
		 * 
		 * @return 如果参数只有一个，返回该类型的字典集合，作用与retrieveType相同，并且清空该类型数据缓存。
		 * 
		 */
		
		public function clear(...$args):Map
		{
			if ($args && $args.length)
			{
				for each (var type:Class in $args)
				{
					var name:String = retrieveName(type);
					var result:Map = result || map[name];
					delete raw[name];
					delete map[name];
				}
			}
			else
			{
				raw = {}, map = {};
			}
			return result;
		}
		
		
		/**
		 * 
		 * 解析并注册成WO类型的数据。<br>
		 * 如果是列表行数据，则会对列表进行遍历，列表行数据包括Vector，Array，XMLList，Map；<br>
		 * 如果是XML或Object数据，会构建一个$type类型的WO数据；<br>
		 * 如果本身是一个WO，会直接存储。
		 * 
		 * @param $value:* 注册的数据。
		 * @param $type:Class (default = null) 数据类型，如果为空，则以$value实例的类型为准。
		 * @param $key:String 存储的键值属性名称
		 * 
		 */
		
		public function registData($value:*, $type:Class = null, $key:String = "id"):*
		{
			$type = $type || ClassUtil.getClass($value);
			if (ClassUtil.validateSubclass($type, WO))
			{
				var name:String = retrieveName($type);
				if (validateList($value))
				{
					for each (var item:* in $value) registData(item, $type);
				}
				else
				{
					registType($type);
					try
					{
						var data:WO = ($value is $type) ? $value : new $type($value);
					} catch(e:Error) {trace(e.getStackTrace())}
					if (data)
					{
						var key:String = StringUtil.isEmpty(data[$key]) 
							? String(data.vid) : data[$key];
						map[name][key] = map[name][key] || data;
					}
					var result:*  = map[name][key];
				}
			}
			return result;
		}
		
		
		/**
		 * 
		 * 注册从服务端加载的XML数据。
		 * 
		 * @param $value:* 注册的数据。
		 * @param $type:Class 数据类型。
		 * 
		 */
		
		public function registRaw($value:*, $type:Class):void
		{
			var name:String = retrieveName($type);
			if (raw[name])
			{
				if (raw[name] is Array)
				{
					raw[name][raw[name.length]] = $value;
				}
				else
				{
					var t:* = raw[name];
					raw[name] = [$value, t];
				}
			}
			else raw[name] = $value;
		}
		
		
		/**
		 * 
		 * 注册数据类型。
		 * 
		 * @param ...$args 一个或多个数据类型，必须为Class的实例。
		 * 
		 */
		
		public function registType(...$args):void
		{
			for each (var type:Class in $args)
			{
				var name:String = retrieveName(type);
				
				cla[name] = cla[name] || type;
				map[name] = map[name] || new Map;
			}
		}
		
		
		/**
		 * 
		 * 获取数据结构。
		 * 
		 * @param $id:String
		 * @param $type:Class 数据类型。
		 * 
		 * @return * 数据结构。
		 * 
		 */
		
		public function retrieveData($id:String, $type:Class):*
		{
			var type:String = retrieveName($type);
			return map[type] ? map[type][$id] : null;
		}
		
		
		/**
		 * 
		 * 获取数据结构字典。
		 * 
		 * @param $type:Class 数据类型。
		 * 
		 * @return * 数据结构字典。
		 * 
		 */
		
		public function retrieveMap($type:Class):Map
		{
			return map[retrieveName($type)];
		}
		
		/**
		 * 
		 * 获取类名。
		 * 
		 * @param $type:Class 数据类型。
		 * 
		 * @return String 名称。
		 * 
		 */
		
		public function retrieveName($type:Class):String
		{
			return ClassUtil.getClassName($type, false);
		}
		
		
		/**
		 * 
		 * 获取从服务端加载的数据。
		 * 
		 * @param $type:Class 数据类型。
		 * 
		 * @return * 返回相关数据。
		 * 
		 */
		
		public function retrieveRaw($type:Class):*
		{
			return raw[retrieveName($type)];
		}
		
		
		/**
		 * 初始化操作。
		 * @private
		 */
		private function initialize():void
		{
			raw = {}, map = {}, cla = {}, nam = new Dictionary;
		}
		
		/**
		 * 验证是否为列表行数据。
		 * @private
		 */
		private function validateList($value:*):Boolean
		{
			return ArrayUtil.validate($value) || 
					$value is XMLList || $value is Map;
		}
		
		
		/**
		 * 
		 * @private
		 * 
		 */
		
		private var raw:Object;
		
		/**
		 * @private
		 */
		private var cla:Object;
		
		/**
		 * @private
		 */
		private var map:Object;
		
		/**
		 * @private
		 */
		private var nam:Dictionary;
		
		
		/**
		 * 
		 * 单例引用。
		 * 
		 */
		
		public static const instance:Store = new Store;
		
	}
}