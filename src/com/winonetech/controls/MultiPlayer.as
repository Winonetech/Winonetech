package com.winonetech.controls
{
	import cn.vision.consts.FileTypeConsts;
	import cn.vision.utils.FileUtil;
	
	import com.winonetech.core.wt;
	import com.winonetech.skins.MultiPlayerSkin;
	import com.winonetech.support.SkinComponent;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	
	import mx.events.FlexEvent;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaPlayerState;
	
	import spark.components.Image;
	import spark.components.VideoPlayer;
	
	
	[SkinState("image")]
	
	[SkinState("video")]
	
	
	[SkinState("disabled")]
	
	
	public class MultiPlayer extends SkinComponent
	{
		
		/**
		 * 
		 * 构造函数。
		 * 
		 */
		
		public function MultiPlayer()
		{
			super();
			
			setStyle("skinClass", com.winonetech.skins.MultiPlayerSkin);
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			/*trace(width, height);
			
			trace("measure", measuredWidth, measuredHeight);
			
			trace("explicit", explicitWidth, explicitHeight);
			trace("unscaled", unscaledWidth, unscaledHeight);
			
			switch (getCurrentSkinState())
			{
				case "image":
					
					break;
				case "video":
					
					break;
			}
			
			trace("updateDisplayList")*/
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function registParts():void
		{
			registPartHandler("imagePlayer", partAddedImagePlayer, partRemovedImagePlayer);
			registPartHandler("videoPlayer", partAddedVideoPlayer, partRemovedVideoPlayer);
		}
		
		
		/**
		 * @private
		 */
		private function partAddedImagePlayer():void
		{
			imagePlayer.addEventListener(Event.COMPLETE, imagePlayer_defaultHandler);
			imagePlayer.addEventListener(FlexEvent.READY, imagePlayer_defaultHandler);
			imagePlayer.addEventListener(HTTPStatusEvent.HTTP_STATUS, imagePlayer_defaultHandler);
			imagePlayer.addEventListener(IOErrorEvent.IO_ERROR, imagePlayer_defaultHandler);
			imagePlayer.addEventListener(ProgressEvent.PROGRESS, imagePlayer_defaultHandler);
			imagePlayer.addEventListener(SecurityErrorEvent.SECURITY_ERROR, imagePlayer_defaultHandler);
			imagePlayer.source = source;
		}
		
		/**
		 * @private
		 */
		private function partAddedVideoPlayer():void
		{
			videoPlayer.addEventListener(LoadEvent.BYTES_LOADED_CHANGE, videoPlayer_defaultHandler);
			videoPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, videoPlayer_defaultHandler);
			videoPlayer.addEventListener(TimeEvent.COMPLETE, videoPlayer_defaultHandler);
			videoPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, videoPlayer_defaultHandler);
			videoPlayer.addEventListener(TimeEvent.DURATION_CHANGE, videoPlayer_defaultHandler);
			videoPlayer.source = source;
		}
		
		/**
		 * @private
		 */
		private function partRemovedImagePlayer():void
		{
			imagePlayer.removeEventListener(Event.COMPLETE, imagePlayer_defaultHandler);
			imagePlayer.removeEventListener(FlexEvent.READY, imagePlayer_defaultHandler);
			imagePlayer.removeEventListener(HTTPStatusEvent.HTTP_STATUS, imagePlayer_defaultHandler);
			imagePlayer.removeEventListener(IOErrorEvent.IO_ERROR, imagePlayer_defaultHandler);
			imagePlayer.removeEventListener(ProgressEvent.PROGRESS, imagePlayer_defaultHandler);
			imagePlayer.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, imagePlayer_defaultHandler);
			imagePlayer.source = null;
		}
		
		/**
		 * @private
		 */
		private function partRemovedVideoPlayer():void
		{
			videoPlayer.removeEventListener(LoadEvent.BYTES_LOADED_CHANGE, videoPlayer_defaultHandler);
			videoPlayer.removeEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, videoPlayer_defaultHandler);
			videoPlayer.removeEventListener(TimeEvent.COMPLETE, videoPlayer_defaultHandler);
			videoPlayer.removeEventListener(TimeEvent.CURRENT_TIME_CHANGE, videoPlayer_defaultHandler);
			videoPlayer.removeEventListener(TimeEvent.DURATION_CHANGE, videoPlayer_defaultHandler);
			videoPlayer.source = null;
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (sourceChanged && (imagePlayer || videoPlayer))
			{
				switch (getCurrentSkinState())
				{
					case "image":
						if (imagePlayer) imagePlayer.source = source;
						break;
					case "video":
						if (videoPlayer) videoPlayer.source = source;
						break;
				}
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function getCurrentSkinState():String
		{
			if(!enabled) return "disabled";
			
			if (source is String)
			{
				const ext:String = FileUtil.getFileTypeByURL(source as String);
				if (ext == FileTypeConsts.FLV || ext == FileTypeConsts.MP4)
				{
					return "video";
				}
			}
			return "image";
		}
		
		
		/**
		 * @private
		 */
		private function imagePlayer_defaultHandler(e:Event):void
		{
			dispatchEvent(e);
		}
		
		/**
		 * @private
		 */
		private function videoPlayer_defaultHandler(e:Event):void
		{
			dispatchEvent(e);
		}
		
		
		/**
		 * 
		 * 图片源或视频源。
		 * 
		 */
		
		[Bindable]
		public function get source():Object
		{
			return wt::source;
		}
		
		/**
		 * @private
		 */
		public function set source($value:Object):void
		{
			if (source!= $value)
			{
				wt::source = $value;
				
				sourceChanged = true;
				
				invalidateProperties();
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override public function set explicitWidth(value:Number):void
		{
			if (explicitWidth!= value)
			{
				super.explicitWidth = value;
				
				widthChanged = true;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override public function set percentWidth(value:Number):void
		{
			if (percentWidth!= value)
			{
				super.percentWidth = value;
				
				widthChanged = true;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override public function set explicitHeight(value:Number):void
		{
			if (explicitHeight!= value)
			{
				super.explicitHeight = value;
				
				heightChanged = true;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override public function set percentHeight(value:Number):void
		{
			if (percentHeight!= value)
			{
				super.percentHeight = value;
				
				heightChanged = true;
			}
		}
		
		
		/**
		 * 
		 * 图片播放组件。
		 * 
		 */
		
		[SkinPart(required="false")]
		public var imagePlayer:Image;
		
		
		/**
		 * 
		 * 视频组件。
		 * 
		 */
		
		[SkinPart(required="false")]
		public var videoPlayer:VideoPlayer;
		
		
		/**
		 * 
		 * 视频是否自动播放。
		 * 
		 */
		
		public var autoPlay:Boolean = true;
		
		
		/**
		 * @private
		 */
		private var sourceChanged:Boolean;
		
		/**
		 * @private
		 */
		private var widthChanged:Boolean;
		
		/**
		 * @private
		 */
		private var heightChanged:Boolean;
		
		
		/**
		 * @private
		 */
		wt var source:Object;
		
	}
}