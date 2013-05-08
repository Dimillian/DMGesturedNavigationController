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

I provide an example and the header is documented. I'll add more here later.

##Know issues
1. The navigation bar stack is bugged when animated if you do too much transitions simultaneously.
2. pushViewController have an undefined behavior when a new VC is pushed when you're not on the last page.
3. The bottom toolbar is missing at the moment. 

##License
Copyright (C) 2012 by Thomas Ricouard.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.