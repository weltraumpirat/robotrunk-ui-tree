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
	import flash.utils.Dictionary;

	import mx.collections.ArrayCollection;

	import org.robotrunk.common.error.IllegalOperationException;
	import org.robotrunk.ui.core.Position;
	import org.robotrunk.ui.core.Style;
	import org.robotrunk.ui.core.event.ViewEvent;
	import org.robotrunk.ui.tree.api.Tree;
	import org.robotrunk.ui.tree.api.TreeNode;
	import org.robotrunk.ui.tree.event.TreeEvent;
	import org.robotrunk.ui.tree.event.TreeNodeEvent;

	public class TreeImpl extends Sprite implements Tree {
		private var _states:Dictionary = new Dictionary( true );
		private var _style:Style;
		private var _dataProvider:*;
		private var _structure:XML;
		private var _nodes:ArrayCollection;
		private var _renderers:Dictionary = new Dictionary( true );
		private var _rootNode:TreeNode;

		public function TreeImpl() {
			addRenderer( "default", new TreeNodeRenderer( SimpleTreeNodeImpl ) );
		}

		public function addRenderer( identifier:String, renderer:TreeNodeRenderer ):void {
			_renderers[identifier] = renderer;
		}

		public function render():void {
			dispatchEvent( new ViewEvent( ViewEvent.RENDER ) );

			_nodes = new ArrayCollection();
			createTree();

			dispatchEvent( new ViewEvent( ViewEvent.RENDER_COMPLETE ) );
		}

		private function createTree():void {
			_rootNode = createNode( {name: "root", value: "root", level: 0}, "default" );
			_rootNode.nodes = createChildNodesFromNestedElements( _structure.elements(), _dataProvider, 1 );
			addChild( _rootNode as DisplayObject );
			_rootNode.addEventListener( TreeNodeEvent.NODE_UPDATED, onNodeUpdated );
			_rootNode.addEventListener( TreeNodeEvent.NODE_SELECTED, onNodeSelected );
			_rootNode.addEventListener( TreeNodeEvent.NODE_DESELECTED, onNodeDeselected );
			_rootNode.active = true;
			_rootNode.open();
		}

		private function onNodeSelected( ev:TreeNodeEvent ):void {
			var selectedNode:TreeNode = ev.selectedNode;
			updateNodesInPath( selectedNode );
			dispatchEvent( new TreeEvent( TreeEvent.NODE_SELECTED, selectedNode ) );
		}

		private function onNodeDeselected( ev:TreeNodeEvent ):void {
			var selectedNode:TreeNode = ev.selectedNode["parent"];
			updateNodesInPath( selectedNode );
			dispatchEvent( new TreeEvent( TreeEvent.NODE_DESELECTED, ev.selectedNode ) );
		}

		private function updateNodesInPath( selectedNode:TreeNode ):void {
			for each( var node:TreeNode in _nodes ) {
				updateNodeProperties( node, selectedNode );
			}

			for each( node in _nodes ) {
				animateNode( node );
			}
			_rootNode.open();
		}

		private function updateNodeProperties( node:TreeNode, selectedNode:TreeNode ):void {
			node.active = selectedNode.pathContains( node );
			node.selected = node == selectedNode;
		}

		private function animateNode( node:TreeNode ):void {
			if( node.active ) {
				node.open();
			} else {
				node.close();
			}
		}

		private function createChildNodesFromNestedElements( searchList:XMLList, parentNode:*, level:int ):ArrayCollection {
			var childNodes:ArrayCollection = new ArrayCollection();
			for each( var nestedElement:XML in searchList ) {
				childNodes.addAll( tryToCreateChildNodesFromNestedElement( parentNode, nestedElement, level ) );
			}
			return childNodes.length>0 ? childNodes : null;
		}

		private function tryToCreateChildNodesFromNestedElement( parentNode:*, searchNode:XML, level:int ):ArrayCollection {
			var childNodes:ArrayCollection = new ArrayCollection();
			try {
				childNodes.addAll( createChildNodes( parentNode, searchNode, level ) );
			} catch( ignore:Error ) {
				trace( "An error occurred while rendering tree:"+ignore.message );
			}
			return childNodes;
		}

		private function createChildNodes( parentNode:*, searchNode:XML, level:int ):ArrayCollection {
			var childNodes:ArrayCollection = new ArrayCollection();
			for each( var item:* in parentNode[searchNode.name()] ) {
				childNodes.addItem( initNode( item, level, searchNode ) );
			}
			return childNodes;
		}

		private function initNode( item:*, level:int, searchNode:XML ):TreeNode {
			var type:String = getNodeType( searchNode.@type, item.type );
			var childNode:TreeNode = createNode( item, type );
			childNode.level = level;
			_nodes.addItem( childNode );
			childNode.nodes = createChildNodesFromNestedElements( searchNode.elements(), item, level+1 );
			return childNode;
		}

		private function onNodeUpdated( ev:TreeNodeEvent ):void {
			ev.stopImmediatePropagation();
			dispatchEvent( new TreeEvent( TreeEvent.UPDATED, ev.target as TreeNode ) );
		}

		private function getNodeType( nodeType:String, itemType:String ):String {
			var isNodeTyped:Boolean = nodeType != null && nodeType != "";
			var isItemTyped:Boolean = itemType != null && itemType != "";
			return isNodeTyped ? nodeType : isItemTyped ? itemType : "default";
		}

		private function createNode( item:*, type:String ):TreeNode {
			return _renderers[type].render( item );
		}

		public function selectNodeById( id:String ):void {
			for each ( var node:TreeNode in nodes ) {
				node.selectById( id );
			}
		}

		public function destroy():void {
			while( numChildren>0 ) {
				removeChildAt( 0 );
			}
			_states = null;
			_style = null;
			_dataProvider = null;
			_structure = null;
			_nodes = null;
			for( var key:String in _renderers ) {
				delete _renderers[key];
			}
			_renderers = null;
		}

		public function get selectedNode():TreeNode {
			var node:TreeNode = findSelectedNode( rootNode );
			return node ? node : rootNode;
		}

		private function findSelectedNode( node:TreeNode ):TreeNode {
			return node.selected ? node : findSelectedChildNode( node.nodes );
		}

		private function findSelectedChildNode( nodes:ArrayCollection ):TreeNode {
			for each( var node:TreeNode in nodes ) {
				var childNode:TreeNode = findSelectedNode( node );
				if( childNode ) {
					return childNode;
				}
			}
			return null;
		}

		public function get style():Style {
			return _style;
		}

		public function set style( style:Style ):void {
			_style = style;
		}

		public function get dataProvider():* {
			return _dataProvider;
		}

		public function set dataProvider( dataProvider:* ):void {
			_dataProvider = dataProvider;
		}

		public function get structure():XML {
			return _structure;
		}

		public function set structure( structure:XML ):void {
			_structure = structure;
		}

		public function get states():Dictionary {
			return _states;
		}

		public function set states( states:Dictionary ):void {
			_states = states;
		}

		public function get currentState():String {
			return "default";
		}

		public function set currentState( currentState:String ):void {
			throw new IllegalOperationException( "Tree does not allow switching states; its only state is 'default'." );
		}

		public function get position():Position {
			return null;
		}

		public function set position( position:Position ):void {
			throw new IllegalOperationException( "Due to its dynamic nature, tree does not accept automated positioning." );
		}

		public function get nodes():ArrayCollection {
			return _nodes;
		}

		public function get renderers():Dictionary {
			return _renderers;
		}

		public function get rootNode():TreeNode {
			return _rootNode;
		}

		public function set rootNode( rootNode:TreeNode ):void {
			_rootNode = rootNode;
		}

		public function applyToStyles( property:String, value:* ):void {

		}

		override public function get width():Number {
			return _rootNode.subTreeWidth;
		}

		override public function get height():Number {
			return _rootNode.subTreeHeight;
		}
	}
}
