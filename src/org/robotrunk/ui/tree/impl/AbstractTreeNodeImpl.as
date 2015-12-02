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

package org.robotrunk.ui.tree.impl {
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import mx.collections.ArrayCollection;

	import org.robotrunk.common.error.AbstractMethodInvocationException;
	import org.robotrunk.ui.tree.api.TreeNode;
	import org.robotrunk.ui.tree.event.TreeNodeEvent;

	public class AbstractTreeNodeImpl extends Sprite implements TreeNode {
		private var _data:*;
		private var _nodes:ArrayCollection;
		private var _level:int;
		private var _active:Boolean;
		private var _nodeHeight:Number = NaN;
		private var _selected:Boolean;
		private var _nodeWidth:Number;

		public function AbstractTreeNodeImpl( data:Object ) {
			_data = data;
		}

		public function get id():String {
			return _data.name;
		}

		public function get value():String {
			return _data.value;
		}

		public function open():void {
			throw new AbstractMethodInvocationException( "You must override the 'open()' method." );
		}

		public function close():void {
			throw new AbstractMethodInvocationException( "You must override the 'close()' method." );
		}

		public function add( node:TreeNode ):TreeNode {
			if( !holds( node ) ) {
				addChild( node as DisplayObject );
			}
			return node;
		}

		public function removeNode( node:TreeNode ):TreeNode {
			if( holds( node ) ) {
				removeChild( node as DisplayObject );
			}

			return node;
		}

		public function holds( node:TreeNode ):Boolean {
			return contains( node as DisplayObject );
		}

		public function destroy():void {
			_data = null;
			_nodes = null;
			_level = 0;
			_active = false;
		}

		public function isFolder():Boolean {
			return _nodes && _nodes.length>0;
		}

		public function get nodes():ArrayCollection {
			return _nodes;
		}

		public function set nodes( value:ArrayCollection ):void {
			_nodes = value;
			for each( var node:TreeNode in value ) {
				node.addEventListener( TreeNodeEvent.NODE_SELECTED, onChildNodeSelected, false, 0, true );
				node.addEventListener( TreeNodeEvent.NODE_DESELECTED, onChildNodeDeselected, false, 0, true );
				node.addEventListener( TreeNodeEvent.NODE_UPDATED, onChildNodeUpdated, false, 0, true );
				node.addEventListener( TreeNodeEvent.ACTIVE, onChildNodeActive, false, 0, true );
			}
		}

		private function onChildNodeSelected( ev:TreeNodeEvent ):void {
			ev.stopImmediatePropagation();
			dispatchEvent( new TreeNodeEvent( TreeNodeEvent.NODE_SELECTED, ev.selectedNode ) );
		}

		private function onChildNodeDeselected( ev:TreeNodeEvent ):void {
			ev.stopImmediatePropagation();
			dispatchEvent( new TreeNodeEvent( TreeNodeEvent.NODE_DESELECTED, ev.selectedNode ) );
		}

		private function onChildNodeUpdated( ev:TreeNodeEvent ):void {
			ev.stopImmediatePropagation();
			dispatchEvent( new TreeNodeEvent( TreeNodeEvent.NODE_UPDATED, ev.selectedNode ) );
		}

		private function onChildNodeActive( ev:TreeNodeEvent ):void {
			ev.stopImmediatePropagation();
			active = true;
		}

		public function get level():int {
			return _level;
		}

		public function set level( value:int ):void {
			_level = value;
		}

		public function get active():Boolean {
			return _active;
		}

		public function set active( active:Boolean ):void {
			_active = active;

			if( active ) {
				dispatchEvent( new TreeNodeEvent( TreeNodeEvent.ACTIVE ) );
			}

		}

		public function get data():* {
			return _data;
		}

		public function get subTreeHeight():Number {
			var subNodesHeight:Number = nodeHeight;
			for each ( var node:TreeNode in nodes ) {
				subNodesHeight += node.subTreeHeight;
			}
			return active ? subNodesHeight : nodeHeight;
		}

		public function get subTreeWidth():Number {
			var subNodesWidth:Number = nodeWidth;
			for each( var node:TreeNode in nodes ) {
				subNodesWidth = node.x+node.subTreeWidth>subNodesWidth ? node.x+node.subTreeWidth : subNodesWidth;
			}
			return active ? subNodesWidth : nodeWidth;
		}

		public function selectById( id:String ):void {
			if( this.id == id ) {
				select();
			} else {
				selected = false;
				for each( var node:TreeNode in nodes ) {
					node.selectById( id );
				}
			}
		}

		public function select():void {
			selected = true;
			dispatchEvent( new TreeNodeEvent( TreeNodeEvent.NODE_SELECTED, this ) );
		}

		public function deselect():void {
			selected = false;
			dispatchEvent( new TreeNodeEvent( TreeNodeEvent.NODE_DESELECTED, this ) );
		}

		public function get selected():Boolean {
			return _selected;
		}

		public function set selected( selected:Boolean ):void {
			_selected = selected;
		}

		public function pathContains( node:TreeNode ):Boolean {

			return matchesAncestor( this, node );
		}

		private function matchesAncestor( ancestor:DisplayObject, node:TreeNode ):Boolean {
			return ancestor == node ? true :
				   ancestor.parent != stage ? matchesAncestor( ancestor.parent, node ) : false;
		}

		public function get nodeHeight():Number {
			return _nodeHeight>0 ? _nodeHeight : height;
		}

		public function set nodeHeight( hei:Number ):void {
			_nodeHeight = hei;
		}

		public function get nodeWidth():Number {
			return _nodeWidth>0 ? _nodeWidth : width;
		}

		public function set nodeWidth( nodeWidth:Number ):void {
			_nodeWidth = nodeWidth;
		}
	}
}