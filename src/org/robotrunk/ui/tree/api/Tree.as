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
	import mx.collections.ArrayCollection;

	import org.robotrunk.ui.core.api.UIComponent;
	import org.robotrunk.ui.tree.impl.TreeNodeRenderer;

	public interface Tree extends UIComponent {
		function get dataProvider():*;

		function set dataProvider( dataProvider:* ):void;

		function get structure():XML;

		function set structure( structure:XML ):void;

		function get nodes():ArrayCollection;

		function get rootNode():TreeNode;

		function set rootNode( node:TreeNode ):void;

		function render():void;

		function addRenderer( identifier:String, renderer:TreeNodeRenderer ):void;

		function selectNodeById( id:String ):void;

		function get selectedNode():TreeNode;
	}
}
