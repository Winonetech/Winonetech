package com.winonetech.controls
{
	
	/**
	 * 
	 * 可触控滚动组件。
	 * 
	 */
	
	
	import caurina.transitions.Tweener;
	
	import cn.vision.utils.ArrayUtil;
	
	import com.winonetech.core.wt;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import spark.components.Group;
	import spark.components.Scroller;
	
	
	[Event(name="scroll", type="flash.events.Event")]
	
	
	public class MultiTouchScroller extends Scroller
	{
		
		/**
		 * 
		 * 构造函数。
		 * 
		 */
		
		public function MultiTouchScroller()
		{
			super();
			
			addEventListener(MouseEvent.MOUSE_DOWN, scroller_mouseDownHandler);
		}
		
		/**
		 * 
		 * 停止滚动的缓动操作。
		 * 
		 */
		
		public function stopScrollTweening():void
		{
			tweenComplete(true);
		}
		
		
		/**
		 * @private
		 */
		private function dispatchScroll():void
		{
			dispatchEvent(new Event(Event.SCROLL));
		}
		
		/**
		 * @private
		 */
		private function tweenComplete($force:Boolean = false):void
		{
			if (tweenScrolling)
			{
				wt::tweenScrolling = false;
				if ($force)
					Tweener.removeTweens.apply(null, tweenParams);
			}
		}
		
		
		/**
		 * @private
		 */
		private function scroller_mouseDownHandler(e:MouseEvent):void
		{
			if (viewport)
			{
				if (maxHorizontalScrollPosition || 
					maxVerticalScrollPosition)
				{
					down = new Point(mouseX, mouseY);
					scro = new Point(
						viewport.horizontalScrollPosition, 
						viewport.verticalScrollPosition);    //视觉区域对于原点的坐标。
					stag = stage;
					stag.addEventListener(MouseEvent.MOUSE_MOVE, scroller_mouseMoveHandler);
					stag.addEventListener(MouseEvent.MOUSE_UP, scroller_mouseUpHandler);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function scroller_mouseMoveHandler(e:MouseEvent):void
		{
			const mouse:Point = new Point(mouseX, mouseY);
			if (Point.distance(mouse, down) > 5)
			{
				const plus:Point = down.subtract(mouse);
				if (viewport) 
				{
					var tweenObj:Object ={"time":1, 
						"onUpdate": dispatchScroll,
						"onComplete": tweenComplete
					};
					
					if (tweenParams && tweenParams.length > 1)
						Tweener.removeTweens.apply(null, tweenParams);
					
					tweenParams = [this];
					if (horizontalTouchScrollEnabled)
					{
						tweenObj["horizontalScrollPosition"] = scro.x + plus.x;
						ArrayUtil.push(tweenParams, "horizontalScrollPosition");
					}
					if (verticalTouchScrollEnabled)
					{
						tweenObj["verticalScrollPosition"] = scro.y + plus.y;
						ArrayUtil.push(tweenParams, "verticalScrollPosition");
					}
					
					
					Tweener.addTween(this, tweenObj);
					wt::tweenScrolling = true;
				}
			}
		}
		
		/**
		 * @private
		 */
		private function scroller_mouseUpHandler(e:MouseEvent):void
		{
			if (stag)
			{
				stag.removeEventListener(MouseEvent.MOUSE_MOVE, scroller_mouseMoveHandler);
				stag.removeEventListener(MouseEvent.MOUSE_UP, scroller_mouseUpHandler);
				stag = null;
			}
		}
		
		
		/**
		 * 
		 * 最大横向滚动距离。
		 * 
		 */
		
		public function get maxHorizontalScrollPosition():Number
		{
			return viewport ? viewport.contentWidth - viewport.width : 0;
		}
		
		
		/**
		 * 
		 * 最大垂直滚动距离。
		 * 
		 */
		
		public function get maxVerticalScrollPosition():Number
		{
			return viewport ? viewport.contentHeight - viewport.height : 0;
		}
		
		
		/**
		 * 
		 * 能否继续向左滚动。
		 * 
		 */
		
		public function get leftScrollable():Boolean
		{
			return horizontalScrollPosition > 0;
		}
		
		
		/**
		 * 
		 * 能否继续向右滚动。
		 * 
		 */
		
		public function get rightScrollable():Boolean
		{
			return horizontalScrollPosition < maxHorizontalScrollPosition;
		}
		
		
		/**
		 * 
		 * 能否继续向上滚动。
		 * 
		 */
		
		public function get topScrollable():Boolean
		{
			return verticalScrollPosition > 0;
		}
		
		
		/**
		 * 
		 * 能否继续向下滚动。
		 * 
		 */
		
		public function get bottomScrollable():Boolean
		{
			return verticalScrollPosition < maxVerticalScrollPosition;
		}
		
		/**
		 * 
		 * 组件的坐标系中视区原点（默认值为 (0,0)，与组件的左上角相对应）的 x 坐标。
		 * 
		 */
		
		public function get horizontalScrollPosition():Number
		{
			return viewport ? viewport.horizontalScrollPosition : 0;
		}
		
		/**
		 * @private
		 */
		public function set horizontalScrollPosition($value:Number):void
		{
			if (viewport) viewport.horizontalScrollPosition = $value;
		}
		
		
		/**
		 * 
		 * 组件的坐标系中视区原点（默认值为 (0,0)，与组件的左上角相对应）的 x 坐标。
		 * 
		 */
		
		public function get verticalScrollPosition():Number
		{
			return viewport ? viewport.verticalScrollPosition : 0;
		}
		
		/**
		 * @private
		 */
		public function set verticalScrollPosition($value:Number):void
		{
			if (viewport) viewport.verticalScrollPosition = $value;
		}
		
		
		/**
		 * 
		 * 是否在缓动过程中。
		 * 
		 */
		
		public function get tweenScrolling():Boolean
		{
			return wt::tweenScrolling as Boolean;
		}
		
		
		/**
		 * 
		 * 允许横向触摸滚动。
		 * 
		 */
		
		public var horizontalTouchScrollEnabled:Boolean = true;
		
		
		/**
		 * 
		 * 允许垂直触摸滚动。
		 * 
		 */
		
		public var verticalTouchScrollEnabled:Boolean = true;
		
		
		/**
		 * @private
		 */
		private var tweenParams:Array;
		
		/**
		 * @private
		 */
		private var down:Point;
		
		/**
		 * @private
		 */
		private var scro:Point;
		
		/**
		 * @private
		 */
		private var stag:Stage;
		
		
		/**
		 * @private
		 */
		wt var tweenScrolling:Boolean;
		
	}
}