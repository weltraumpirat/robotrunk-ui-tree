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

package org.robotrunk.ui.tree.conf {
	import flash.utils.getQualifiedClassName;

	import org.robotrunk.ui.core.conf.UIComponentProvider;
	import org.robotrunk.ui.tree.api.Tree;
	import org.robotrunk.ui.tree.factory.TreeFactory;
	import org.robotrunk.ui.tree.impl.TreeImpl;
	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.IExtension;

	public class TreeExtension implements IExtension {
		[Inject]
		public var injector:Injector;

		[Inject]
		public var commandMap:IEventCommandMap;

		[Inject]
		public var viewMap:IMediatorMap;

		public function extend( context:IContext ):void {
			context.injector.injectInto( this );

			var treeProvider:UIComponentProvider = new UIComponentProvider( new TreeFactory() );
			injector.map( UIComponentProvider, getQualifiedClassName( TreeImpl ) ).toValue( treeProvider );
			injector.map( Tree ).toProvider( treeProvider );
		}
	}
}
