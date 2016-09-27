package com.winonetech.support
{
	
	/**
	 * 
	 * 可自定义皮肤组件。
	 * 
	 */
	
	
	import cn.vision.utils.StringUtil;
	
	import com.winonetech.core.wt;
	
	import spark.components.Button;
	import spark.components.supportClasses.SkinnableComponent;
	
	
	public class SkinComponent extends SkinnableComponent
	{
		
		/**
		 * 
		 * 构造函数。
		 * 
		 */
		
		public function SkinComponent()
		{
			super();
			
			registParts();
		}
		
		
		/**
		 * 
		 * 注册part函数回调。
		 * 
		 */
		
		protected function registParts():void
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance.id &&
				partAddedHandlers[instance.id])
			{
				partAddedHandlers[instance.id]();
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance.id &&
				partRemovedHandlers[instance.id])
			{
				partRemovedHandlers[instance.id]();
			}
		}
		
		
		/**
		 * 
		 * 注册组件回调，注册后的方法会在partAdded中调用。
		 * 
		 * @param $id:String 组件的ID。
		 * @param $handler:Function 回调函数。
		 * 
		 */
		
		protected function registPartHandler($id:String, $partAdded:Function, $partRemoved:Function):void
		{
			if (!StringUtil.isEmpty($id))
			{
				if ($partAdded  != null) partAddedHandlers  [$id] = $partAdded;
				if ($partRemoved!= null) partRemovedHandlers[$id] = $partRemoved;
			}
		}
		
		
		/**
		 * @private
		 */
		private const partAddedHandlers:Object = {};
		
		/**
		 * @private
		 */
		private const partRemovedHandlers:Object = {};
		
		
		/**
		 * @pirvate
		 */
		wt var skinState:String = "normal";
		
	}
}