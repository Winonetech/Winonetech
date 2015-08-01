package com.winonetech.tools
{
	
	/**
	 * 
	 * 缓存管理器。
	 * 
	 */
	import cn.vision.consts.Consts;
	import cn.vision.consts.ProtocolConsts;
	import cn.vision.collections.Map;
	import cn.vision.net.*;
	import cn.vision.pattern.core.Command;
	import cn.vision.pattern.queue.ParallelQueue;
	import cn.vision.system.VSFile;
	import cn.vision.utils.ByteArrayUtil;
	import cn.vision.utils.FileUtil;
	import cn.vision.utils.StringUtil;
	
	import com.winonetech.consts.PathConsts;
	import com.winonetech.utils.CacheUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;
	
	
	/**
	 * 
	 * 进度改变时触发。
	 * 
	 */
	
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	
	public class Cache extends Command
	{
		
		/**
		 * 
		 * <code>Cache</code>构造函数。
		 * 
		 * @param $loadURL:String 加载路径。
		 * @param $saveURL:String 相对存储路径。
		 * 
		 */
		
		public function Cache($loadURL:String = null, $saveURL:String = null)
		{
			super();
			
			initialize($loadURL, $saveURL);
		}
		
		
		/**
		 * 
		 * 停止当前下载的进程。
		 * 
		 */
		
		override public function close():void
		{
			executing && handlerDefault();
		}
		
		
		/**
		 * 
		 * 执行命令加载文件至本地。
		 * 
		 */
		
		override public function execute():void
		{
			commandStart();
			
			cache();
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function commandEnd():void
		{
			super.commandEnd();
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function commandStart():void
		{
			super.commandStart();
		}
		
		
		/**
		 * @private
		 */
		private function cache():void
		{
			if(!exist)
			{
				var protocol:String = String(loadURL.split("://")[0]).toLowerCase();
				var b:Boolean = protocol == ProtocolConsts.HTTP;
				var l:String = b ? loadURL : CacheUtil.extractURI(loadURL);
				var s:String = FileUtil.resolvePathApplication(saveURL);
				if (b)
				{
					var request:Object = new HTTPRequest(l, s);
				}
				else
				{
					if (DFTP[Consts.INIT])
					{
						var h:String = DFTP.host;
						var u:String = DFTP.user;
						var w:String = DFTP.pass;
						var p:uint   = DFTP.port || 21;
					}
					else
					{
						var t1:Array = loadURL.split("/");
						if (t1[2]) var t2:Array = t1[2].split("@");
						if (t1[2] && t2.length == 2)
						{
							//分解如ftp:FTPMedia@192.168.1.21:21的字符串。
							var t3:Array = t2[0].split(":");
							var t4:Array = t2[1].split(":");
							h = t4[0];
							u = t3[0];
							w = t3[1];
							p = t4[1] || 21;
						}
					}
					request = new FTPRequest(h, u, w, p, l, s);
				}
				
				loader = new (b ? HTTPLoader : FTPLoader);
				loader.addEventListener(Event.COMPLETE, handlerDefault);
				loader.addEventListener(IOErrorEvent.IO_ERROR, handlerDefault);
				loader.addEventListener(ProgressEvent.PROGRESS, handlerProgress);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handlerDefault);
				loader.load(request);
			}
			else
			{
				commandEnd();
			}
		}
		
		/**
		 * @private
		 */
		private function initialize($loadURL:String, $saveURL:String):void
		{
			loadURL = $loadURL;
			saveURL = $saveURL;
		}
		
		
		/**
		 * 
		 * 缓存文件至本地。
		 * 
		 * @param $url:String 加载地址。
		 * 
		 * @return Cache Cache实例。
		 * 
		 */
		
		public static function cache($url:String):Cache
		{
			if(!StringUtil.isEmpty($url))
			{
				var loadURL:String = $url;
				var saveURL:String = CacheUtil.extractURI($url, PathConsts.PATH_FILE);
				if(!CACH[saveURL])
				{
					CACH[saveURL] = new Cache(loadURL, saveURL);
					queue.execute(CACH[saveURL]);
				}
			}
			return CACH[saveURL];
		}
		
		
		/**
		 * 
		 * 检测本地缓存文件是否存在，如果传递的url为空，则默认返回true。
		 * 
		 * @param $url:String 文件相对路径。
		 * 
		 * @return Boolean true为存在，false为不存在。
		 * 
		 */
		
		public static function exist($url:String):Boolean
		{
			if(!StringUtil.isEmpty($url))
				var file:VSFile = new VSFile(FileUtil.resolvePathApplication($url));
			return file ? file.exists : true;
		}
		
		
		/**
		 * 
		 * 获取缓存路径对应的Cache。
		 * 
		 * @param $url:String 文件相对路径。
		 * 
		 * @return Cache 对应的缓存。
		 * 
		 */
		
		public static function gain($url:String):Cache
		{
			return CACH[$url];
		}
		
		
		/**
		 * 
		 * 将Cache顺序提升至队列前下载。
		 * 
		 * @param $cache:Cache 需要提前的Cache实例。
		 * 
		 */
		
		public static function shift($cache:Cache):void
		{
			if ($cache && CACH[$cache.saveURL] == $cache)
				if(!$cache.executing) queue.shift($cache);
		}
		
		
		/**
		 * 
		 * 存储文件。
		 * 
		 * @param $url:String 相对存储路径。
		 * @param $data:* 需要存储的数据。
		 * 
		 */
		
		public static function save($url:String, $data:*):FileSaver
		{
			var bytes:ByteArray = ByteArrayUtil.convertByteArray($data);
			if (bytes)
			{
				SAVE[$url] = true;
				$url = FileUtil.resolvePathApplication($url);
				var saver:FileSaver = new FileSaver;
				var request:FileRequest = new FileRequest($url, bytes);
				var count:uint = 0;
				var handler:Function = function($e:Event):void
				{
					if ($e.type == Event.COMPLETE)
					{
						saver.removeEventListener(Event.COMPLETE, handler);
						saver.removeEventListener(IOErrorEvent.IO_ERROR, handler);
						saver.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handler);
					}
					else
					{
						if (count++ < 3)
							saver.save(request);
						/*else
							LogSaver.log(TypeConsts.FILE, EventConsts.SAVE_ERROR, RegexpUtil.replaceTag(VSTipConsts.FILE_SAVE_ERROR, saver), null, LogSaver.getTime());*/
					}
				};
				saver.addEventListener(Event.COMPLETE, handler);
				saver.addEventListener(IOErrorEvent.IO_ERROR, handler);
				saver.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handler);
				saver.save(request);
				
			}
			return saver;
		}
		
		
		/**
		 * 
		 * 检测文件是否在APP使用到。
		 * 
		 * @param $url:String 文件相对路径。
		 * 
		 * @return Boolean 
		 * 
		 */
		
		public static function used($url:String, $save:Boolean = false):Boolean
		{
			if ($save) SAVE[$url] = true;
			return SAVE[$url] || CACH[$url];
		}
		
		
		/**
		 * 
		 * 定义FTP服务端设置，如果加载的地址是FTP协议，则优先使用该方法初始化后的FTP信息。
		 * 
		 * @param $host:String FTP地址。
		 * @param $port:uint FTP端口。
		 * @param $username:String 用户名。
		 * @param $password:String 密码。
		 * 
		 */
		
		public static function deftp($host:String, $port:uint, $username:String, $password:String):void
		{
			DFTP[Consts.INIT] = true;
			DFTP.host = $host;
			DFTP.port = $port;
			DFTP.user = $username;
			DFTP.pass = $password;
		}
		
		
		/**
		 * @private
		 */
		private function handlerDefault($e:Event = null):void
		{
			/*if ($e)
			{
				if ($e.type == IOErrorEvent.IO_ERROR)
					
					LogSaver.log(TypeConsts.FILE,EventConsts.CACHE_UNEXIST,RegexpUtil.replaceTag(TipConsts.NOTICE_CACHE_UNEXIST, this),null,LogSaver.getTime());
			}*/
			if (loader)
			{
				loader.removeEventListener(Event.COMPLETE, handlerDefault);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, handlerDefault);
				loader.removeEventListener(ProgressEvent.PROGRESS, handlerProgress);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handlerDefault);
				loader.close();
				loader = null;
			}
			commandEnd();
		}
		
		/**
		 * @private
		 */
		private function handlerProgress($e:ProgressEvent):void
		{
			dispatchEvent($e.clone());
		}
		
		
		/**
		 * 
		 * 缓存完毕，文件是否存在。
		 * 
		 */
		
		public function get exist():Boolean
		{
			return Cache.exist(saveURL);
		}
		
		
		/**
		 * 
		 * 下载速度，KB/S。
		 * 
		 */
		
		public function get speed():Number
		{
			return loader ? loader.speed : 0;
		}
		
		
		/**
		 * 
		 * 下载百分比。
		 * 
		 */
		
		public function get percent():Number
		{
			return loader ? loader.bytesLoaded / loader.bytesTotal : 0;
		}
		
		
		/**
		 * 
		 * 是否有文件在加载。
		 * 
		 */
		
		public static function get caching():Boolean
		{
			return queue.executing;
		}
		
		
		/**
		 * 
		 * 加载队列的引用。
		 * 
		 */
		
		public static function get queue():ParallelQueue
		{
			return parallel || (parallel = new ParallelQueue);
		}
		
		
		/**
		 * 
		 * 返回正在当前正在下载的缓存集合。
		 * 
		 */
		
		public static function get executingCaches():Map
		{
			return parallel.executingCommands;
		}
		
		
		/**
		 * 
		 * 缓存字典引用。
		 * 
		 */
		
		public static function get caches():Map
		{
			return CACH;
		}
		
		
		/**
		 * 
		 * 加载路径。
		 * 
		 */
		
		public var loadURL:String;
		
		
		/**
		 * 
		 * 存储路径。
		 * 
		 */
		
		public var saveURL:String;
		
		
		/**
		 * @private
		 */
		private var loader:Object;
		
		
		/**
		 * @private
		 */
		private static var parallel:ParallelQueue;
		
		
		/**
		 * @private
		 */
		private static const DFTP:Object = {};
		
		/**
		 * @private
		 */
		private static const SAVE:Object = {};
		
		/**
		 * @private
		 */
		private static const CACH:Map = new Map;
		
	}
}