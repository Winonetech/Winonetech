package com.winonetech.tools
{
	
	/**
	 * 
	 * 日志存储。
	 * 
	 */
	
	
	import cn.vision.pattern.core.Command;
	import cn.vision.pattern.queue.SequenceQueue;
	import cn.vision.system.VSFile;
	import cn.vision.utils.FileUtil;
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.events.SQLEvent;
	
	
	public class LogSQLite extends Command
	{
		
		/**
		 * 
		 * 构造函数。
		 * 
		 */
		
		public function LogSQLite($args:Array)
		{
			super();
			
			args = $args;
		}
		
		/**
		 * 
		 * 记录一条日志。
		 * 
		 */
		
		public static function log(...$args):void
		{
			queue.execute(new LogSQLite($args));
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override public function execute():void
		{
			commandStart();
			
			trace.apply(null, args);
			debug(args);
		}
		
		/**
		 * @private
		 */
		private  function debug($data:*):void
		{
			var url:String = FileUtil.resolvePathApplication("log/sqlite");
			//如果文件夹不存在，先创建文件夹，否则调用SQL出错。
			var dir:VSFile = new VSFile(url);
			if(!dir.exists) dir.createDirectory();
			var date:Date = new Date;
			var name:String = date.fullYear + "-" + (date.month+1) + "-" + date.date + ".sqlite";
			url += "/" + name;
			file = file || new VSFile(url);
			con.open(file);
			
			if (file.exists && createStmt.sqlConnection)
				insertData();
			else
				createDataBases();
		}
		
		/**
		 * @private
		 */
		public static function getTime():String
		{
			var date:Date = new Date;
			return date.fullYear + "-" + (date.month + 1) + "-" + date.date + " " + date.hours + ":" + date.minutes + ":" + date.seconds;
		}
		
		/**
		 * @private
		 */
		private  function createDataBases():void
		{
			createStmt.sqlConnection = con;
			createStmt.text = CREATE_SQL;
			createStmt.addEventListener(SQLEvent.RESULT, insertData);
			createStmt.execute();
		}
		
		/**
		 * @private
		 */
		private function executeEnd(evt:SQLEvent):void
		{
			createStmt.removeEventListener(SQLEvent.RESULT, executeEnd);
			
			commandEnd();
		}
		
		/**
		 *  @private
		 * 
		 * 插入相关数据
		 * */
		private  function insertData(evt:SQLEvent = null):void
		{
			createStmt.removeEventListener(SQLEvent.RESULT,insertData);
			var sql:String = "insert into log(type,event,description,memo,time) values ('"+args[0]+"','"+args[1]+"','"+args[2]+"','"+args[3]+"','"+getTime()+"')";
			createStmt.text = sql;
			createStmt.addEventListener(SQLEvent.RESULT, executeEnd);
			createStmt.execute();
			con.close();
		}
		
		
		/**
		 * @private
		 */
		private var args:Array;
		
		
		/**
		 * @private
		 */
		private static var createStmt:SQLStatement = new SQLStatement;;
		
		
		/**
		 * @private
		 */
		private static var file:VSFile;
		
		/**
		 * @private
		 */
		private static var con:SQLConnection = new SQLConnection;
		
		/**
		 * @private
		 */
		private static var queue:SequenceQueue = new SequenceQueue;
		
		
		/**
		 * @private
		 */
		private static const CREATE_SQL:String = "CREATE TABLE IF NOT EXISTS log (id INTEGER PRIMARY KEY AUTOINCREMENT,type VARCHAR,event VARCHAR,description VARCHAR,memo VARCHAR,time VARCHAR)";
		
	}
}