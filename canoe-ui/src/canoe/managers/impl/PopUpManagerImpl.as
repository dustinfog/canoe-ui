package canoe.managers.impl
{
	import canoe.managers.IPopUpManager;
	import canoe.managers.PopUpLayer;
	import canoe.util.ArrayUtil;
	import canoe.util.BitmapDataUtil;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;

	public class PopUpManagerImpl implements IPopUpManager
	{
		private const layerDict : Object = {};
        private var modalMask : Sprite;
		private var _modalMaskColor : uint = 0;
        private var _modalMaskAlpha : Number = 0.2;
        private var root : Sprite;
		private var modalQueue : Array = [];
		
		public function get modalMaskAlpha():Number
		{
			return _modalMaskAlpha;
		}

		public function set modalMaskAlpha(value:Number):void
		{
            if(_modalMaskAlpha != value)
			{
				_modalMaskAlpha = value;
                redrawModalMask();
			}
		}

		public function get modalMaskColor():uint
		{
			return _modalMaskColor;
		}

		public function set modalMaskColor(value:uint):void
		{
            if(_modalMaskColor != value)
			{
				_modalMaskColor = value;
				redrawModalMask();
			}
		}

		public function initialize(root : Sprite) : void
		{
			if(this.root) return;
			
			this.root = root;
			var layerWindows : Sprite  = new Sprite();
			layerDict[PopUpLayer.LAYER_WINDOWS] = layerWindows;
			root.addChild(layerWindows);
			
			var layerWidgets : Sprite = new Sprite();
			layerDict[PopUpLayer.LAYER_WIDGETS] = layerWidgets;
			root.addChild(layerWidgets);
            
			var layerEffects : Sprite = new Sprite();
			layerEffects.mouseEnabled = false;
			layerDict[PopUpLayer.LAYER_EFFECTS] = layerEffects;
			root.addChild(layerEffects);
            
			modalMask = new Sprite();
			redrawModalMask();
			
			root.stage.addEventListener(Event.RESIZE, redrawModalMask);
		}
		
		public function addPopUp(popUp : DisplayObject, layer : String, modal : Boolean = false) : void
		{
			getLayer(layer).addChild(popUp);
            if(modal)
			{
               	attachModal(popUp);
			}
		}
        
		public function centerPopUp(popUp : DisplayObject) : void
		{
			if(!isPopUp(popUp)) return;
			
			popUp.x = (root.stage.stageWidth - popUp.width) / 2;
			popUp.y = (root.stage.stageHeight - popUp.height) / 2;
		}
        
		public function isPopUp(object : DisplayObject) : Boolean
		{
			if(object.parent == null) return false;
			
			for each(var layer : Sprite in layerDict)
			{
				if(object.parent == layer) return true;
			}
			
			return false;
		}
		
		public function isModal(popUp : DisplayObject) : Boolean
		{
			return modalQueue.indexOf(popUp) >= 0;
		}
		
		public function topPopUp(popUp : DisplayObject) : void
		{
			if(!isPopUp(popUp)) return;
			
			var layer : Sprite = Sprite(popUp.parent);
			layer.setChildIndex(popUp, layer.numChildren - 1);
			
			if(isModal(popUp))
			{
				sortModal();
				attachModal(popUp);
			}
		}
		
		public function removePopUp(popUp : DisplayObject) : void
		{
			if(!isPopUp(popUp)) return;
			
			dettachModal(popUp);
			
			var layer : Sprite = Sprite(popUp.parent);
			layer.removeChild(popUp);
		}
		
		public function attachModal(popUp : DisplayObject) : void
		{
			if(!isModal(popUp))
			{
				modalQueue.push(popUp);
				sortModal();
			}

			if(modalQueue.indexOf(popUp) == modalQueue.length - 1)
			{
				var layer : DisplayObjectContainer = popUp.parent;
	            var index : int = layer.getChildIndex(popUp);
				if(modalMask.parent == layer)
				{
	                if(layer.getChildIndex(modalMask) > index)
					{
						layer.setChildIndex(modalMask, index);
					}
					else
					{
						layer.setChildIndex(modalMask, index - 1);
					}
				}
				else
				{
					layer.addChildAt(modalMask, index);
				}
			}
		}
		
		public function dettachModal(popUp : DisplayObject) : void
		{
			var modalIndex : int = modalQueue.indexOf(popUp);
			if(modalIndex < 0) return;
			
			ArrayUtil.removeElements(modalQueue, popUp);

			var layer : DisplayObjectContainer = popUp.parent;
			if(modalIndex == modalQueue.length)
			{
				if(modalQueue.length > 0)
				{
					attachModal(modalQueue[modalQueue.length - 1]);
				}
				else
				{
					layer.removeChild(modalMask);
				}
			}
		}
		
		private function sortModal() : void
		{
			modalQueue.sort(comparePopUp);
		}
		
		private function comparePopUp(popUp1 : DisplayObject, popUp2 : DisplayObject) : int
		{
			var layer1 : DisplayObjectContainer = popUp1.parent;
			var layer2 : DisplayObjectContainer = popUp2.parent;
			
			if(layer1 != layer2)
			{
				return layer1.parent.getChildIndex(layer1) - layer2.parent.getChildIndex(layer2);
			}

			return layer1.getChildIndex(popUp1) - layer2.getChildIndex(popUp2);
		}
		
		private function getLayer(name : String) : Sprite
		{
			return layerDict[name];
		}
		
		private function redrawModalMask(event : Event = null) : void
		{
			const g : Graphics = modalMask.graphics;
			g.clear();
			if(modalMaskAlpha == 0)
			{
				g.beginBitmapFill(BitmapDataUtil.blank);
			}
			else
			{
				g.beginFill(modalMaskColor, modalMaskAlpha);
			}
			
			g.drawRect(0, 0, root.stage.stageWidth, root.stage.stageHeight);
			g.endFill();
		}
	}
}