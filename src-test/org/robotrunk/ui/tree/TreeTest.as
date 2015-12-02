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

package org.robotrunk.ui.tree {
	import mx.collections.ArrayCollection;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.instanceOf;
	import org.robotrunk.ui.core.Position;
	import org.robotrunk.ui.core.Style;
	import org.robotrunk.ui.core.event.ViewEvent;
	import org.robotrunk.ui.tree.api.Tree;
	import org.robotrunk.ui.tree.api.TreeNode;
	import org.robotrunk.ui.tree.event.TreeEvent;
	import org.robotrunk.ui.tree.impl.AbstractTreeNodeImpl;
	import org.robotrunk.ui.tree.impl.TreeImpl;
	import org.robotrunk.ui.tree.impl.TreeNodeRenderer;

	public class TreeTest {
		private var tree:Tree;

		[Before]
		public function setUp():void {
			tree = new TreeImpl();
		}

		[Test]
		public function acceptsAnyObjectAsDataProvider():void {
			var data:Object = {};
			tree.dataProvider = data;
			assertEquals( data, tree.dataProvider );
		}

		[Test]
		public function structureIsProvidedAsXML():void {
			var structure:XML = <tree>
				<nodes/>
			</tree>;
			tree.structure = structure;
			assertEquals( structure, tree.structure );
		}

		[Test(async)]
		public function rendersASingleNode():void {
			assertNull( tree.nodes );
			var data:* = {};
			data.nodes = new ArrayCollection();
			data.nodes.addItem( {name: "nodeId", value: "nodeValue"} );
			tree.dataProvider = data;
			tree.structure = <tree>
				<nodes />
			</tree>;
			tree.addEventListener( ViewEvent.RENDER_COMPLETE,
								   Async.asyncHandler( this, onSingleNodeRenderComplete, 500 ) );
			tree.render();
		}

		private function onSingleNodeRenderComplete( ev:ViewEvent, ...rest ):void {
			assertEquals( 1, tree.nodes.length );
			assertNodeCorrect( tree.nodes.getItemAt( 0 ) as TreeNode, "nodeId", "nodeValue" );
		}

		[Test(async)]
		public function rendersMultipleNodes():void {
			assertNull( tree.nodes );
			var data:* = {};
			data.nodes = new ArrayCollection();
			data.nodes.addItem( {name: "node1", value: "nodeValue1"} );
			data.nodes.addItem( {name: "node2", value: "nodeValue2"} );
			tree.dataProvider = data;
			tree.structure = <tree>
				<nodes />
			</tree>;
			tree.addEventListener( ViewEvent.RENDER_COMPLETE,
								   Async.asyncHandler( this, onMultipleNodeRenderComplete, 500 ) );
			tree.render();
		}

		private function onMultipleNodeRenderComplete( ev:ViewEvent, ...rest ):void {
			assertEquals( 2, tree.nodes.length );
			assertNodeCorrect( tree.nodes.getItemAt( 0 ) as TreeNode, "node1", "nodeValue1" );
			assertNodeCorrect( tree.nodes.getItemAt( 1 ) as TreeNode, "node2", "nodeValue2" );
		}

		private function assertNodeCorrect( node:TreeNode, name:String, value:String ):void {
			assertThat( node, instanceOf( AbstractTreeNodeImpl ) );
			assertEquals( name, node.id );
			assertEquals( value, node.value );
		}

		[Test(async)]
		public function rendersHierarchicalNodesWithDifferentTypesProvidedByStructure():void {
			createHierarchicalStructure();
			tree.addEventListener( ViewEvent.RENDER_COMPLETE,
								   Async.asyncHandler( this, onHierarchicalNodeRenderComplete, 500 ) );
			tree.render();
		}

		private function createHierarchicalStructure():void {
			assertNull( tree.nodes );

			tree.dataProvider = createHierarchicalNodes();
			tree.structure =
			<tree>
				<nodes type="test1">
					<subnodes type="test2" />
				</nodes>
			</tree>;
			tree.addRenderer( "test1", new TreeNodeRenderer( Test1TreeNodeImpl ) );
			tree.addRenderer( "test2", new TreeNodeRenderer( Test2TreeNodeImpl ) );
		}

		private function onHierarchicalNodeRenderComplete( ev:ViewEvent, ...rest ):void {
			assertEquals( 3, tree.nodes.length );
			assertNodeCorrect( tree.nodes.getItemAt( 0 ) as TreeNode, "node1", "nodeValue1" );
			assertNodeCorrect( tree.nodes.getItemAt( 1 ) as TreeNode, "node2", "nodeValue2" );
			assertNodeCorrect( tree.nodes.getItemAt( 2 ) as TreeNode, "node3", "nodeValue3" );
			assertThat( tree.nodes.getItemAt( 0 ), instanceOf( Test1TreeNodeImpl ) );
			assertThat( tree.nodes.getItemAt( 1 ), instanceOf( Test2TreeNodeImpl ) );
			assertThat( tree.nodes.getItemAt( 2 ), instanceOf( Test1TreeNodeImpl ) );
		}

		private function createHierarchicalNodes():* {
			var data:* = {};
			data.nodes = new ArrayCollection();
			var item1:* = {name: "node1", value: "nodeValue1"};
			item1.subnodes = new ArrayCollection();
			item1.subnodes.addItem( {name: "node2", value: "nodeValue2"} );
			data.nodes.addItem( item1 );
			data.nodes.addItem( {name: "node3", value: "nodeValue3"} );
			return data;
		}

		[Test(async)]
		public function rendersHierarchicalNodesWithDifferentTypesProvidedByData():void {
			createHierarchicalStructureWithTypesInData();
			tree.addEventListener( ViewEvent.RENDER_COMPLETE,
								   Async.asyncHandler( this, onHierarchicalNodeRenderComplete, 500 ) );
			tree.render();
		}

		private function createHierarchicalStructureWithTypesInData():void {
			assertNull( tree.nodes );

			tree.dataProvider = createHierarchicalNodesWithTypes();
			tree.structure = <tree>
				<nodes>
					<subnodes/>
				</nodes>
			</tree>;
			tree.addRenderer( "test1", new TreeNodeRenderer( Test1TreeNodeImpl ) );
			tree.addRenderer( "test2", new TreeNodeRenderer( Test2TreeNodeImpl ) );
		}

		private function createHierarchicalNodesWithTypes():* {
			var data:* = createHierarchicalNodes();
			data.nodes.getItemAt( 0 ).type = "test1";
			data.nodes.getItemAt( 0 ).subnodes.getItemAt( 0 ).type = "test2";
			data.nodes.getItemAt( 1 ).type = "test1";

			return data;
		}

		[Test(async)]
		public function selectsSubNodeById():void {
			createHierarchicalStructure();
			tree.render();
			tree.addEventListener( TreeEvent.NODE_SELECTED, Async.asyncHandler( this, onNodeSelected, 500 ) );
			tree.selectNodeById( "node2" );
		}

		private function onNodeSelected( ev:TreeEvent, ...rest ):void {
			verifySelection( tree.nodes, ev.selectedNode );
		}

		private function verifySelection( nodesToCheck:ArrayCollection, selectedNode:TreeNode ):void {
			for each( var node:TreeNode in nodesToCheck ) {
				if( node == selectedNode ) {
					assertTrue( node.selected, node.active );
				} else {
					assertFalse( node.selected );
					verifySelection( node.nodes, selectedNode );
				}
			}
		}

		[Test]
		public function keepsTrackOfCurrentlySelectedNode():void {
			createHierarchicalStructure();
			tree.render();
			tree.selectNodeById( "node2" );
			assertEquals( "node2", tree.selectedNode.id )
		}

		[Test(async)]
		public function selectionActivatesAllAncestors():void {
			createHierarchicalStructure();
			tree.render();
			tree.addEventListener( TreeEvent.NODE_SELECTED,
								   Async.asyncHandler( this, onNodeSelectedActivatesAncestors, 500 ) );
			tree.selectNodeById( "node2" );
		}

		private function onNodeSelectedActivatesAncestors( ev:TreeEvent, ...rest ):void {
			for each( var node:TreeNode in tree.nodes ) {
				if( node.id == "node1" || node.id == "node2" ) {
					assertTrue( node.active );
				} else {
					assertFalse( node.active );
				}
			}

		}

		[Test(async)]
		public function selectionDeactivatesAllOthers():void {
			createHierarchicalStructure();
			tree.render();
			tree.selectNodeById( "node2" );
			tree.addEventListener( TreeEvent.NODE_SELECTED,
								   Async.asyncHandler( this, onNodeSelectedDeactivatesOthers, 500 ) );
			tree.selectNodeById( "node3" );
		}

		private function onNodeSelectedDeactivatesOthers( ev:TreeEvent, ...rest ):void {
			for each( var node:TreeNode in tree.nodes ) {
				if( node.id == "node1" || node.id == "node2" ) {
					assertFalse( node.active );
				} else {
					assertTrue( node.active );
				}
			}

		}

		[Test]
		public function holdsAStyle():void {
			var style:Style = new Style();
			tree.style = style;
			assertEquals( style, tree.style );
		}

		[Test(expects="org.robotrunk.common.error.IllegalOperationException")]
		public function allowsOnlyDefaultState():void {
			assertEquals( "default", tree.currentState );
			tree.currentState = "somethingElse";
		}

		[Test(expects="org.robotrunk.common.error.IllegalOperationException")]
		public function doesNotAllowAutomaticPositioning():void {
			assertNull( tree.position );
			tree.position = new Position();
		}

		[Test]
		public function cleansUpNicely():void {
			tree.dataProvider = {};
			tree.style = new Style();
			tree.structure = new XML();
			tree.destroy();
			assertNull( tree.dataProvider );
			assertNull( tree.states );
			assertNull( tree.structure );
			assertNull( tree.style );
			assertNull( tree["renderers"] );
		}

		[After]
		public function tearDown():void {
			tree.destroy();
			tree = null;
		}
	}
}

import org.robotrunk.ui.tree.impl.AbstractTreeNodeImpl;

internal class Test1TreeNodeImpl extends AbstractTreeNodeImpl {
	public function Test1TreeNodeImpl( data:* ) {
		super( data );

	}

	override public function open():void {
	}

	override public function close():void {
	}
}

internal class Test2TreeNodeImpl extends AbstractTreeNodeImpl {
	public function Test2TreeNodeImpl( data:* ) {
		super( data );
	}

	override public function open():void {
	}

	override public function close():void {
	}
}