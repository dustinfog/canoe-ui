package canoe.core
{
	import flash.display.Stage;
	import flash.events.IEventDispatcher;

	public interface IElement extends IEventDispatcher
	{
		/**
		 * 获取或设置变量名。 
		 * @param v
		 * 
		 */		
        function set id(v : String) : void;
		
		function get id() : String;
		/**
		 *  获取或设置x轴上的值。 
		 * @param v
		 * 
		 */		
		function set x(v : Number) : void;
		
		function get x():Number;
		/**
		 *   获取或设置y轴上的值。 
		 * @param v
		 * 
		 */		
		function set y(v : Number) : void;
		
		function get y() : Number;
		/**
		 *  获取或设置是否可见 
		 * @param v
		 * 
		 */		
		function set visible(v : Boolean) : void;
		
		function get visible() : Boolean;
		/**
		 * 获取或设置宽度 
		 * @param v
		 * 
		 */		
		function set width(v : Number) : void;
		
		function get width():Number;
		/**
		 * 获取设置高度 
		 * @param value
		 * 
		 */		
		function set height(value:Number):void;
		
		function get height():Number;
		/**
		 *  measuredHeight是由布局来赋值的，通过VLayout或HLayout赋值。
		 * @return 
		 * 
		 */		
		function get measuredHeight():Number;
		
		function set measuredHeight(value:Number):void;
		/**
		 *  measureWidth是由布局来赋值的，通过VLayout或HLayout赋值。
		 * @return 
		 * 
		 */		
		function get measuredWidth():Number;
		
		function set measuredWidth(value:Number):void;
		/**
		 *  获取或设置最低高度，displayObject对象的高度不能小于minHeight的值
		 * @return 
		 * 
		 */		
		function get minHeight():Number;
		
		function set minHeight(value:Number):void;
		/**
		 *   获取或设置最低宽度，displayObject对象的宽度不能小于minWidth的值
		 * @return 
		 * 
		 */		
		function get minWidth():Number;

		function set minWidth(value:Number):void;
		/**
		 *  获取或设置最大高度，displayObject对象的高度不能大于maxHeigh的值
		 * @return 
		 * 
		 */		
		function get maxHeight():Number;
		
		function set maxHeight(value:Number):void;
		/**
		 *  获取或设置最大宽度，displayObject对象的宽度不能大于maxWidth的值
		 * @return 
		 * 
		 */		
		function get maxWidth():Number;
		
		function set maxWidth(value:Number):void;
		/**
		 *  获取或设置离父级容器上部的距离
		 * @return 
		 * 
		 */		
		function get top():Number;
		
		function set top(value:Number):void;
		/**
		 *  获取或设置离父级容器右侧的距离
		 * @return 
		 * 
		 */		
		function get right():Number;
		
		function set right(value:Number):void;
		/**
		 *  获取或设置离父级容器左侧的距离
		 * @return 
		 * 
		 */		
		function get left():Number;
		
		function set left(value:Number):void;		
		/**
		 *   获取或设置离父级容器底部的距离
		 * @return 
		 * 
		 */		
		function get bottom():Number;
		
		function set bottom(value:Number):void;
		/**
		 *  获取或设置是否靠左
		 * @return 
		 * 
		 */		
		function get autoLeft() : Boolean;
		/**
		 *  获取或设置是否靠上 
		 * @return 
		 * 
		 */		
		function get autoTop() : Boolean;
		/**
		 *  获取或设置是否靠右 
		 * @return 
		 * 
		 */		
		function get autoRight() : Boolean;
		/**
		 * 获取或设置是否靠下 
		 * @return 
		 * 
		 */		
		function get autoBottom() : Boolean;

		/**
		 * 获取或设置纵向居中 
		 * @return 
		 * 
		 */		
		function get vCenter():Number;
		
		function set vCenter(value:Number):void;
		/**
		 * 获取或设置横向居中 
		 * @return 
		 * 
		 */		
		function get hCenter():Number;
		
		function set hCenter(value:Number):void;
		/**
		 *  获取或设置深度 
		 * @param value
		 * 
		 */		
		function set depth(value : int) : void;
		
		function get depth() : int;
		/**
		 *  获取舞台 
		 * @return 
		 * 
		 */		
		function get stage() : Stage;
		/**
		 *  获取或设置父级容器。owner是代替parent的，比如Window对象里有一个子元素，它的parent是Window的Skin的id为content的Container，但它的owner应该是Window，因为Window的细节被隐藏掉了
		 * @return 
		 * 
		 */        
		function get owner() : IContainer;
		
		function set owner(v : IContainer) : void;
		/**
		 * 父级文件。  比如做了一个界面MainView.cxml，那么在创建MainView的元素时，所有的元素的document都是MainView。
		 * @return 
		 * 
		 */        
		function get document() : Object;
		
		function set document(v : Object) : void;
		/**
		 *  获取或设置状态字符串数组 
		 * @param v
		 * 
		 */        
		function set states(v : Array) : void;
		
		function get states() : Array;
		/**
		 *   获取或设置当前的状态
		 * @param v
		 * 
		 */        
		function set currentState(v : String) : void;

        function get currentState() : String;
		/**
		 *  当您在项目呈示器或项目编辑器中使用某个组件时，可借助 data 属性向该组件传递值。
		 * @param v
		 * 
		 */		
		function set data(v : *) : void;
		
		function get data() : *;
		/**
		 *   注册数据绑定
		 * @param binding
		 * 
		 */		
		function registerBinding(binding:IBinding):void;
		/**
		 *  取消数据绑定 
		 * @param binding
		 * 
		 */		
		function unregisterBinding(binding:IBinding):void;
		/**
		 *  组件的属性 失效
		 * 
		 */		
		function invalidate() : void
		/**
		 *  组件的属性生效 
		 * 
		 */		
		function validate() : void;
	}
}