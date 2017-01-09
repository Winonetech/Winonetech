package com.winonetech.consts
{
	
	/**
	 * 
	 * 定义缓存路径。
	 * 
	 */
	
	
	import cn.vision.core.NoInstance;
	
	
	public final class PathConsts extends NoInstance
	{
		
		/**
		 * 
		 * 文件相对缓存路径。
		 * 
		 * @default cache
		 * 
		 */
		
		public static const PATH_FILE:String = "cache";
		
		/**
		 * 
		 * 存储服务端文件是否存在的缓存列表。
		 * 
		 * @default cache/fileList.lst
		 * 
		 */
		
		public static const PATH_FILE_LIST_CACHE:String = "cache/fileList.lst";
		
	}
}