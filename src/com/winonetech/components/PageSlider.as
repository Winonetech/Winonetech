package com.winonetech.components
{
	
	import cn.vision.utils.MathUtil;
	
	import com.winonetech.core.wt;
	import com.winonetech.skins.PageSliderSkin;
	import com.winonetech.support.SkinComponent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.Button;
	import spark.components.HSlider;
	
	
	[SkinState("normal")]
	
	
	[SkinState("disabled")]
	
	
	[Event(name="change", type="flash.events.Event")]
	
	
	public class PageSlider extends SkinComponent
	{
		
		/**
		 * 
		 * 构造函数。
		 * 
		 */
		
		public function PageSlider()
		{
			super();
			
			mouseEnabled = false;
			
			setStyle("skinClass", com.winonetech.skins.PageSliderSkin);
		}
		
		
		/**
		 * 
		 * 上一页。
		 * 
		 */
		
		public function prev():void
		{
			if (prevable) current--;
		}
		
		
		/**
		 * 
		 * 下一页。
		 * 
		 */
		
		public function next():void
		{
			if (nextable) current++;
		}
		
		
		/**
		 * 
		 * 注册part函数回调。
		 * 
		 */
		
		override protected function registParts():void
		{
			registPartHandler("prevButton" , partAddedPrevButton , partRemovedPrevButton);
			registPartHandler("nextButton" , partAddedNextButton , partRemovedNextButton);
			registPartHandler("valueSlider", partAddedValueSlider, partRemovedValueSlider);
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			updateComponents();
		}
		
		
		/**
		 * @inheritDoc
		 */
		
		override protected function getCurrentSkinState():String
		{
			return enabled ? "normal" : "disabled";
		}
		
		
		/**
		 * @private
		 */
		private function updateComponents():void
		{
			wt::prevable = wt::current > wt::min;
			wt::nextable = wt::current < wt::max;
			prevButton.enabled = prevable;
			nextButton.enabled = nextable;
			
			valueSlider.minimum = wt::min;
			valueSlider.maximum = wt::max;
			valueSlider.value = wt::current;
		}
		
		
		/**
		 * @private
		 */
		private function partAddedPrevButton():void
		{
			prevButton.addEventListener(MouseEvent.CLICK, prev_clickHandler);
		}
		
		/**
		 * @private
		 */
		private function partRemovedPrevButton():void
		{
			prevButton.removeEventListener(MouseEvent.CLICK, prev_clickHandler);
		}
		
		/**
		 * @private
		 */
		private function partAddedNextButton():void
		{
			nextButton.addEventListener(MouseEvent.CLICK, next_clickHandler);
		}
		
		/**
		 * @private
		 */
		private function partRemovedNextButton():void
		{
			nextButton.removeEventListener(MouseEvent.CLICK, prev_clickHandler);
		}
		
		/**
		 * @private
		 */
		private function partAddedValueSlider():void
		{
			valueSlider.addEventListener(Event.CHANGE, slider_changeHandler);
			
			valueSlider.stepSize = 1;
			valueSlider.minimum = wt::min;
			valueSlider.maximum = wt::max;
			valueSlider.value = wt::current;
		}
		
		/**
		 * @private
		 */
		private function partRemovedValueSlider():void
		{
			valueSlider.removeEventListener(Event.CHANGE, slider_changeHandler);
		}
		
		
		/**
		 * @private
		 */
		private function prev_clickHandler($e:MouseEvent):void
		{
			prev();
		}
		
		/**
		 * @private
		 */
		private function next_clickHandler($e:MouseEvent):void
		{
			next();
		}
		
		/**
		 * @private
		 */
		private function slider_changeHandler($e:Event):void
		{
			current = valueSlider.value;
		}
		
		
		/**
		 * 
		 * 最大页
		 * 
		 */
		
		[Bindable]
		public function get max():uint
		{
			return wt::max;
		}
		
		/**
		 * @private
		 */
		public function set max($value:uint):void
		{
			if (!isNaN($value) && $value != wt::max)
			{
				wt::max = Math.max($value, wt::current);
				
				invalidateProperties();
			}
		}
		
		
		/**
		 * 
		 * 最小页
		 * 
		 */
		
		[Bindable]
		public function get min():uint
		{
			return wt::min;
		}
		
		/**
		 * @private
		 */
		public function set min($value:uint):void
		{
			if (!isNaN($value) && $value != wt::min)
			{
				wt::min = Math.min($value, wt::current);
				
				invalidateProperties();
			}
		}
		
		
		/**
		 * 
		 * 当前页
		 * 
		 */
		
		[Bindable]
		public function get current():uint
		{
			return wt::current;
		}
		
		/**
		 * @private
		 */
		public function set current($value:uint):void
		{
			if (!isNaN($value) && $value != wt::current)
			{
				wt::current = MathUtil.clamp($value, min, max);
				
				invalidateProperties();
				
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		
		/**
		 * 
		 * 能否上一页
		 * 
		 */
		
		public function get prevable():Boolean
		{
			return wt::prevable as Boolean;
		}
		
		
		/**
		 * 
		 * 能否上一页
		 * 
		 */
		
		public function get nextable():Boolean
		{
			return wt::nextable as Boolean;
		}
		
		
		/**
		 * 
		 * 上一页按钮。
		 * 
		 */
		
		[SkinPart(required="false")]
		public var prevButton:Button;
		
		
		/**
		 * 
		 * 下一页按钮。
		 * 
		 */
		
		[SkinPart(required="false")]
		public var nextButton:Button;
		
		
		/**
		 * 
		 * 滑动组件背景线。
		 * 
		 */
		
		[SkinPart(required="false")]
		public var valueSlider:HSlider;
		
		
		/**
		 * @private
		 */
		private var partAddedHandlers:Object = {};
		
		/**
		 * @private
		 */
		private var partRemovedHandlers:Object = {};
		
		
		/**
		 * @private
		 */
		wt var prevable:Boolean;
		
		/**
		 * @private
		 */
		wt var nextable:Boolean;
		
		/**
		 * @private
		 */
		wt var max:uint;
		
		/**
		 * @private
		 */
		wt var min:uint;
		
		/**
		 * @private
		 */
		wt var current:uint;
		
	}
}