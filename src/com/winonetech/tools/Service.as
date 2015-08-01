package com.winonetech.tools
{
	
	/**
	 * 
	 * Socket服务交互。
	 * 
	 */
	
	
	import cn.vision.core.VSEventDispatcher;
	import cn.vision.utils.LogUtil;
	
	import com.winonetech.consts.TipConsts;
	import com.winonetech.core.wt;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.Timer;
	
	
	public class Service extends VSEventDispatcher
	{
		
		/**
		 * 
		 * <code>Service</code>构造函数。
		 * 
		 */
		
		public function Service()
		{
			super();
		}
		
		
		/**
		 * 
		 * 连接socket服务端。
		 * 
		 * @param $ip:String 服务器地址。
		 * @param $port:uint 服务器端口。
		 * 
		 */
		
		public function connect($ip:String, $port:uint):void
		{
			wt::ip   = $ip;
			wt::port = $port;
			
			LogUtil.logTip(TipConsts.RECORD_SOCKET_CONNECT, this); 
			
			if(!socket)
			{
				socket = new Socket;
				socket.addEventListener(Event.CLOSE, handlerSocketRetry);
				socket.addEventListener(Event.CONNECT, handlerSocketConnected);
				socket.addEventListener(IOErrorEvent.IO_ERROR, handlerSocketRetry);
				socket.addEventListener(ProgressEvent.SOCKET_DATA, handlerSocketData);
				socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handlerSocketRetry);
			}
			
			socket.connect($ip, $port);
		}
		
		
		/**
		 * 
		 * 关闭socket连接。
		 * 
		 */
		
		public function close():void
		{
			if (socket)
			{
				socket.connected && socket.close();
				socket.removeEventListener(Event.CLOSE, handlerSocketRetry);
				socket.removeEventListener(Event.CONNECT, handlerSocketConnected);
				socket.removeEventListener(IOErrorEvent.IO_ERROR, handlerSocketRetry);
				socket.removeEventListener(ProgressEvent.SOCKET_DATA, handlerSocketData);
				socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handlerSocketRetry);
				socket = null;
			}
			
			removeTimer();
		}
		
		
		/**
		 * @private
		 */
		protected function createTimer($delay:Number, $handler:Function):void
		{
			if(!timer)
			{
				timerHandler = $handler;
				timer = new Timer($delay * 1000);
				timer.addEventListener(TimerEvent.TIMER, timerHandler);
				timer.start();
			}
		}
		
		
		/**
		 * @private
		 */
		protected function removeTimer():void
		{
			if (timer)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, timerHandler);
				timer = null;
			}
		}
		
		
		/**
		 * @private
		 */
		protected function handlerSocketConnected($e:Event):void
		{
			LogUtil.logTip(TipConsts.RECORD_SOCKET_SUCCESS, this);
			
			removeTimer();
			count = 0;
		}
		
		/**
		 * @private
		 */
		protected function handlerSocketData($e:ProgressEvent):void
		{
			count = 0;
		}
		
		/**
		 * @private
		 */
		private function handlerSocketRetry($e:Event = null):void
		{
			try
			{
				close();
				
				if (count++ < 3)
				{
					LogUtil.logTip(TipConsts.RECORD_SOCKET_FAILURE, this);
					
					connect(ip, port);
				}
				else
				{
					count = 0;
					if (autoReconnect)
					{
						LogUtil.logTip(TipConsts.NOTICE_SOCKET_DISCONNECT, this);
						
						createTimer(autoReconnectTime || 60, handlerTimerReconnect);
					}
				}
			}
			catch(e:Error)
			{
				LogUtil.log(e.getStackTrace());
			}
		}
		
		/**
		 * @private
		 */
		private function handlerTimerReconnect($e:TimerEvent):void
		{
			handlerSocketRetry();
		}
		
		
		/**
		 * 
		 * ip
		 * 
		 */
		
		public function get ip():String
		{
			return wt::ip;
		}
		
		
		/**
		 * 
		 * port
		 * 
		 */
		
		public function get port():uint
		{
			return wt::port;
		}
		
		
		/**
		 * 
		 * SOCKET断开后是否自动重连。
		 * 
		 */
		
		public var autoReconnect:Boolean = true;
		
		/**
		 * 
		 * SOCKET断开后自动重连时长，以秒为单位。
		 * 
		 */
		
		public var autoReconnectTime:uint = 60;
		
		
		/**
		 * @private
		 */
		private var count:uint;
		
		/**
		 * @private
		 */
		private var timer:Timer;
		
		/**
		 * @private
		 */
		private var timerHandler:Function;
		
		/**
		 * @private
		 */
		protected var socket:Socket;
		
		
		/**
		 * @private
		 */
		wt var ip:String;
		
		/**
		 * @private
		 */
		wt var port:uint;
		
	}
}