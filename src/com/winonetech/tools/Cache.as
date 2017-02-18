package com.winonetech.tools
{
	
	/**
	 * 
	 * 缓存管理器。
	 * 
	 */
	
	
	import cn.vision.collections.Map;
	import cn.vision.consts.CommandPriorityConsts;
	import cn.vision.consts.Consts;
	import cn.vision.consts.ProtocolConsts;
	import cn.vision.events.pattern.QueueEvent;
	import cn.vision.net.*;
	import cn.vision.pattern.core.Command;
	import cn.vision.pattern.queue.ParallelQueue;
	import cn.vision.system.VSFile;
	import cn.vision.utils.ByteArrayUtil;
	import cn.vision.utils.FileUtil;
	import cn.vision.utils.LogUtil;
	import cn.vision.utils.StringUtil;
	import cn.vision.utils.TimerUtil;
	
	import com.winonetech.consts.PathConsts;
	import com.winonetech.core.wt;
	import com.winonetech.utils.CacheUtil;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	
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
		 * 缓存文件至本地。
		 * 
		 * @param $url:String 加载地址。
		 * @param $useSP:Boolean 是否加入到特殊队列。
		 * @param $group:String (default = null)一个标记，用于标记在一个组中，从队列中清空Cache时，可以按组清除。
		 * 
		 * @return Cache Cache实例。
		 * 
		 */
		
		public static function cache($url:String, $useSP:Boolean = false, $group:String = null, $start:Boolean = false, $isEpaper:Boolean = false):Cache
		{
			if(!StringUtil.isEmpty($url))
			{
				var loadURL:String = $url;
				var saveURL:String = CacheUtil.extractURI($url, PathConsts.PATH_FILE);
				
				var cache:Cache = retrieveCache(loadURL, saveURL, $group, $isEpaper);
				//cahe文件不存在，cache没有执行，cache不在队列中
				
				if(!cache.exist) //cahe文件不存在才加入下载队列。
				{
					if (!$useSP) //如果使用等待队列。
					{
						//如果在非等待队列中，要把它从非等待队列中移除。
						queue_sp.remove(cache);
						
						//如果不在等待队列中，加入等待队列。
						if(!queue.exist(cache))
						{
							queue[$start ? "execute" : "push"](cache);
							queueTotal ++;
						}
					}
					else
					{
						queue_sp[$start ? "execute" : "push"](cache);
					}
				}
			}
			return cache;
		}
		
		
		/**
		 * 
		 * 清空所有当前正在下载的文件。
		 * 
		 * @group:String (default = null) 参数$group代表清除某个组的cache。
		 * 
		 */
		
		public static function clear($group:String = null):void
		{
			if ($group)
			{
				var group:Object = GROUPS[$group];
				for each (var item:Cache in group)
				{
					var flag:int = GROUPS["COUNT"][item.saveURL];
					flag --;
					if (flag <= 0)
					{
						delete GROUPS["COUNT"][item.saveURL];
						remove(item);
					}
					else
					{
						trace("文件不止在一个地方使用。");
					}
				}
				delete GROUPS[$group];
			}
			else
			{
				queue.clear();
				queue_sp.clear();
			}
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
		 * 执行下载队列。
		 * 
		 */
		
		public static function start():void
		{
			if (queue.executing)
			{
				LogUtil.log("等待队列正在下载的文件个数：", queue.executingCommands.length);
				for each (var item:Cache in queue.executingCommands)
				{
					LogUtil.log("文件：" + item.saveURL + "，speed：" + item.speed + "，percent：" + item.percent);
				}
			}
			
			if (queue.lave > 0) queue.execute();
			
			if (queue_sp.executing)
			{
				LogUtil.log("特殊队列正在下载的文件个数：", queue.executingCommands.length);
				for each (item in queue.executingCommands)
				{
					LogUtil.log("文件：" + item.saveURL + "，speed：" + item.speed + "，percent：" + item.percent);
				}
			}
			
			if (queue_sp.lave > 0) queue_sp.execute();
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
		 * 
		 * <code>Cache</code>构造函数。
		 * 
		 * @param $loadURL:String 加载路径。
		 * @param $saveURL:String 相对存储路径。
		 * 
		 */
		
		public function Cache($loadURL:String = null, $saveURL:String = null, $isEpaper:Boolean = false)
		{
			super();
			
			initialize($loadURL, $saveURL, $isEpaper);
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
			if (!executing)
			{
				commandStart();
				
				cache();
			}
		}
		
		
		/**
		 * @private
		 */
		private function cache():void
		{
			if(!exist)
			{
				var protocol:String = String(loadURL.split("://")[0]).toLowerCase();    //确定协议 （ FTP || HTTP）。
				var b:Boolean = protocol == ProtocolConsts.HTTP;     //是否是HTTP协议。
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
							//分解如 ftp:FTPMedia@192.168.1.21:21的字符串。
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
				loader.timeout = timeout;
				loader.addEventListener(Event.COMPLETE, handlerDefault);
				loader.addEventListener(IOErrorEvent.IO_ERROR, handlerDefault);
				loader.addEventListener(ProgressEvent.PROGRESS, handlerProgress);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handlerDefault);
				loader.load(request);
			}
			else
			{
				TimerUtil.callLater(1, commandEnd);
			}
		}
		
		/**
		 * @private
		 */
		private function initialize($loadURL:String, $saveURL:String, $isEpaper:Boolean = false):void
		{
			loadURL  = $loadURL;
			saveURL  = $saveURL;
			isEpaper = $isEpaper;
		}
		
		
		/**
		 * 
		 * 移除某个Cache。
		 * 
		 * @param $cache:Cache 要移除的Cache实例。
		 * 
		 * @return Cache 对应的缓存。
		 * 
		 */
		
		private static function remove($cache:Cache):void
		{
			if(!queue.remove($cache)) queue_sp.remove($cache);
		}
		
		/**
		 * @private
		 */
		private static function removeGroupRecords($cache:Cache):void
		{
			for each (var group:Object in GROUPS) delete group[$cache.saveURL];
			delete GROUPS["COUNT"][$cache.saveURL];
		}
		
		/**
		 * @private
		 */
		private static function retrieveCache($loadURL:String, $saveURL:String, $group:String, $isEpaper:Boolean = false):Cache
		{
			var cache:Cache = (CACH[$saveURL] = CACH[$saveURL] || new Cache($loadURL, $saveURL, $isEpaper));
			if ($group)
			{
				var group:Object = GROUPS[$group] = GROUPS[$group] || {};
				if (!group[cache.saveURL])
				{
					group[cache.saveURL] = cache;
					var flag:int = GROUPS["COUNT"][cache.saveURL];
					flag++;
					GROUPS["COUNT"][cache.saveURL] = flag;
				}
			}
			return cache;
		}
		
		/**
		 * @private
		 */
		private static function checkFileUnloadable($url:String):Boolean
		{
			var cacheObj:Object = getFileCache();
			return cacheObj && cacheObj[$url];
		}
		
		/**
		 * @private
		 */
		private static function flagFileUnloadable($url:String):void
		{
			var cacheObj:Object = getFileCache() || {};
			cacheObj[$url] = true;
			setFileCache(cacheObj);
		}
		
		/**
		 * @private
		 */
		private static function getFileCache():Object
		{
			cacheListFile = cacheListFile || new VSFile(FileUtil.resolvePathApplication(PathConsts.PATH_FILE_LIST_CACHE));
			if (cacheListFile.exists)
			{
				cacheListStream.open(cacheListFile, FileMode.READ);
				var temp:String = cacheListStream.readUTFBytes(cacheListStream.bytesAvailable);
				cacheListStream.close();
			}
			try
			{
				if (temp) var result:Object = JSON.parse(temp);
			} catch(e:Error){}
			return result;
		}
		
		/**
		 * @private
		 */
		private static function setFileCache($value:Object):void
		{
			try
			{
				var temp:String = JSON.stringify($value, null, '\t');
			} catch(e:Error) {}
			if (temp)
			{
				cacheListStream.open(cacheListFile, FileMode.WRITE);
				cacheListStream.writeUTFBytes(temp);
				cacheListStream.close();
			}
		}
		
		
		/**
		 * @private
		 */
		private function handlerDefault($e:Event = null):void
		{
			if (loader)
			{
				loader.removeEventListener(Event.COMPLETE, handlerDefault);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, handlerDefault);
				loader.removeEventListener(ProgressEvent.PROGRESS, handlerProgress);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handlerDefault);
				if (loader is FTPLoader) 
				{
					code = loader.code;
				}
				loader = null;
			}
			
			if ($e)
			{
				switch ($e.type)
				{
					case Event.COMPLETE:
						wt::succeed = true;
						break;
					case IOErrorEvent.IO_ERROR:
					case SecurityErrorEvent.SECURITY_ERROR:
						wt::message = Object($e).text;
						break;
				}
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
		 * @private
		 */
		private static function parallelStepEnd($e:QueueEvent):void
		{
			var cache:Cache = $e.command as Cache;
			if(!cache.exist)
			{
				if (cache.reloadCount++ < 2)
				{
					if (cache.code == "550")
					{
						LogUtil.log("下载失败：" + cache.code + "，" + cache.saveURL + "，" + cache.message);
						cache.reloadCount = 0;
						unexist++;
						//标记该文件下载失败，原因是服务端没有这个文件。
//						flagFileUnloadable(cache.loadURL);
						
					}
					else
					{
						LogUtil.log("下载失败：" + cache.code + "，" + cache.saveURL + "，稍后再次下载，" + cache.message);
						cache.priority = CommandPriorityConsts.NORMAL;
						queue.execute(cache);
					}
				}
				else
				{
					LogUtil.log("下载失败：" + cache.code + "，" + cache.saveURL + "，网络较慢，FTP服务器无响应。");
					failure++;
					FAIL[cache.saveURL] = cache;
					//标记下载失败，可能原因是服务端阻塞。
//					flagFileUnloadable(cache.loadURL);
				}
			}
			else
			{
				if (cache.succeed)
				{
					success++;
					removeGroupRecords(cache);
					LogUtil.log("下载成功" + cache.saveURL + "总数：" + queueTotal + "剩余：" + (queue.lave + queue.num));
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private static function parallel_spStepEnd($e:QueueEvent):void
		{
			var cache:Cache = $e.command as Cache;
			if(!cache.exist)
			{
				if (cache.reloadCount++ < 2)
				{
					if (cache.code == "550")
					{
						LogUtil.log("特殊文件下载失败：" + cache.code + "，" + cache.saveURL + "，" + cache.message);
						cache.reloadCount = 0;
					}
					else
					{
						LogUtil.log("特殊文件下载失败：" + cache.code + "，" + cache.saveURL + "，稍后再次下载，" + cache.message);
						cache.priority = CommandPriorityConsts.NORMAL;
						queue_sp.execute(cache);
					}
				}
				else
				{
					result = false;
					FAIL[cache.saveURL] = cache;
					LogUtil.log("特殊文件下载失败：" + cache.code + "，" + cache.saveURL + "，网络较慢，FTP服务器无响应。");
				}
			}
			else
			{
				if (cache.succeed)
				{
					result = true;
					removeGroupRecords(cache);
					LogUtil.log("特殊文件下载成功");
				}
			}
		}
		
		
		
		/**
		 * @private
		 */
		private static function parallelStepStart($e:QueueEvent):void
		{
			var cache:Cache = $e.command as Cache;
			LogUtil.log((cache.reloadCount == 0 ? "开始下载" : "再次下载"), cache.saveURL);
		}

		
		/**
		 * @private
		 */
		private static function parallel_spStepStart($e:QueueEvent):void
		{
			var cache:Cache = $e.command as Cache;
			LogUtil.log((cache.reloadCount == 0 ? "特殊队列开始下载" : "特殊队列再次下载"), cache.saveURL);
		}
		
		/**
		 * @private
		 */
		private static function parallel_spQueueEnd($e:QueueEvent):void
		{
			LogUtil.log("特殊队列下载结束");
			LogUtil.log(result ? "特殊队列下载成功" : "特殊队列下载失败");
			
			queueUseCount--;
			
			reloadLater();
		}
		
		
		/**
		 * @private
		 */
		private static function parallelQueueEnd($e:QueueEvent):void
		{
			LogUtil.log("等待队列下载结束");
			LogUtil.log("文件总数：" + queueTotal);
			LogUtil.log("成功：" + success);
			LogUtil.log("失败：" + failure);
			LogUtil.log("不存在：" + unexist);
			
			success = 0;
			failure = 0;
			unexist = 0;
			queueUseCount--;
			
			reloadLater();
		}
		
		/**
		 * @private
		 */
		private static function parallelQueueStart($e:QueueEvent):void
		{
			LogUtil.log("文件队列下载开始");
			queueUseCount++;
		}
		
		
		/**
		 * @private
		 */
		private static function parallel_spQueueStart($e:QueueEvent):void
		{
			LogUtil.log("特殊队列下载开始");
			queueUseCount++;
		}
		
		/**
		 * @private
		 */
		private static function reloadLater():void
		{
			if (queueUseCount == 0 && FAIL.length) 
			{
				var timer:Timer = new Timer(60000, RELOADTIME);
				var handler:Function = function(e:TimerEvent):void
				{
					timer.removeEventListener(TimerEvent.TIMER_COMPLETE, handler);
					timer.stop();
					timer = null;
					
					reloadFailures();
				};
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, handler);
				timer.start();
			}
		}
		
		/**
		 * @private
		 */
		private static function reloadFailures():void
		{
			for each (var item:Cache in FAIL) queue_sp.execute(item);
			
			queue_sp.execute();
		}

		
		
		/**
		 * @private
		 */
//		private static function reloadSP():void
//		{
//			for each (var item:Cache in FAIL_SP) queue_sp.execute(item);
//			
//			queue_sp.execute();
//		}
		
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
		 * 消息。
		 * 
		 */
		
		public function get message():String
		{
			return wt::message;
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
		 * 是否下载成功。
		 * 
		 */
		
		public function get succeed():Boolean
		{
			return wt::succeed as Boolean;
		}
		
		
		/**
		 * 
		 * 额外的信息。
		 * 
		 */
		
		public var extra:Object;
		
		
		/**
		 * 
		 * 下载百分比。
		 * 
		 */
		
		public function get percent():Number
		{
			var result:Number = 0;
			if (loader)
			{
				result = loader.bytesLoaded / loader.bytesTotal;
				if (isNaN(result)) result = 0;
			}
			return result;
		}
		
		
		/**
		 * 
		 * 是否等待队列中有文件在加载。
		 * 
		 */
		
		public static function get caching():Boolean
		{
			return queue.executing;
		}
		
		
		public static function get cachesLave():uint
		{
			return parallel.lave;
		}
		
		
		public static function get hasSP():Boolean
		{
			return queue_sp.lave > 0;
		}
		
		/**
		 * 
		 * 加载队列的引用。
		 * 
		 */
		
		public static function get queue():ParallelQueue
		{
			if(!parallel)
			{
				parallel = new ParallelQueue;
				parallel.addEventListener(QueueEvent.STEP_START, parallelStepStart);
				parallel.addEventListener(QueueEvent.STEP_END, parallelStepEnd, false, uint.MAX_VALUE);
				parallel.addEventListener(QueueEvent.QUEUE_START, parallelQueueStart);
				parallel.addEventListener(QueueEvent.QUEUE_END, parallelQueueEnd);
				parallel.limit = 2;
			}
			return parallel;
		}
		
		
		public static function get queue_sp():ParallelQueue
		{
			if (!parallel_sp)
			{
				parallel_sp = new ParallelQueue;
				parallel_sp.addEventListener(QueueEvent.STEP_START, parallel_spStepStart);
				parallel_sp.addEventListener(QueueEvent.STEP_END, parallel_spStepEnd, false, uint.MAX_VALUE);
				parallel_sp.addEventListener(QueueEvent.QUEUE_START, parallel_spQueueStart);
				parallel_sp.addEventListener(QueueEvent.QUEUE_END, parallel_spQueueEnd);
				parallel_sp.limit = 2;
			}
			return parallel_sp;
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
		 * 获取队列剩余下载的个数。
		 * 
		 */
		
		public static function get waitLave():uint
		{
			return queue.lave;
		}
		
		
		/**
		 * 
		 * 是否有文件需要下载。
		 * 
		 */
		
		public static function get unwaitLave():uint
		{
			return queue_sp.lave;
		}
		
		
		/**
		 * 
		 * 是否有文件需要下载。
		 * 
		 */
		
		public static function get hasDownload():Boolean
		{
			return unwaitLave > 0 || waitLave > 0;
		}
		
		
		
		public static var allowed:Boolean;
		
		
		/**
		 * 
		 * 一个计数，失败后重复加载的次数。
		 * 
		 */
		
		public var reloadCount:uint = 0;
		
		
		/**
		 * 
		 * 加载路径。
		 * 
		 */
		
		public var loadURL:String;
		
		
		/**
		 * 
		 * 一个提示编码，此编码通常由服务端返回。
		 * 
		 */
		
		public var code:String;
		
		
		/**
		 * 
		 * 存储路径。
		 * 
		 */
		
		public var saveURL:String;
		
		
		public var isEpaper:Boolean;
		
		/**
		 * @private
		 */
		private var loader:Object;
		
		
		/**
		 * @private
		 */
		wt var succeed:Boolean;
		
		/**
		 * @private
		 */
		wt var message:String;
		
		
		/**
		 * 
		 * 超时时间。
		 * 
		 */
		
		public static var timeout:uint = 10;
		
		
		/**
		 * 
		 * 是否允许执行下载。<br>
		 * 当需要下载的时候，在调用处之前改其为true。
		 * 
		 */
		
		//public static var allowed:Boolean;
		
		
		/**
		 * @private
		 */
		private static var parallel:ParallelQueue;
		
		
		/**
		 * @private
		 */
		private static var parallel_sp:ParallelQueue;
		
		
		/**
		 * @private
		 */
		private static var queueTotal:uint = 0;
		
		/**
		 * @private
		 */
		private static var success:uint = 0;
		
		
		/**
		 * @private
		 */
		private static var failure:uint = 0;
		
		/**
		 * @private
		 */
		private static var unexist:uint = 0;
		
		/**
		 * @private
		 */
		private static var result:Boolean = true;
		
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
		
		/**
		 * @private
		 */
		private static const GROUPS:Object = {COUNT:{}};
		
		/**
		 * @private
		 */
		private static const FAIL:Map = new Map;
		
		/**
		 * @private
		 */
		private static var queueUseCount:uint;
//		private static const FAIL_SP:Map = new Map;
		
		/**
		 * @private
		 */
		private static var cacheListFile:VSFile;
		
		/**
		 * @private
		 */
		private static var cacheListStream:FileStream = new FileStream;
		
		/**
		 * 重新下载等待时间。(分钟)
		 * @private
		 */
		private static const RELOADTIME:uint = 60; 
		
	}
}