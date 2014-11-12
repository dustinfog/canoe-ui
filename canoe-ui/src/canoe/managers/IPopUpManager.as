package canoe.managers
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public interface IPopUpManager
	{
		function get modalMaskAlpha():Number;
		function set modalMaskAlpha(value:Number):void;
		function get modalMaskColor():uint;
		function set modalMaskColor(value:uint):void;
		function initialize(root : Sprite) : void;
		function addPopUp(popUp : DisplayObject, layer : String, modal : Boolean = false) : void;
		function centerPopUp(popUp : DisplayObject) : void;
		function isPopUp(object : DisplayObject) : Boolean;
		function isModal(popUp : DisplayObject) : Boolean;
		function topPopUp(popUp : DisplayObject) : void;
		function removePopUp(popUp : DisplayObject) : void;
		function attachModal(popUp : DisplayObject) : void;
		function dettachModal(popUp : DisplayObject) : void;
	}
}