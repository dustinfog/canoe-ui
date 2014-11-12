package canoe.studio.editor.props
{
	import mx.core.IVisualElement;

	public interface IPropertyEditor extends IVisualElement
	{
		function set propName(v : String) : void
		function get propName() : String;
		function set value(v : *) : void;
		function get value() : *;
	}
}