package com.winonetech.core
{
	
	/**
	 * 
	 * 数据结构基类。
	 * 
	 */
	
	
	import cn.vision.collections.Map;
	import cn.vision.core.VSEventDispatcher;
	import cn.vision.events.pattern.CommandEvent;
	import cn.vision.utils.ArrayUtil;
	import cn.vision.utils.ObjectUtil;
	import cn.vision.utils.StringUtil;
	import cn.vision.utils.TimerUtil;
	import cn.vision.utils.XMLUtil;
	
	import com.winonetech.events.ControlEvent;
	import com.winonetech.tools.Cache;
	
	
	/**
	 * 
	 * VO初始化完毕时触发。
	 * 
	 */
	
	[Event(name="init", type="com.winonetech.events.ControlEvent")]
	
	
	/**
	 * 
	 * 与该VO相关的文件下载完毕时触发。
	 * 
	 */
	
	[Event(name="ready", type="com.winonetech.events.ControlEvent")]
	
	
	/**
	 * 
	 * 与该VO相关的处理完成一定的进度时触发。
	 * 
	 */
	
	[Event(name="progress", type="com.winonetech.events.ControlEvent")]
	
	
	/**
	 * 
	 * 与该VO相关的处理完成一定的进度时触发。
	 * 
	 */
	
	[Event(name="download", type="com.winonetech.events.ControlEvent")]
	
	
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
		
		public function VO($data:Object = null, $name:String = "vo", $useWait:Boolean = true, $cacheGroup:String = null)
		{
			super();
			
			initialize($data, $name, $useWait, $cacheGroup);
		}
		
		
		/**
		 * 
		 * 解析转换数据。
		 * 将所有的数据均转化为Object类型。
		 * 
		 */
		public function parse($data:Object):void
		{
			//将数据保存至data和 raw
			wt::internalParse($data);
			
			TimerUtil.callLater(1, dispatchInit);
			TimerUtil.callLater(2, dispatchReady);
		}
		
		
		/**
		 * @private
		 */
		wt function internalParse($data:Object):void
		{
			if ($data)
			{
				wt::raw = $data;
				if ($data is String)
				{
					var src:String = StringUtil.trim(String($data));
					data = XMLUtil.validate(src)
						?  ObjectUtil.convert(XML(src), Object)
						:  JSON.parse(src);
				}
				else if ($data is XML)
				{
					data = ObjectUtil.convert($data, Object);
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
		 * 更新数据
		 * 
		 */
		
		public function update(...$args):void { }
		
		
		/**
		 * 
		 * XML格式缓存数据。
		 * 
		 */
		
		public function toXML():String
		{
			return ObjectUtil.convert(data, XML, name);
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
		private function initialize($data:Object, $name:String, $useWait:Boolean, $cacheGroup:String):void
		{
			name = $name;   //用作 XML的根节点。
			stor = Store.instance;
			useWait = $useWait;
			cacheGroup = $cacheGroup;
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
		 * @param ...$args 其他转换所需要的参数。
		 * 
		 * @return * 属性值。
		 * 
		 */
		
		protected function getProperty($name:String, $type:Class = null, ...$args):*
		{
			ArrayUtil.unshift($args, data[$name], $type);
			return disc[$name] || (disc[$name] = ObjectUtil.convert.apply(null, $args));
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
		 * 发送初始化完毕。
		 * 
		 */
		
		protected function dispatchInit():void
		{
			if(!inited) 
			{
				inited = true;
				dispatchEvent(new ControlEvent(ControlEvent.INIT));
			}
		}
		
		
		/**
		 * 
		 * 发送准备完毕。
		 * 
		 */
		
		protected function dispatchReady():void
		{
			if (ready) dispatchEvent(new ControlEvent(ControlEvent.READY));
		}
		
		
		
//		protected function destroy():void {}
		
		
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
				var cache:Cache = (item is String) ? Cache.cache(item, !useWait, cacheGroup) : item;
				if (!useWait && cache && ! cach[cache.saveURL] && !cache.exist)
				{
					var handler:Function = function($e:CommandEvent):void
					{
						var cache:Cache = Cache($e.command);
						cache.removeEventListener(CommandEvent.COMMAND_END, handler);
							
						delete cach[cache.saveURL];
						
						dispatchReady();
					};
					cache.addEventListener(CommandEvent.COMMAND_END, handler);
					cach[cache.saveURL] = cache;
				}
			}
			
			if (cach.length) dispatchEvent(new ControlEvent(ControlEvent.DOWNLOAD));  //当有需要下载的文件时，发送下载命令。
		}
		
		
		/**
		 * 
		 * 添加一个子VO。
		 * 
		 * @param $child:VO 子VO。
		 * 
		 */
		
		wt function addChild($child:VO):void
		{
			if(!children) wt::children = new Vector.<VO>;
			if (children.indexOf($child) == -1)
			{
				ArrayUtil.push(children, $child);
			}
		}
		
		
		/**
		 * 
		 * 删除一个子VO。
		 * 
		 * @param $child:VO 子VO。
		 * 
		 */
		
		wt function delChild($child:VO):void
		{
			if(!children) wt::children = new Vector.<VO>;
			var index:int = children.indexOf($child);
			if (index != -1) children.splice(index, 1);
		}
		
		
		/**
		 * 
		 * 子组件数组。
		 * 
		 */
		
		public function get children():Vector.<VO>
		{
			return wt::children;
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
			if (parent) parent.wt::delChild(this);
			wt::parent = $value;
			if (parent) parent.wt::addChild(this);
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
			var result:Boolean = true;
			//如果没有子项，则直接设计为已准备阶段。
			if (children)     
			{
				for each (var child:VO in children)
				{
					if(!child.ready)
					{
						result = false;
						break;
					}
				}
			}
			//return true;
			return result && (!cach.length);
		}
		
		
		/**
		 * 
		 * 存储提示信息。
		 * 
		 */
		
		public var tip:Object;
		
		
		/**
		 * 
		 * 是否使用等待队列。
		 * 
		 */
		
		public var useWait:Boolean;
		
		
		/**
		 * 
		 * 解析文件时存储的组。
		 * 
		 */
		
		public var cacheGroup:String;
		
		
		/**
		 * 
		 * 存储转换前的数据。
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
		 * (需要下载的)文件缓存字典。
		 * cach[saveURL] -> cache
		 * 
		 * 
		 */
		
		protected var cach:Map;
		
		
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
		private var inited:Boolean;
		
		
		/**
		 * @private
		 */
		wt var children:Vector.<VO>;
		
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