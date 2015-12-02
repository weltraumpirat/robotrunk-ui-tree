/*
 * Copyright (c) 2012 Tobias Goeschel.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package org.robotrunk.ui.tree.api {
	import flash.events.IEventDispatcher;

	import mx.collections.ArrayCollection;

	import org.robotrunk.ui.core.api.GraphicalElement;

	[Event(type="org.robotrunk.ui.tree.event.TreeNodeEvent", name="NODE_SELECTED")]
	[Event(type="org.robotrunk.ui.tree.event.TreeNodeEvent", name="NODE_OPEN")]
	[Event(type="org.robotrunk.ui.tree.event.TreeNodeEvent", name="NODE_CLOSED")]
	public interface TreeNode extends GraphicalElement, IEventDispatcher {

		function open():void;

		function close():void;

		function isFolder():Boolean;

		function get active():Boolean;

		function set active( active:Boolean ):void;

		function get id():String;

		function get value():String;

		function get level():int;

		function set level( level:int ):void;

		function get nodes():ArrayCollection;

		function set nodes( nodes:ArrayCollection ):void;

		function add( node:TreeNode ):TreeNode;

		function removeNode( node:TreeNode ):TreeNode;

		function holds( node:TreeNode ):Boolean;

		function destroy():void;

		function get data():*;

		function get nodeHeight():Number;

		function get subTreeHeight():Number;

		function get subTreeWidth():Number;

		function get selected():Boolean;

		function set selected( selected:Boolean ):void;

		function select():void;

		function deselect():void;

		function selectById( id:String ):void;

		function pathContains( node:TreeNode ):Boolean;

	}
}
