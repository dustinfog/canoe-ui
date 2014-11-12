package canoe.studio.editor
{
	import flash.display.NativeMenu;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	import mx.controls.TextArea;
	import mx.events.FlexMouseEvent;
	
	import spark.components.PopUpAnchor;
	import spark.components.PopUpPosition;
	
	import canoe.studio.library.LibraryManager;
	import canoe.studio.util.TextHistoryManager;
	import canoe.util.reflect.Access;
	import canoe.util.reflect.Accessor;
	import canoe.util.reflect.ClassReflector;
	import canoe.util.reflect.Member;
	import canoe.util.reflect.Variable;
	
	[Event(name="update", type="canoe.studio.editor.EditorEvent")]
	public class UICoder extends TextArea
	{
		
		public static const COLOR_CDATA : int = 0xFF9900;
		public static const COLOR_COMMENT : int = 0x009900;
		public static const COLOR_NODE : int = 0x007BF7;
		public static const COLOR_ATTR_NAME : int = 0xFF2F34;
		public static const COLOR_ATTR_VALUE : int = 0xEE6CD1;
		public static const COLOR_TEXT : int = 0xffffff;
		
		public static const TAG_TEXT : int = 1;
		public static const TAG_NODE : int = 2;
		public static const TAG_CDATA : int = 3;
		public static const TAG_COMMENT : int = 4;
		
		public static const POS_TAG_NAME : int = 1;
		public static const POS_ATTR_NAME : int = 2;
		public static const POS_ATTR_VALUE : int = 3;
		
		public static const CDATA_START : String = "<![CDATA[";
		public static const CDATA_END : String = "]]>";
		public static const COMMENT_START : String = "<!--";
		public static const COMMENT_END : String = "-->";
		
		/**
		 *  映射字符">"
		 **/
		public static const CHAR_CODE_GT : int = 62;
		/**
		 *  映射字符"<"
		 **/
		public static const CHAR_CODE_LT : int = 60;
		/**
		 *  映射字符"/"
		 **/
		public static const CHAR_CODE_SLASH : int = 47;
		/**
		 *  映射字符"="
		 **/
		public static const CHAR_CODE_EQUAL : int = 61;
		/**
		 *  映射字符"\""
		 **/
		public static const CHAR_CODE_QUOTE : int = 34;
		
		/**
		 *  映射字符"\t"
		 **/
		public static const CHAR_CODE_TAB : int = 9;
		
		/**
		 *  映射字符"\n"
		 **/
		public static const CHAR_CODE_NL : int = 10;
		
		/**
		 *  映射字符"\r"
		 **/
		public static const CHAR_CODE_RL : int = 13;
		
		/**
		 *  映射字符" "
		 **/
		public static const CHAR_CODE_SPACE : int = 32;
		
		private static const AT_KEYS : Array = ["()", "Array()", "Asset()", "Class()", "false", "true"];
		
		

		private var delayTimer : int;
		private var historyManager : TextHistoryManager;

		private var tipsCallingInput : String;
		private var tipsCallingCaretIndex : int = -1;
		private var autoCompletion : AutoCompletionList = new AutoCompletionList();
		private var popUpAnchor : PopUpAnchor;
		private var inputRL : Boolean;
		private var textChanged : Boolean;
		private var historyIsDirty : Boolean;
		private var libraryManager : LibraryManager = LibraryManager.instance;
		
		public function UICoder()
		{
			super();
			
			wordWrap = false;

			setStyle("fontFamily", "Courier New,simsun");
			setStyle("fontSize", 14);
			
			historyManager = new TextHistoryManager();
			historyManager.addEventListener("historyChanged", historyChangedHandler);
			
			addEventListener(Event.CHANGE, changeHandler);
			addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
		}
		
		private var _text : String;
		
		override public function set text(v : String) : void
		{
			setText(v, true);
		}
		
		private function setText(v : String, recordHistory : Boolean = false) : void
		{
			if(_text != v)
			{
				_text = v;
				textChanged = true;
				if(recordHistory)
				{
					historyIsDirty = true;
				}

				invalidateProperties();
			}
		}
		
		override public function get text() : String
		{
			return _text;
		}
		
		[Bindable(event="historyChanged")]
		public function get redoEnabled() : Boolean
		{
			return historyManager.redoEnabled; 
		}
		
		[Bindable(event="historyChanged")]
		public function get undoEnabled() : Boolean
		{
			return historyManager.undoEnabled; 
		}
		
		public function redo() : void
		{
			if(historyManager.redoEnabled)
			{
				var nextText : String = historyManager.forward();
				if(nextText !== null)
				{
					setText(nextText);
				}
			}
		}
		
		public function undo() : void
		{
			if(historyManager.undoEnabled)
			{
				var lastText : String = historyManager.backward();
				if(lastText !== null)
				{
					setText(lastText);
				}
			}
		}

		private function analyseAndColor() : void
		{
			var str : String = text;
			var textFormat : TextFormat = textField.defaultTextFormat;
			
			var tagType : int = TAG_TEXT, tagStart : int = 0;
			var posType : int, posStart : int;
			var nodeNameEndIndex : int, rootNodeText : String;
			var tipsClallingName : String = null;
			var unclosedTagNames : Array;

			for(var i : int = 0, length : int = str.length; i < length; i ++)
			{
				var charCode : int = str.charCodeAt(i);
				textFormat.bold = false;
				if(tagType != TAG_TEXT)
				{
					if(charCode == CHAR_CODE_GT)
					{
						switch(tagType)
						{
							case TAG_CDATA:
								if(str.substr(i - 2, 3) == CDATA_END)
								{
									textFormat.color = COLOR_CDATA;
									textField.setTextFormat(textFormat, tagStart, i + 1);
									
									tagType = TAG_TEXT;
									tagStart = i + 1;
								}
								break;
							case TAG_COMMENT:
								if(str.substr(i - 2, 3) == COMMENT_END) 
								{
									textFormat.color = COLOR_COMMENT;
									textField.setTextFormat(textFormat, tagStart, i + 1);
									
									tagType = TAG_TEXT;
									tagStart = i + 1;
								}
								break;
							case TAG_NODE:
								textFormat.color = COLOR_NODE;
								
								if(posType == POS_TAG_NAME)
								{
									textField.setTextFormat(textFormat, posStart, i);
									nodeNameEndIndex = i;
								}

								if(str.charCodeAt(i - 1) == CHAR_CODE_SLASH)
								{
									textField.setTextFormat(textFormat, i - 1, i + 1);
								}
								else
								{
									textField.setTextFormat(textFormat, i, i + 1);
									
									if(tipsCallingCaretIndex > i && tipsCallingInput == "<")
									{
										var currTagName : String = text.substring(tagStart + 1, nodeNameEndIndex);
										if(currTagName.charCodeAt(0) != CHAR_CODE_SLASH)
										{
											if(unclosedTagNames == null)
											{
												unclosedTagNames = [currTagName];
											}
											else
											{
												unclosedTagNames.push(currTagName);
											}
										}
										else if(unclosedTagNames != null)
										{
											unclosedTagNames.pop();
										}
									}
								}
								
								if(rootNodeText == null)
								{
									rootNodeText = text.substring(tagStart, i + 1);
								}
								
								posType = -1;
								posStart = -1;
								tagType = TAG_TEXT;
								tagStart = i + 1;
								break;
						}
					}
					else if(tagType == TAG_NODE)
					{
						if(posType == POS_TAG_NAME)
						{
							if(isWhitespace(charCode))
							{
								textFormat.color = COLOR_NODE;
								textField.setTextFormat(textFormat, posStart, i);
								
								nodeNameEndIndex = i;
								posType = POS_ATTR_NAME;
								posStart = -1;
							}
						}
						else if(posType == POS_ATTR_NAME)
						{
							if(posStart == -1)
							{
								if(!isWhitespace(charCode))
								{
									posStart = i;
								}
							}
							else if(charCode == CHAR_CODE_EQUAL)
							{
								textFormat.color = COLOR_ATTR_NAME;
								textField.setTextFormat(textFormat, posStart, i);
								
								textFormat.color = COLOR_NODE;
								textField.setTextFormat(textFormat, i, i + 1);
								
								posType = POS_ATTR_VALUE;
								posStart = -1;
							}
						}
						else if(posType == POS_ATTR_VALUE)
						{
							if(posStart == -1)
							{
								if(charCode == CHAR_CODE_QUOTE)
								{
									posStart = i;
								}
							}
							else if(charCode == CHAR_CODE_QUOTE)
							{
								textFormat.color = COLOR_ATTR_VALUE;
								textFormat.bold = true;
								textField.setTextFormat(textFormat, posStart, i + 1);
								
								posType = POS_ATTR_NAME;
								posStart = -1;
							}
						}
						
						if(tipsCallingCaretIndex == i)
						{
							if(posType == POS_TAG_NAME && tipsCallingInput == ":")
							{
								tipsClallingName = text.substring(tagStart + 1, i);
							}
							else if(posType == POS_ATTR_NAME && tipsCallingInput == " ")
							{
								tipsClallingName = text.substring(tagStart + 1, nodeNameEndIndex);
							}
							else if(posType == POS_ATTR_VALUE && tipsCallingInput == "@")
							{
								tipsClallingName = tipsCallingInput;
							}
						}
					}
				}
				else if(charCode == CHAR_CODE_LT)
				{
					if(i != tagStart)
					{
						textFormat.color = COLOR_TEXT;
						textField.setTextFormat(textFormat, tagStart, i);
					}
					
					if(str.substr(i, 4) == COMMENT_START)
					{
						tagType = TAG_COMMENT;
					}
					else if(str.substr(i, 9) == CDATA_START)
					{
						tagType = TAG_CDATA;
					}
					else
					{
						tagType = TAG_NODE;

						posType = POS_TAG_NAME;
						posStart = i;
					}
					
					tagStart = i;
					
					if(tipsCallingCaretIndex == i)
					{
						tipsClallingName = tipsCallingInput;
					}
				}
			}
			
			switch(tagType)
			{
				case TAG_CDATA:
					textFormat.color = COLOR_CDATA;
					textField.setTextFormat(textFormat, tagStart, i);
					break;
				case TAG_COMMENT:
					textFormat.color = COLOR_COMMENT;
					textField.setTextFormat(textFormat, tagStart, i);
					break;
				case TAG_NODE:
					if(posType == POS_TAG_NAME)
					{
						textFormat.color = COLOR_NODE;
						textField.setTextFormat(textFormat, posStart, i);
					}
					else if(posType == POS_ATTR_NAME)
					{
						textFormat.color = COLOR_ATTR_NAME;
						textField.setTextFormat(textFormat, posStart, i);
					}
					else if(posType == POS_ATTR_VALUE)
					{
						textFormat.color = COLOR_ATTR_VALUE;
						textFormat.bold = true;
						textField.setTextFormat(textFormat, posStart, i);
					}
					break;
				default:
					if(i != tagStart)
					{
						textFormat.color = COLOR_TEXT;
						textField.setTextFormat(textFormat, tagStart, i);
					}
			}
			
			if(tipsClallingName != null)
			{
				readyAutoCompletion(tipsClallingName, rootNodeText, unclosedTagNames);
			}
			else
			{
				tipsCallingCaretIndex = -1;
				tipsCallingInput = null;
			}
		}
		
		protected function autoCompletion_clickHandler(event:MouseEvent):void
		{
			if(autoCompletion.isItemRendererClicked(event))
			{
				applyAutoCompletion();
			}
		}
		
		private function readyAutoCompletion(tipsClallingName : String, rootNodeText : String, unclosedTagNames : Array) : void
		{
			var namespaceDict : Object = {};
			if(rootNodeText)
			{
				var regExp : RegExp = /xmlns:([^=]+)="([^"]+)"/g;
				var result : Array;
				while(result = regExp.exec(rootNodeText))
				{
					namespaceDict[result[1]] = result[2];
				}
			}
			
			var ns : String, attrs : Array, reflector : ClassReflector, member : Member;
			if(tipsCallingInput == ":")
			{
				ns = namespaceDict[tipsClallingName];
				
				var classNames : Array = libraryManager.getClassNames(ns);
				if(classNames.length > 0)
				{
					classNames.sort();
					showAutoCompletion(classNames);
				}
			}
			else if(tipsCallingInput == " ")
			{
				reflector = reflectNodeName(tipsClallingName, namespaceDict);
				if(reflector)
				{
					attrs = [];
					for each(member in reflector.members)
					{
						if(member is Variable || (member is Accessor
							&& (Accessor(member).access == Access.READWRITE || Accessor(member).access == Access.WRITEONLY))
						)
						{
							attrs.push(member.name);
						}
					}
					attrs.sort();
					showAutoCompletion(attrs);
				}
			}
			else if(tipsCallingInput == "<")
			{
				var compList : Array = [];
				var nses : Array = [];
				for(ns in namespaceDict)
				{
					nses.push(ns + ":");
				}
				
				nses.sort();
				
				attrs = [];
				if(unclosedTagNames != null && unclosedTagNames.length > 0)
				{
					var unclosed : String = unclosedTagNames[unclosedTagNames.length - 1];
					compList.push("/" + unclosed + ">");
					
					reflector = reflectNodeName(unclosed, namespaceDict);
					if(reflector)
					{
						for each(member in reflector.members)
						{
							if(member is Accessor
								&& (Accessor(member).access == Access.READWRITE || Accessor(member).access == Access.WRITEONLY)
							)
							{
								attrs.push(member.name);
							}
						}
						attrs.sort();
					}
				}
				
				compList = compList.concat(nses, attrs);
				compList.push("!--");

				showAutoCompletion(compList);
			}
			else if(tipsCallingInput == "@")
			{
				showAutoCompletion(AT_KEYS);
			}
		}
		
		private function showAutoCompletion(source : Array) : void
		{
			autoCompletion.source = source;
			
			var rect : Rectangle = textField.getCharBoundaries(tipsCallingCaretIndex);
			popUpAnchor.x = rect.right - textField.scrollH;
			popUpAnchor.y = rect.y;
			popUpAnchor.width = rect.width;
			popUpAnchor.height = rect.height;

			autoCompletion.selectedIndex = 0;
			autoCompletion.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, stopAutoCompletion);
			autoCompletion.addEventListener(MouseEvent.CLICK, autoCompletion_clickHandler);
			
			popUpAnchor.displayPopUp = true;
		}
		
		private function applyAutoCompletion() : void
		{
			var changed : Boolean, insertText : String, newCaretIndex : int;
			if(autoCompletion.selectedItem)
			{
				if(tipsCallingInput == " ")
				{
					insertText = autoCompletion.selectedItem + "=\"\"";
					newCaretIndex = tipsCallingCaretIndex + insertText.length;
				}
				else
				{
					insertText = autoCompletion.selectedItem;
					if(insertText == "!--")
					{
						newCaretIndex = tipsCallingCaretIndex + 4;
						insertText = "!---->";
					}
					else
					{
						var bracketIndex : int = insertText.indexOf("(");
						if(bracketIndex >= 0)
						{
							newCaretIndex = tipsCallingCaretIndex + bracketIndex + 2;
						}
						else
						{
							newCaretIndex = tipsCallingCaretIndex + insertText.length + 1;
						}
					}
				}
				
				textField.replaceText(tipsCallingCaretIndex + 1, tipsCallingCaretIndex + 1 + (autoCompletion.prefix ? autoCompletion.prefix.length : 0), insertText);
				textField.setSelection(newCaretIndex, newCaretIndex);
				
				changed = true;
			}
			
			stopAutoCompletion();

			if(changed)
			{
				if(insertText.charAt(insertText.length - 1) == ":")
				{
					tipsCallingInput = ":";
					tipsCallingCaretIndex = newCaretIndex - 1;
				}
				
				textField.dispatchEvent(new Event(Event.CHANGE, true));	
			}
		}
		
		private function stopAutoCompletion(event : Event = null) : void
		{
			popUpAnchor.displayPopUp = false;
			autoCompletion.removeEventListener(MouseEvent.CLICK, autoCompletion_clickHandler);
			autoCompletion.removeEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, stopAutoCompletion);
			clearTipsCalling();
		}
		
		private function clearTipsCalling() : void
		{
			tipsCallingInput = null;
			tipsCallingCaretIndex = -1;
		}
		
		private function reflectNodeName(nodeName : String, namespaceDict : Object) : ClassReflector
		{
			var colonIndex : int = nodeName.indexOf(":");
			
			var className : String;
			if(colonIndex > 0)
			{
				var nsName : String = nodeName.substring(0, colonIndex); 
				var ns : String = namespaceDict[nsName];
				className = ns + nodeName.substr(colonIndex);
			}
			else
			{
				className = nodeName;
			}
			
			try
			{
				var clazz : Class = Class(getDefinitionByName(className.replace(":", ".")));
				return ClassReflector.reflect(clazz, true);
			}
			catch(e : Error)
			{
			}
			
			return null;
		}
		
		private function isWhitespace(charCode:int):Boolean
		{
			switch (charCode)
			{
				case 9: //"\t"
				case CHAR_CODE_NL:
				case 12: //"\f"
				case CHAR_CODE_RL:
				case CHAR_CODE_SPACE:
					return true;
				default:
					return false;
			}
		}
		
		private function historyChangedHandler(event : Event) : void
		{
			updateHistoryMenu();
			dispatchEvent(event);
		}
		
		private function updateHistoryMenu() : void
		{
			var menu:NativeMenu = TextField(textField).contextMenu;
			if (menu) {
				ContextMenuItem(menu.getItemAt(0)).enabled = undoEnabled;
				ContextMenuItem(menu.getItemAt(1)).enabled = redoEnabled;
			}
		}
		
		private function addHistoryMenu():void
		{
			var undoItem:ContextMenuItem = new ContextMenuItem('撤销', false, false, true);
			undoItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(event:Event):void
			{
				undo();
			});
			var redoItem:ContextMenuItem = new ContextMenuItem('重做', false, false, true);
			redoItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, function(event:Event):void
			{
				redo();
			});
			
			var menu:NativeMenu = TextField(textField).contextMenu;
			if (menu == null) {
				menu = new ContextMenu();
				TextField(textField).contextMenu = menu;
			}
			menu.addItem(undoItem);
			menu.addItem(redoItem);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			addHistoryMenu();
			
			popUpAnchor = new PopUpAnchor();
			popUpAnchor.popUpPosition = PopUpPosition.BELOW;
			popUpAnchor.popUp = autoCompletion;
			addChildAt(popUpAnchor, 0);
		}
		
		protected function textInputHandler(event:TextEvent):void
		{
			if(event.text == " " || event.text == ":" || event.text == "<" || event.text == "@") //# @
			{
				tipsCallingInput = event.text;
				tipsCallingCaretIndex = textField.caretIndex;
			}
			else
			{
				if(event.text == "\n" || event.text == "\r")
				{
					inputRL = true;
				}
				
				if(!autoCompletion.isPopUp)
				{
					clearTipsCalling();	
				}
			}
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			super.keyDownHandler(event);
			
			if(autoCompletion.isPopUp)
			{
				if(event.keyCode == Keyboard.UP)
				{
					if(autoCompletion.selectedIndex > 0)
					{
						autoCompletion.selectedIndex --;
					}
					else
					{
						autoCompletion.selectedIndex = autoCompletion.length - 1;
					}
					
					event.preventDefault();
				}
				else if(event.keyCode == Keyboard.DOWN)
				{
					if(autoCompletion.selectedIndex < autoCompletion.length - 1)
					{
						autoCompletion.selectedIndex ++;
					}
					else
					{
						autoCompletion.selectedIndex = 0;
					}
					event.preventDefault();
				}
				else if(event.keyCode == Keyboard.ENTER)
				{
					applyAutoCompletion();
					event.preventDefault();
				}
				else if(event.keyCode == Keyboard.ESCAPE)
				{
					stopAutoCompletion();
					event.preventDefault();
				}
			}
			else
			{
				supportTab(event);
			}
		}
		
		private function supportTab(event : KeyboardEvent) : void
		{
			if(event.keyCode != Keyboard.TAB) return;
			
			var selectionBeginIndex : int = textField.selectionBeginIndex,
				selectionEndIndex : int = textField.selectionEndIndex,
				currentText : String = text,
				beforeCounter : int = 0,
				afterCounter : int = 0,
				searchIndex : int; 
			
			if(!event.shiftKey)
			{
				var selectedText : String = TextField(textField).selectedText;
				if(selectedText.length == 0 || (selectedText.indexOf("\r") < 0 && selectedText.indexOf("\n") < 0))
				{
					textField.replaceText(selectionBeginIndex, selectionEndIndex, "\t");
					beforeCounter = 1;
					afterCounter = - selectedText.length;
				}
				else
				{
					for(searchIndex = selectionEndIndex -1; searchIndex >= -1; searchIndex --)
					{
						if(searchIndex == -1 || currentText.charCodeAt(searchIndex) == CHAR_CODE_NL || currentText.charCodeAt(searchIndex) == CHAR_CODE_RL)
						{
							var insertIndex : int = searchIndex + 1;
							textField.replaceText(insertIndex, insertIndex, "\t");
							currentText = textField.text;
							
							if(searchIndex >= selectionBeginIndex)
								afterCounter ++;
							else
								beforeCounter ++;
							
							if(searchIndex <= selectionBeginIndex)
								break;
						};
					}
				}
			}
			else
			{
				for(searchIndex = selectionEndIndex - 1; searchIndex >= -1; searchIndex --)
				{
					if(searchIndex == -1 || currentText.charCodeAt(searchIndex) == CHAR_CODE_NL || currentText.charCodeAt(searchIndex) == CHAR_CODE_RL)
					{
						if(currentText.charCodeAt(searchIndex + 1) == CHAR_CODE_TAB)
						{
							textField.replaceText(searchIndex + 1, searchIndex + 2, "");
							currentText = textField.text;
							
							if(searchIndex >= selectionBeginIndex)
								afterCounter --;
							else
								beforeCounter --;
						}
						
						if(searchIndex <= selectionBeginIndex)
							break;
					};
				}
			}
			
			if(beforeCounter != 0 || afterCounter != 0)
			{
				textField.setSelection(selectionBeginIndex + beforeCounter, selectionEndIndex + afterCounter + beforeCounter);
				textField.dispatchEvent(new Event(Event.CHANGE, true));
			}
			
			event.preventDefault();
		}
		
		protected function changeHandler(event:Event = null):void
		{
			if(inputRL)
			{
				//处理简单的自动缩进
				var line : int = textField.getLineIndexOfChar(textField.caretIndex);
				if(line > 0)
				{
					var lastLineText : String = textField.getLineText(line - 1);
					var indentation : Array = [];
					
					for(var i : int = 0; i < lastLineText.length; i ++)
					{
						var charCode : int = lastLineText.charCodeAt(i);
						if(charCode != CHAR_CODE_SPACE && charCode != CHAR_CODE_TAB)
							break;
						
						indentation.push(charCode);
					}
					
					textField.replaceText(textField.caretIndex, textField.caretIndex, String.fromCharCode.apply(String, indentation));
					
					var newCaretIndex : int = textField.caretIndex + indentation.length;
					textField.setSelection(newCaretIndex, newCaretIndex);
				}
				
				inputRL = false;
			}
			
			_text = textField.text;

			if(autoCompletion.isPopUp)
			{
				if(textField.caretIndex > tipsCallingCaretIndex)
				{
					autoCompletion.prefix = text.substring(tipsCallingCaretIndex + 1, textField.caretIndex);
					
					if(autoCompletion.length > 0)
					{
						autoCompletion.selectedIndex = 0;
					}
					else
					{
						stopAutoCompletion();
					}
				}
				else
				{
					stopAutoCompletion();
				}
			}
			else
			{
				delayHighLightXML();
			}
			
			historyManager.record(_text);

			dispatchEvent(new EditorEvent(EditorEvent.UPDATE));
			event.stopPropagation();
		}
		
		public function find() : void
		{
			
		}
		
		private function delayHighLightXML() : void
		{
			clearTimeout(delayTimer);
			delayTimer = setTimeout(analyseAndColor, 200);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(textChanged)
			{
				commitText();
				dispatchEvent(new EditorEvent(EditorEvent.UPDATE));
				delayHighLightXML();
				
				if(historyIsDirty)
				{
					historyManager.clear();
					historyManager.record(text);
					historyIsDirty = false;
				}
				textChanged = false;
			}
		}
		
		private function commitText() : void
		{
			var lastText : String = textField.text;

			var lastLength : int = lastText.length;
			var currLength : int = text.length;
			
			var beginIndex : int = beginIndex = Math.min(lastLength, currLength);
			var indexChanged : Boolean;
			
			var lastChar : int, newChar : int;
			for(var i : uint = 0; i < beginIndex; i ++)
			{
				lastChar = lastText.charCodeAt(i);
				newChar = text.charCodeAt(i);
				if(lastChar != newChar && ((lastChar != CHAR_CODE_NL && lastChar != CHAR_CODE_RL) || (newChar != CHAR_CODE_NL && newChar != CHAR_CODE_RL)))
				{
					beginIndex = i;
					indexChanged = true;
					break;
				}
			}
			
			var lastEndIndex : int, currEndIndex : int;
			
			if(!indexChanged)
			{
				lastEndIndex = lastLength;
				currEndIndex = currLength;
			}
			else
			{
				indexChanged = false;
				var rBeginIndex : int = Math.min(lastLength - beginIndex, currLength - beginIndex); 
				
				for(i = 0; i < rBeginIndex; i ++)
				{
					var lastIndex : int = lastLength - i - 1;
					var currIndex : int = currLength - i - 1;
					
					lastChar = lastText.charCodeAt(lastIndex);
					newChar = text.charCodeAt(currIndex);
					if(lastChar != newChar && ((lastChar != CHAR_CODE_NL && lastChar != CHAR_CODE_RL) || (newChar != CHAR_CODE_NL && newChar != CHAR_CODE_RL)))
					{
						lastEndIndex = lastIndex + 1;
						currEndIndex = currIndex + 1;
						indexChanged = true;
						break;
					}
				}
				
				if(!indexChanged)
				{
					lastEndIndex = lastLength - rBeginIndex;
					currEndIndex = currLength - rBeginIndex;
				}
			}

			textField.replaceText(beginIndex, lastEndIndex, text.substring(beginIndex, currEndIndex).replace(/\r/g, "\n"));
			textField.setSelection(currEndIndex, currEndIndex);
			_text = textField.text;
		}
	}
}
