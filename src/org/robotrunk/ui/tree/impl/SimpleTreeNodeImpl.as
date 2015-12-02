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
	import org.robotrunk.ui.tree.api.TreeNode;
	import org.robotrunk.ui.tree.event.TreeNodeEvent;

	public class SimpleTreeNodeImpl extends AbstractTreeNodeImpl implements TreeNode {

		public function SimpleTreeNodeImpl( data:Object ) {
			super( data );
		}

		override public function open():void {
			initializeNodeHeightAndWidth();
			var position:Number = nodeHeight;
			for each( var node:TreeNode in nodes ) {
				node.visible = true;
				node.alpha = 1;
				node.y = position;
				position += node.subTreeHeight;
				add( node );
			}
			dispatchEvent( new TreeNodeEvent( TreeNodeEvent.NODE_OPEN ) );
			node.dispatchEvent( new TreeNodeEvent( TreeNodeEvent.NODE_UPDATED ) );
		}

		private function initializeNodeHeightAndWidth():void {
			nodeHeight = nodeHeight;
			nodeWidth = nodeWidth;
		}

		override public function close():void {
			for each( var node:TreeNode in nodes ) {
				node.alpha = 0;
				node.visible = false;
			}

			dispatchEvent( new TreeNodeEvent( TreeNodeEvent.NODE_CLOSED ) );
			node.dispatchEvent( new TreeNodeEvent( TreeNodeEvent.NODE_UPDATED ) );
		}
	}
}