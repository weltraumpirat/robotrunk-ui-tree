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
	import flash.utils.Dictionary;

	import org.flexunit.assertThat;
	import org.hamcrest.object.instanceOf;
	import org.robotrunk.ui.core.StyleMap;
	import org.robotrunk.ui.tree.api.Tree;
	import org.robotrunk.ui.tree.factory.TreeFactory;
	import org.swiftsuspenders.Injector;

	public class TreeFactoryTest {
		private var factory:TreeFactory;
		private var tree:Tree;
		private var injector:Injector;

		[Before]
		public function setUp():void {
			injector = new Injector();
			injector.map( StyleMap, "default" ).toValue( new StyleMap() );
			factory = new TreeFactory();
		}

		[Test]
		public function createsATree():void {
			var params:Dictionary = new Dictionary( true );
			params.id = "tree";
			params.kind = "tree";
			params.style = "tree";
			params.states = "default";

			tree = factory.create( injector, params ) as Tree;

			assertThat( tree, instanceOf( Tree ) );
		}

		[After]
		public function tearDown():void {
			injector.teardown();
			injector = null;
			factory = null;
			tree.destroy();
			tree = null;
		}
	}
}