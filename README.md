DMGesturedNavigationController
==============================

Beta: This is a very early release, refactors and more features, less bug too… are coming.

Feedbacks would be appreciated.

UINavigationController re-implementation the way Apple should have made it. 
Full gesture support for transition and navigation. With stack options and more

##Features
1. Support swipe gesture to navigation between child view controllers
2. Support both standard UINavigationController stack and a new one where you can navigate back and forth.
3. Full re-implementation of UINavigationController by subclassing UIViewController. 
4. Provide a protocol for you to know when your view controller are visible, active, etc…
5. Far more to come.


##How to use it

Add the files from **/classes** to your project, import `DMGesturedNavigationController` and you're done. 

It works like a UINavigationController, but it's not, it offer various other feature and powerful manipulation of the child view controller stack.

###Important

Take a look at the stackType property, it takes a `DMGesturedNavigationControllerStackType` option
By default it is set to the new `DMGesturedNavigationControllerStackNavigationFree`
`DMGesturedNavigationControllerStackNavigationFree`: Here the user can go back and forth between view controller (like it is actual pages of a book). 

When you go back from a view controller it won't be removed from the hierarchy. You will still be able to navigate to it. 

`DMGesturedNavigationControllerStackLikeNavigationController` work like a classic UINavigationController, if you go back, the previous view controller is removed from the hierarchy. 

###Classic

You'll find the usual suspect 


	- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated;
	- (void)popViewConrollerAnimated:(BOOL)animated;
	- (void)popToRootViewControllerAnimated:(BOOL)animated;
	- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;
	
Which act the same if you are in `DMGesturedNavigationControllerStackLikeNavigationController` mode

###New

To accomodate with the new navigation mode I've added a few other method


	- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
	removeInBetweenViewControllers:(BOOL)removeInBetweenVC;
	
This one is interesting, you can push a new UIViewController and navigate to it, if you set removeInBetweenVC to No, it will preserve view controller betweeen the new pushed one and the last visible one you navigate from. 
 
	- (void)inserViewController:(UIViewController *)viewController
              atStackOffset:(NSInteger)offset
                   animated:(BOOL)animated;
	- (void)removeViewController:(UIViewController *)viewControlller
                    animated:(BOOL)animated;
	- (void)navigateToViewController:(UIViewController *)viewController 
							animated:(BOOL)animated;
	- (BOOL)containViewController:(UIViewController *)viewController;
	
Those methods are documented. 
The new thing is that you can freely add or remove a VC in the stack and navigate to it. 

##Know issues
1. The navigation bar stack is bugged when animated if you do too much transitions simultaneously.
3. The bottom toolbar is not implemented.

##License
Copyright (C) 2012 by Thomas Ricouard.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.