package com.winonetech.controls
{
	
	/**
	 * 
	 * 缩放缓动。
	 * 
	 */
	
	
	import caurina.transitions.Tweener;
	
	import cn.vision.utils.BitmapUtil;
	import cn.vision.utils.DebugUtil;
	
	import com.winonetech.core.wt;
	
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	import mx.graphics.BitmapFillMode;
	import mx.graphics.BitmapScaleMode;
	
	import spark.components.Group;
	import spark.components.Image;
	
	
	public final class Zoomer extends Group
	{
		
		/**
		 * 
		 * <code>Zoomer</code>构造函数。
		 * 
		 */
		
		public function Zoomer()
		{
			super();
			
			initializeEnvironment();
		}
		
		
		/**
		 * 
		 * 播放缓动动画。
		 * 
		 * @param $prev:DisplayObject 上一界面。
		 * @param $next:DisplayObject 目标界面。
		 * @param $rect:Rectangle (default = null) 占位矩形。
		 * @param $back:Boolean (default = false) 是否为向外。
		 * 
		 */
		
		public function play($prev:UIComponent,
							 $next:UIComponent,
							 $rect:Rectangle = null,
							 $back:Boolean = false):void
		{
			if(!playing)
			{
				wt::playing = true;
				prev = $prev;
				next = $next;
				rect = $rect;
				back = $back;
				
				if (prev && next)
				{
					if(!timer)
					{
						timer = new Timer(10);
						timer.addEventListener(TimerEvent.TIMER, handlerTimer);
						timer.start();
					}
				}
				else
				{
					stop();
				}
			}
		}
		
		
		/**
		 * 
		 * 暂停动画。
		 * 
		 */
		
		public function stop():void
		{
			if (playing)
			{
				wt::playing = false;
				if (timer)
				{
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER, handlerTimer);
					timer = null;
				}
				
				DebugUtil.execute(onStop);
				
				visible = false;
				
				prev && containsElement(prev) && removeElement(prev);
				next && containsElement(next) && removeElement(next);
				prev = next = null;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function updateDisplayList($unscaledWidth:Number, $unscaledHeight:Number):void
		{
			super.updateDisplayList($unscaledWidth, $unscaledHeight);
			
			if (lastWidth  != $unscaledWidth || 
				lastHeight != $unscaledHeight)
			{
				lastWidth  = $unscaledWidth;
				lastHeight = $unscaledHeight;
				
				background.graphics.clear();
				background.graphics.beginFill(0x000000);
				background.graphics.drawRect(0, 0, $unscaledWidth, $unscaledHeight);
				background.graphics.endFill();
			}
		}
		
		
		/**
		 * @private
		 */
		private function initializeEnvironment():void
		{
			addElement(background = new UIComponent);
			visible = false;
		}
		
		/**
		 * @private
		 */
		private function getImage($source:UIComponent):Image
		{
			var bmd:BitmapData = BitmapUtil.draw($source, NaN, NaN, false, 0xFFFFFF);
			var image:Image = new Image;
			image.fillMode  = BitmapFillMode .SCALE;
			image.scaleMode = BitmapScaleMode.ZOOM;
			image.source    = bmd;
			image.width     = bmd.width;
			image.height    = bmd.height;
			image.smooth    = true;
			addElement(image);
			return image;
		}
		
		/**
		 * @private
		 */
		private function privateTween():void
		{
			var ow:Number = width;
			var oh:Number = height;
			var sc:Number = rect
				?(rect.width / rect.height < ow / oh 
					? rect.height / oh 
					: rect.width  / ow) : .15;
			
			var ax:Number = back ? (rect ? rect.x : ow * .45) 
				:-(rect ? rect.x + .5 * rect.width  : .5 * ow) * sc;
			var ay:Number = back ? (rect ? rect.y : oh * .45)
				:-(rect ? rect.y + .5 * rect.height : .5 * oh) * sc;
			var aw:Number = back ? (rect ? rect.width  : ow * .1) : ow * (1 + sc);
			var ah:Number = back ? (rect ? rect.height : oh * .1) : oh * (1 + sc);
			
			prev.width  = ow;
			prev.height = oh;
			prev.x = prev.y = 0;
			
			next.x      = back ?-(rect ? rect.x + .5 * rect.width  : .5 * ow) * sc
				: (rect ? rect.x : ow * .45);
			next.y      = back ?-(rect ? rect.y + .5 * rect.height : .5 * oh) * sc
				: (rect ? rect.y : oh * .45);
			next.width  = back ? ow * (1 + sc) : (rect ? rect.width  : ow * .1);
			next.height = back ? oh * (1 + sc) : (rect ? rect.height : oh * .1);
			
			background.alpha = back ? 1 : 0;
			var aa:Number = back ? 0 : 1;
			
			Tweener.addTween(prev, {x:ax, y:ay, 
				width:aw, height:ah, alpha:aa, time:time});
			Tweener.addTween(next, {x:0 , y:0 , 
				width:ow, height:oh, time:time, 
				transition:"eastInExpo", onComplete:stop});
			Tweener.addTween(background, {alpha:aa, time:time});
			
			setElementIndex(background, 1);
			back && swapElements(prev, next);
			
			visible = true;
			
			DebugUtil.execute(onPlay);
		}
		
		
		/**
		 * @private
		 */
		private function handlerTimer($e:TimerEvent):void
		{
			if(!drawing)
			{
				drawing = true;
				if (prev is Image)
				{
					if (next is Image)
					{
						if (timer)
						{
							timer.stop();
							timer.removeEventListener(TimerEvent.TIMER, handlerTimer);
							timer = null;
						}
						privateTween();
					}
					else
					{
						next = getImage(next);
					}
				}
				else
				{
					prev = getImage(prev);
				}
				drawing = false;
			}
		}
		
		
		/**
		 * 
		 * 是否在缓动过程中。
		 * 
		 */
		
		public function get playing():Boolean
		{
			return Boolean(wt::playing);
		}
		
		
		/**
		 * 
		 * 缓动时长。
		 * 
		 */
		
		public var time:Number = 1;
		
		
		/**
		 * 
		 * 开始缓动回调。
		 * 
		 */
		
		public var onPlay:Function;
		
		
		/**
		 * 
		 * 结束缓动回调。
		 * 
		 */
		
		public var onStop:Function;
		
		
		/**
		 * @private
		 */
		private var prev:UIComponent;
		
		/**
		 * @private
		 */
		private var next:UIComponent;
		
		/**
		 * @private
		 */
		private var rect:Rectangle;
		
		/**
		 * @private
		 */
		private var back:Boolean;
		
		/**
		 * @private
		 */
		private var background:UIComponent;
		
		/**
		 * @private
		 */
		private var container:Group;
		
		/**
		 * @private
		 */
		private var lastWidth:Number;
		
		/**
		 * @private
		 */
		private var lastHeight:Number;
		
		/**
		 * @private
		 */
		private var timer:Timer;
		
		/**
		 * @private
		 */
		private var drawing:Boolean;
		
		
		/**
		 * @private
		 */
		wt var playing:Boolean;
		
	}
}