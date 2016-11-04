package com.winonetech.controls
{
	
	/**
	 * 
	 * 流媒体播放器。
	 * 
	 */
	
	
	import com.winonetech.core.wt;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.system.LoaderContext;
	
	import mx.core.UIComponent;
	
	
	public class StreamPlayer extends UIComponent
	{
		
		/**
		 * 
		 * 构造函数
		 * 
		 */
		
		public function StreamPlayer()
		{
			super();
		}
		
		
		/**
		 * 
		 * 暂停播放。
		 * 
		 */
		
		public function pause():void
		{
			if (pausable) 
			{
				try
				{
					content.pause();
				}
				catch(e:Error) {}
			}
		}
		
		
		/**
		 * 
		 * 恢复播放。
		 * 
		 */
		
		public function resume():void
		{
			if (pausable) 
			{
				try
				{
					content.resume();
				}
				catch(e:Error) {}
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			var context:LoaderContext = new LoaderContext;
			context.allowCodeImport = true;
			loader.loadBytes(STREAM_MEDIA.movieClipData, context);
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (content)
			{
				content.width  = unscaledWidth;
				content.height = unscaledHeight;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (content)
			{
				content.autoPlay = autoPlay;
				
				if (sourceChanged)
				{
					sourceChanged = false;
					content.source = source;
				}
			}
		}
		
		
		/**
		 * @private
		 */
		private function loader_completeHandler($e:Event):void
		{
			loader.removeEventListener(Event.COMPLETE, loader_completeHandler);
			
			addChild(loader.content);
			content = loader.content;
			
			invalidateDisplayList();
			invalidateProperties();
		}
		
		
		/**
		 * 
		 * 资源路径。
		 * 
		 */
		
		public function get source():String
		{
			return wt::source;
		}
		
		/**
		 * @private
		 */
		public function set source($value:String):void
		{
			if (wt::source!= $value)
			{
				wt::source = $value;
				
				sourceChanged = true;
				
				invalidateProperties();
			}
		}
		
		
		/**
		 * 
		 * 自动播放。
		 * 
		 */
		
		public function get autoPlay():Boolean
		{
			return wt::autoPlay as Boolean;
		}
		
		/**
		 * @private
		 */
		public function set autoPlay($value:Boolean):void
		{
			if (wt::autoPlay!= $value)
			{
				wt::autoPlay = $value;
				
				invalidateProperties();
			}
		}
		
		
		/**
		 * 
		 * 能否暂停。
		 * 
		 */
		
		public function get pausable():Boolean
		{
			return content ? content.canPause : false;
		}
		
		
		/**
		 * @private
		 */
		[Embed(source = "StreamPlayer.swf")]
		private static const Stream:Class;
		
		
		/**
		 * @private
		 */
		private static const STREAM_MEDIA:* = new Stream;
		
		
		/**
		 * @private
		 */
		private var sourceChanged:Boolean;
		
		/**
		 * @private
		 */
		private var loader:Loader;
		
		/**
		 * @private
		 */
		private var content:Object;
		
		
		/**
		 * @private
		 */
		wt var source:String;
		
		/**
		 * @private
		 */
		wt var autoPlay:Boolean = true;
		
	}
}