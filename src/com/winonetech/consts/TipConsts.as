package com.winonetech.consts
{
	
	/**
	 * 
	 * 定义提示常量。
	 * 
	 */
	
	
	import cn.vision.data.Tip;
	
	
	public final class TipConsts
	{
		
		
		/**
		 * 
		 * Socket通信服务端安全沙箱错误。
		 * 
		 */
		
		public static const ERROR_SOCKET_SECURITY:cn.vision.data.Tip = new Tip("通信服务端安全沙箱错误！", 0);
		
		
		/**
		 * 
		 * 缓存文件不存在。
		 * 
		 */
		
		public static const NOTICE_CACHE_UNEXIST:Tip = new Tip("文件不存在：{saveURL}, {loadURL}。", 1);
		
		
		/**
		 * 
		 * Socket连接断开。
		 * 
		 */
		
		public static const NOTICE_SOCKET_DISCONNECT:Tip = new Tip("Socket连接断开，将在 {autoReconnectTime} 秒后重连！", 1);
		
		
		/**
		 * 
		 * Socket创建连接。
		 * 
		 */
		
		public static const RECORD_SOCKET_CONNECT:Tip = new Tip("连接推送服务端：{ip}, {port}。", 2);
		
		
		/**
		 * 
		 * Socket连接失败。
		 * 
		 */
		
		public static const RECORD_SOCKET_FAILURE:Tip = new Tip("连接推送服务端失败：{ip}, {port}。", 2);
		
		
		/**
		 * 
		 * Socket连接成功。
		 * 
		 */
		
		public static const RECORD_SOCKET_SUCCESS:Tip = new Tip("连接推送服务端成功：{ip}, {port}。", 2);
		
	}
}