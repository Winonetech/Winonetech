package com.winonetech.controls
{
	
	/**
	 * 
	 * 网页控件。
	 * 
	 */
	
	
	import cn.vision.utils.ArrayUtil;
	import cn.vision.utils.DebugUtil;
	import cn.vision.utils.HTTPUtil;
	
	import com.winonetech.core.wt;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.html.HTMLLoader;
	import flash.utils.Dictionary;
	
	import mx.controls.HTML;
	
	
	public final class Browser extends HTML
	{
		
		/**
		 * 
		 * <code>Browser</code>构造函数。
		 * 
		 */
		
		public function Browser()
		{
			super();
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			htmlLoader.visible = location as Boolean;
			htmlLoader.useCache = true;
			htmlLoader.cacheResponse = true;
			htmlLoader.idleTimeout = 60;
			htmlLoader.navigateInSystemBrowser = false;
			htmlLoader.htmlHost = new SelfHTMLHost;
			addEventListener(Event.HTML_DOM_INITIALIZE, htmlDomInitialize, true);
			addEventListener(Event.HTML_BOUNDS_CHANGE, htmlBoundsChange, true);
		}
		
		
		/**
		 * @private
		 */
		private function initializeContent():void
		{
			if (document)
			{
				document.onselectstart = function():*{return selectable;};
				if(!title) wt::title = document.getElementsByTagName("title")[0].innerText;
				if(!body ) wt::body  = document.getElementsByTagName("body")[0];
				if (body)  body.onmousedown = bodyMouseDown;
				if(body && title) removeEventListener(Event.HTML_RENDER, htmlRender);
			}
			else
			{
				wt::document = domWindow.document;
			}
		}
		
		/**
		 * @private
		 */
		private function analyzeContent($content:Object):void
		{
			if ($content)
			{
				//trace("analyzeContent");
				DebugUtil.execute(analyzeInput, false, $content);
				DebugUtil.execute(analyzeArea , false, $content);
				DebugUtil.execute(analyzeFrame, false, $content, "frame");
				DebugUtil.execute(analyzeFrame, false, $content, "iframe");
			}
		}
		
		/**
		 * @private
		 */
		private function analyzeInput($content:Object):void
		{
			
			var a:Object = $content.getElementsByTagName("input");
			var l:int = a.length;
			for (var i:int = 0; i < l; i++)
			{
				if(!dictionary[a[i]] && (a[i].type == "text" || a[i].type=="password"))
				{
					dictionary[a[i]] = true;
					ArrayUtil.push(wt::inputs, a[i]);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function analyzeArea($content:Object):void
		{
			var a:Object = $content.getElementsByTagName("textarea");
			var l:int = a.length;
			for (var i:int = 0; i < l; i++)
			{
				if (!dictionary[a[i]])
				{
					dictionary[a[i]] = true;
					ArrayUtil.push(wt::inputs, a[i]);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function analyzeFrame($content:Object, $element:String = "frame"):void
		{
			var a:Object = $content.getElementsByTagName($element);
			var l:int = a.length;
			for (var i:int = 0; i < l; i++)
				analyzeContent(a[i].contentDocument);
		}
		
		/**
		 * @private
		 */
		private function clearProperties():void
		{
			wt::document = wt::body = wt::title = null;
			dictionary = new Dictionary;
			inputs.length = 0;
		}
		
		/**
		 * @private
		 */
		private function caculateBounds():void
		{
			wt::maxScrollV = contentHeight - height;
			wt::maxScrollH = contentWidth  - width;
			verticalScrollPosition   = Math.min(verticalScrollPosition  , wt::maxScrollV);
			horizontalScrollPosition = Math.min(horizontalScrollPosition, wt::maxScrollH);
		}
		
		
		/**
		 * @private
		 */
		private function htmlDomInitialize($e:Event):void
		{
			addEventListener(Event.HTML_RENDER, htmlRender, true);
			addEventListener(Event.COMPLETE, htmlComplete, true);
			
			clearProperties();
			caculateBounds();
			
			wt::historyBackwardable = historyPosition > 0;
			wt::historyForwardable = historyPosition < historyLength - 1;
		}
		
		/**
		 * @private
		 */
		private function htmlBoundsChange($e:Event = null):void
		{
			caculateBounds();
		}
		
		/**
		 * @private
		 */
		private function htmlRender($e:Event):void
		{
			DebugUtil.execute(initializeContent, false);
		}
		
		/**
		 * @private
		 */
		private function htmlComplete($e:Event):void
		{
			removeEventListener(Event.COMPLETE, htmlComplete, true);
			analyzeContent(document);
		}
		
		/**
		 * @private
		 */
		private function bodyMouseDown(o:Object):void
		{
			if (panable && body)
			{
				lastX = mouseX;
				lastY = mouseY;
				lastH = horizontalScrollPosition;
				lastV = verticalScrollPosition;
				body.onmousemove = bodyMouseMove;
				body.onmouseup   = bodyMouseUp  ;
			}
		}
		
		/**
		 * @private
		 */
		private function bodyMouseMove(o:Object):void
		{
			var plsX:Number = mouseX - lastX;
			var plsY:Number = mouseY - lastY;
			if (Math.abs(plsX)+Math.abs(plsY) > 10)
			{
				stage.addEventListener(MouseEvent.MOUSE_MOVE, htmlMouseMove, true);
				stage.addEventListener(MouseEvent.MOUSE_UP, htmlMouseUp, true);
				bodyMouseUp(null);
			}
		}
		
		/**
		 * @private
		 */
		private function bodyMouseUp(o:Object = null):void
		{
			body.onmousemove = null;
			body.onmouseup   = null;
		}
		
		/**
		 * @private
		 */
		private function htmlMouseMove(e:MouseEvent):void
		{
			targX = lastX - mouseX + lastH;
			targY = lastY - mouseY + lastV;
			targX = Math.min(Math.max(0, targX), maxHorizontalScrollPosition);
			targY = Math.min(Math.max(0, targY), maxVerticalScrollPosition);
			if(!moving)
			{
				moving = true;
				addEventListener(Event.ENTER_FRAME, moveEnterFrame);
			}
		}
		
		/**
		 * @private
		 */
		private function htmlMouseUp(o:Object):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, htmlMouseMove, true);
			stage.removeEventListener(MouseEvent.MOUSE_UP  , htmlMouseUp  , true);
		}
		
		/**
		 * @private
		 */
		private function moveEnterFrame(e:Event):void
		{
			var plsX:Number = targX - horizontalScrollPosition;
			var plsY:Number = targY - verticalScrollPosition;
			if (Math.abs(plsX)<1&&Math.abs(plsY)<1)
			{
				horizontalScrollPosition = targX;
				verticalScrollPosition   = targY;
				removeEventListener(Event.ENTER_FRAME, moveEnterFrame);
				moving = false;
			}
			else
			{
				horizontalScrollPosition += plsX * .3;
				verticalScrollPosition   += plsY * .3;
			}
		}
		
		
		/**
		 * 
		 * 网页的主体对象，在分派htmlDOMInitialize之前为null。
		 * 
		 */
		
		public function get body():Object
		{
			return wt::body;
		}
		
		
		/**
		 * 
		 * 网页的文档对象，在分派htmlDOMInitialize之前为null。
		 * 
		 */
		
		override public function get document():Object
		{
			return wt::document;
		}
		
		
		/**
		 * 
		 * 设定主页。
		 * 
		 */
		[Bindable]
		public function get home():String
		{
			return wt::home;
		}
		
		/**
		 * @private
		 */
		public function set home($value:String):void
		{
			wt::home = $value;
		}
		
		
		/**
		 * 
		 * 历史记录能否再后退。
		 * 
		 */
		
		public function get historyBackwardable():Boolean
		{
			return Boolean(wt::historyBackwardable);
		}
		
		
		/**
		 * 
		 * 历史记录能否再前进。
		 * 
		 */
		
		public function get historyForwardable():Boolean
		{
			return Boolean(wt::historyForwardable);
		}
		
		
		/**
		 * 
		 * 文本输入框列表。
		 * 
		 */
		
		public function get inputs():Vector.<Object>
		{
			return wt::inputs;
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override public function set location($value:String):void
		{
			if(!HTTPUtil.validateIdentical(location, $value))
			{
				clearProperties();
				if (htmlLoader) 
				{
					htmlLoader.visible = Boolean($value);
					htmlLoader.cancelLoad();
					if (htmlLoader.visible)
					{
						super.location = $value;
					}
				}
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override public function get maxHorizontalScrollPosition():Number
		{
			return wt::maxScrollH;
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override public function get maxVerticalScrollPosition():Number
		{
			return wt::maxScrollV;
		}
		
		
		/**
		 * 
		 * 当前页面的标题。
		 * 
		 */
		
		public function get title():String
		{
			return wt::title;
		}
		
		
		/**
		 * 
		 * 表示客户端系统是否支持该控件类。
		 * 
		 */
		
		public static function get supported():Boolean
		{
			return HTMLLoader.isSupported;
		}
		
		
		/**
		 * 
		 * 能否拖动。
		 * 
		 */
		
		public var panable:Boolean = true;
		
		
		/**
		 * 
		 * 文本内容是否可选。
		 * 
		 */
		
		public var selectable:Boolean = false;
		
		
		/**
		 * @private
		 */
		private var moving:Boolean;
		
		/**
		 * @private
		 */
		private var targX:Number;
		
		/**
		 * @private
		 */
		private var targY:Number;
		
		/**
		 * @private
		 */
		private var lastX:Number;
		
		/**
		 * @private
		 */
		private var lastY:Number;
		
		/**
		 * @private
		 */
		private var lastH:Number;
		
		/**
		 * @private
		 */
		private var lastV:Number;
		
		/**
		 * @private
		 */
		private var dictionary:Dictionary;
		
		
		/**
		 * @private
		 */
		wt var body:Object;
		
		/**
		 * @private
		 */
		wt var document:Object;
		
		/**
		 * @private
		 */
		wt var historyBackwardable:Boolean;
		
		/**
		 * @private
		 */
		wt var historyForwardable:Boolean;
		
		/**
		 * @private
		 */
		wt var home:String;
		
		/**
		 * @private
		 */
		wt var inputs:Vector.<Object> = new Vector.<Object>;
		
		/**
		 * @private
		 */
		wt var maxScrollH:Number = 0;
		
		/**
		 * @private
		 */
		wt var maxScrollV:Number = 0;
		
		/**
		 * @private
		 */
		wt var title:String = null;
		
	}
}


/**
 * 
 * 在自身页面打开网页的htmlHost解决方案。
 * 
 */


import flash.events.Event;
import flash.html.HTMLHost;
import flash.html.HTMLLoader;
import flash.html.HTMLWindowCreateOptions;


class SelfHTMLHost extends HTMLHost
{
	
	/**
	 * 
	 * <code>SelfHTMLHost</code>构造函数。
	 * 
	 */
	
	public function SelfHTMLHost($defaultBehaviors:Boolean = true)
	{
		super($defaultBehaviors);
	}
	
	
	/**
	 * @inheritDoc
	 */
	
	override public function createWindow($windowCreateOptions:HTMLWindowCreateOptions):HTMLLoader
	{
		return htmlLoader;
	}
	
}