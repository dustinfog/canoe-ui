package canoe.components
{
	import canoe.core.IFactory;
	import canoe.core.UIElement;
	import canoe.managers.SkinManager;
	import canoe.util.ObjectUtil;
	
	import flash.events.Event;
	
	public class SkinnableComponent extends UIElement
	{
		private var _skinClass : *;
        private var _skin : Skin;
		private var parts : Array;
        private var skinProperties : Object;
		
		/**
		 *	 设置获取皮肤皮肤
		 * 	支持继承自Skin的Class类型或可创建Skin实例的IFactory对象
		 **/
		public function get skinClass():*
		{
			return _skinClass || SkinManager.getSkinClass(this);
		}
		
		[Editable]
		public function set skinClass(value:*):void
		{
			if(skinClass != value)
			{
				_skinClass = value;
				createSkin();
			}
		}

		override public function set enabled(v : Boolean) : void
		{
			if(super.enabled != v)
			{
				super.enabled = v;
				invalidateSkinState();
			}
		}
		/**
		 *	构造函数 
		 * 
		 */		
		public function SkinnableComponent()
		{
			super();
            
			parts = SkinManager.getParts(this);
			skinProperties = {};
		}
		/**
		 *	获取或设置skin数据 
		 * @param v
		 * 
		 */		
		public function set skinData(v : Object) : void
		{
			if(skin)
			{
				skin.data = v;
			}
			skinProperties.data = v;
		}
		
		public function get skinData() : Object
		{
			if(skin)
			{
				return skin.data;
			}

			return skinProperties.data;
		}
		/**
		 *	获取skin 
		 * @return 
		 * 
		 */		
		public function get skin():Skin
		{
			return _skin;
		}
		/**
		 *	获取当前skin的State,值为disabled和normal 
		 * @return 
		 * 
		 */		
		protected function get currentSkinState() : String
		{
			if(!enabled) return "disabled";
			return "normal";
		}
		
		private var skinStateIsDirty : Boolean;
		
		/**
		 * 	标记组件属性失效，
		 * 
		 */
		public function invalidateSkinState() : void
		{
			skinStateIsDirty = true;
			invalidate();
		}

		private function createSkin():void
		{
			if(skin)
			{
				removeParts(skin);
				skin.removeEventListener(Event.RESIZE, dispatchEvent);
				skin.removeEventListener(Event.ADDED_TO_STAGE, skin_addedToStageHandler);
				super.removeChild(skin);
			}

			_skin = SkinManager.createSkin(this);

			skin.addEventListener(Event.RESIZE, dispatchEvent);
			ObjectUtil.overrideProperties(skin, skinProperties);
			skin.addEventListener(Event.ADDED_TO_STAGE, skin_addedToStageHandler);
			super.addChild(skin);
		}
		
		private function skin_addedToStageHandler(event:Event):void
		{
			addParts(skin);
			skin.removeEventListener(Event.ADDED_TO_STAGE, skin_addedToStageHandler);
		}
		
		override public function validate() : void
		{
			super.validate();
			if(skin && skinStateIsDirty)
			{
				skin.currentState = currentSkinState;
				skinStateIsDirty = false;
			}
		}
        
		private function removeParts(skin : Skin) : void
		{
			for each(var partId : String in parts)
			{
				var instance : * = null;
				
				if(skin.hasOwnProperty(partId))
				{
					instance = skin[partId];
				}
				else if(skinClass is IFactory)
				{
					instance = IFactory(skinClass).getProperty(skin, partId);
				}

				if(instance)
				{
					partRemoved(instance);
					this[partId] = null;
				}
			}
		}
        
		private function addParts(skin : Skin) : void
		{
			for each(var partId : String in parts)
			{
				var instance : * = null;
				
				if(skin.hasOwnProperty(partId))
				{
					instance = skin[partId];
				}
				else if(skinClass is IFactory)
				{
					instance = IFactory(skinClass).getProperty(skin, partId);
				}

				if(instance)
				{
					this[partId] = instance;
					partAdded(instance);
				}
			}
		}
		
		protected function partAdded(instance:Object) : void
		{
			
		}
        
		protected function partRemoved(instance:Object) : void
		{
			
		}
		
		override public function set measuredWidth(value:Number):void
		{
			if(measuredWidth != value)
			{
				if(skin)
				{
					skin.measuredWidth = value;
				}

				skinProperties.measuredWidth = value;
				invalidateWidth();
			}
		}
		
		override public function get measuredWidth():Number
		{
			if(skin)
			{
				return skin.measuredWidth;
			}
			else
			{
				return skinProperties.measuredWidth || super.measuredWidth;
			}
		}
		
		override public function set measuredHeight(value:Number):void
		{
			if(measuredHeight != value)
			{
				if(skin)
				{
					skin.measuredHeight = value;
				}
				skinProperties.measuredHeight = value;				
				invalidateHeight();
			}
		}
		
		override public function get measuredHeight():Number
		{
			if(skin)
			{
				return skin.measuredHeight;
			}
			else
			{
				return skinProperties.measuredHeight || super.measuredHeight;
			}
		}
		
		override public function set width(v:Number):void
		{
			if(width != v)
			{
				if(skin)
				{
					skin.width = v;
				}

				skinProperties.width = v;
				invalidateWidth();
			}
		}
		
		override public function get width():Number
		{
			if(skin)
			{
				return skin.width;
			}
			else
			{
				return skinProperties.width || 0;
			}
		}
		
		override public function set height(value:Number):void
		{
			if(height != value)
			{
				if(skin)
				{
					skin.height = value;
				}
				else
				{
					skinProperties.height = value;
				}
				
				invalidateHeight();
			}
		}
		
		override public function get height():Number
		{
			if(skin)
			{
				return skin.height;
			}
			else
			{
				return skinProperties.height || 0;
			}
		}
		override public function set minWidth(v:Number):void
		{
			if(minWidth != v)
			{
				if(skin)
				{
					skin.minWidth = v;
				}

				skinProperties.minWidth = v;
				invalidateWidth();
			}
		}
		
		override public function get minWidth():Number
		{
			if(skin)
			{
				return skin.minWidth;
			}
			else
			{
				return skinProperties.minWidth || 0;
			}
		}
		
		override public function set minHeight(value:Number):void
		{
			if(minHeight != value)
			{
				if(skin)
				{
					skin.minHeight = value;
				}

				skinProperties.minHeight = value;
				invalidateHeight();
			}
		}
		
		override public function get minHeight():Number
		{
			if(skin)
			{
				return skin.minHeight;
			}
			return skinProperties.minHeight || 0;
		}
		
		override public function get contentWidth() : Number
		{
			return skin ? skin.contentWidth :super.contentWidth 
		}
		
		override public function get contentHeight() : Number
		{
			return skin ? skin.contentHeight : super.contentHeight;	
		}
		
		override protected function create():void
		{
			super.create();
			
			if(skin == null)
			{
				createSkin();
			}
		}
	}
}