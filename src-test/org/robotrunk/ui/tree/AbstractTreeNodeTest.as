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
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.EventDispatcher;

	import mx.collections.ArrayCollection;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertNull;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;
	import org.robotrunk.common.error.AbstractMethodInvocationException;
	import org.robotrunk.ui.tree.api.TreeNode;
	import org.robotrunk.ui.tree.event.TreeNodeEvent;
	import org.robotrunk.ui.tree.impl.SimpleTreeNodeImpl;

	public class AbstractTreeNodeTest {
		private var node:TreeNode;

		[Before]
		public function setUp():void {
			node = createNode( "node1", "value1" );
			createChildNodes();
		}

		private function createChildNodes():void {
			var nodes:ArrayCollection = new ArrayCollection();
			nodes.addItem( createNode( "node2", "value2" ) );
			nodes.addItem( createNode( "node3", "value3" ) );
			nodes.addItem( createNode( "node4", "value4" ) );
			node.nodes = nodes;
		}

		protected function createNode( name:String, value:String ):TreeNode {
			throw new AbstractMethodInvocationException( "You must override the 'createNode()' method." );
		}

		[Test(async)]
		public function opensFolderOfChildNodes():void {
			Async.proceedOnEvent( this, node as EventDispatcher, TreeNodeEvent.NODE_OPEN, 1000 );

			assertFolderNotInitialized();
			node.open();
		}

		private function assertFolderNotInitialized():void {
			assertEquals( 3, node.nodes.length );
			assertEquals( 0, node.numChildren );
		}

		[Test(async)]
		public function dispatchesUpdatedEventWhenOpened():void {
			Async.proceedOnEvent( this, node as EventDispatcher, TreeNodeEvent.NODE_UPDATED, 1000 );
			node.open();
		}

		[Test(async)]
		public function closesFolderOfChildNodes():void {
			Async.proceedOnEvent( this, node as EventDispatcher, TreeNodeEvent.NODE_CLOSED, 1000 );
			node.open();
			node.close();
		}

		[Test(async)]
		public function dispatchesUpdatedEventWhenClosed():void {
			node.open();
			Async.proceedOnEvent( this, node as EventDispatcher, TreeNodeEvent.NODE_UPDATED, 1000 );
			node.close();
		}

		[Test]
		public function openFolderYieldsFullSubTreeHeight():void {
			node.active = true;
			node.open();
			assertEquals( 3, node.numChildren );
			assertEquals( 40, node.subTreeHeight );
		}

		[Test]
		public function openFolderYieldsGreatestNodeWidthForSubTreeWidth():void {
			node.active = true;
			node.open();
			assertEquals( 50, node.subTreeWidth );
			var g:Graphics = node.nodes.getItemAt( 0 ).graphics;
			g.beginFill( 0, 1 );
			g.drawRect( 0, 0, 100, 10 );
			assertEquals( 100, node.subTreeWidth );
		}

		[Test]
		public function openFoldersNodesHaveFullAlpha():void {
			node.open();
			for each( var nd:TreeNode in node.nodes ) {
				assertEquals( 1, nd.alpha );
			}
		}

		[Test]
		public function openFoldersNodesAreVisible():void {
			node.open();
			for each ( var nd:TreeNode in node.nodes ) {
				assertTrue( nd.visible );
			}
		}

		[Test]
		public function openFoldersNodesAreSpreadOutBelowEachOther():void {
			node.open();
			var position:Number = node.nodeHeight;
			for each( var nd:TreeNode in node.nodes ) {
				assertEquals( position, nd.y );
				position += nd.subTreeHeight;
			}
		}

		[Test(async)]
		public function openFoldersNodesAreAddedToTheDisplayList():void {
			for each ( var nd:TreeNode in node.nodes ) {
				assertFalse( node.contains( nd as DisplayObject ) );
			}

			node.open();
			for each ( nd in node.nodes ) {
				assertTrue( node.contains( nd as DisplayObject ) );
			}
		}

		[Test]
		public function inActiveNodeYieldsOnlyMasterNodeHeightForSubTreeHeight():void {
			node.active = false;
			assertEquals( 10, node.subTreeHeight );
		}

		[Test]
		public function inActiveNodeYieldsOnlyMasterNodeWidthForSubTreeWidth():void {
			node.active = false;
			assertEquals( 50, node.subTreeWidth );
		}

		[Test]
		public function closedFoldersNodesAreNotVisible():void {
			node.close();
			for each( var nd:TreeNode in node.nodes ) {
				assertFalse( nd.visible );
			}
		}

		[Test]
		public function closedFoldersNodesHaveZeroAlpha():void {
			node.close();
			for each( var nd:TreeNode in node.nodes ) {
				assertEquals( 0, nd.alpha );
			}
		}

		[Test]
		public function closedFoldersNodesAreAtPositionZero():void {
			node.active = false;
			for each( var nd:TreeNode in node.nodes ) {
				assertEquals( 0, nd.y );
			}
		}

		[Test]
		public function cleansUpNicely():void {
			node = new SimpleTreeNodeImpl( {} );
			node.nodes = new ArrayCollection();
			node.level = 1;
			node.active = true;

			node.destroy();

			assertNull( node.data );
			assertNull( node.nodes );
			assertEquals( 0, node.level );
			assertEquals( false, node.active );
		}

		[After]
		public function tearDown():void {
			node.destroy();
			node = null;
		}
	}
}