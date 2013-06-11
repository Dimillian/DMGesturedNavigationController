//
//  DMGesturedNavigationController.m
//  DMGesturedNavigationController
//
//  Created by Thomas Ricouard on 04/05/13.
//  Copyright (c) 2013 Thomas Ricouard. All rights reserved.
//

#import "DMGesturedNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <objc/message.h>

static char kVisible;
static char kActive;

@interface UIViewController (UIViewControllerGesturedNavigationControllerPrivate)
@property (nonatomic, readwrite, getter = isVisible) BOOL visible;
@property (nonatomic, readwrite, getter = isActive) BOOL active;
@end

static const CGFloat kDefaultNavigationBarHeightPortrait = 60.0;

@interface DMGesturedNavigationController ()
{
    NSMutableArray *_internalViewControllers;
    NSInteger _previousPage;
    UIViewController *_tmpStackedViewController;
    UIViewController *_tmpPreviousViewController;
}

@property (nonatomic, readwrite, strong) UIViewController *visibleViewController;
@property (nonatomic, readwrite, strong) UIScrollView *containerScrollView;
@property (nonatomic, readwrite, strong) UINavigationBar *navigationBar;
@property (nonatomic) NSInteger currentPage;

- (void)reloadChildViewControllersTryToRebuildStack:(BOOL)rebuildStack;
- (void)rebuildNavBarStack;
- (void)pageChanged;
- (void)pushBack;
- (void)enableScrollToTop;
- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated;
- (void)pushExternalViewController:(UIViewController *)viewController
                           animted:(BOOL)animated
    removeInBetweeenViewController:(BOOL)removeInBetweeenVC;
- (UIViewController *)viewControllerForPage:(NSInteger)page;
- (NSInteger)pageForViewController:(UIViewController *)viewController;
- (NSInteger)currentOffset;
- (CGRect)rectForViewController:(UIViewController *)viewController;
- (NSArray *)viewControllers;
- (void)notifyVisiblesViewController;
@end

@implementation DMGesturedNavigationController
@dynamic viewControllers;
@dynamic allowSideBoucing;
@dynamic allowSwipeTransition;
@dynamic backgroundColor;

#pragma mark - Init stuff
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _internalViewControllers = [[NSMutableArray alloc]init];
        _navigationBarHidden = NO;
        _animatedNavbarChange = YES;
        _displayEdgeShadow = YES;
        _minimumScaleOnSwipe = 0.8f;
        _scalingWhenSwipe = NO;
        _maximumInclinaisonAngle = 10.0f;
        _rotateYAxisWhenSwipe = NO;
        _stackType = DMGesturedNavigationControllerStackNavigationFree;
        _popAnimationType = DMGesturedNavigationControllerPopAnimationNewWay;
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        [_internalViewControllers addObject:rootViewController];
    }
    return self;
}

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _internalViewControllers = [viewControllers mutableCopy];
    }
    return self;
}

#pragma mark - View stuff

- (void)loadView
{
    [super loadView];
    _containerScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,
                                                                         kDefaultNavigationBarHeightPortrait,
                                                                         self.view.frame.size.width,
                                                                         self.view.frame.size.height)];
    [self.containerScrollView setDelegate:self];
    [self.containerScrollView setPagingEnabled:YES];
    [self.containerScrollView setBackgroundColor:[UIColor clearColor]];
    [self.containerScrollView setShowsHorizontalScrollIndicator:NO];
    [self.containerScrollView setShowsVerticalScrollIndicator:YES];
    [self.containerScrollView setScrollsToTop:NO];
    [self.containerScrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|
     UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:self.containerScrollView];
    _navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kDefaultNavigationBarHeightPortrait)];
    [self.navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:self.navigationBar];
    _currentPage = 0;
    _previousPage = 0;

    UIViewController *controller = [_internalViewControllers objectAtIndex:_currentPage];
    [self.navigationBar pushNavigationItem:controller.navigationItem animated:self.isAnimatedNavbarChange];
    controller.active = YES;
    controller.visible = YES;
    if ([controller respondsToSelector:@selector(childViewControllerdidShow)]) {
        [controller performSelector:@selector(childViewControllerdidShow)];
    }
    if ([controller respondsToSelector:@selector(childViewControllerdidBecomeActive)]) {
        [controller performSelector:@selector(childViewControllerdidBecomeActive)];
    }
    [self setNavigationBarHidden:NO animated:NO];
    [self reloadChildViewControllersTryToRebuildStack:NO];
    [self addObserver:self forKeyPath:@"navigationBarHidden"
              options:NSKeyValueObservingOptionNew
              context:nil];
    [self addObserver:self forKeyPath:@"currentPage"
              options:NSKeyValueObservingOptionNew
              context:nil];
    [self enableScrollToTop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIViewController *controller = [_internalViewControllers objectAtIndex:_currentPage];
    if ([controller respondsToSelector:@selector(childViewControllerCouldProvideTitle)]){
        [controller performSelector:@selector(childViewControllerCouldProvideTitle)];
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"navigationBarHidden"],
    [self removeObserver:self forKeyPath:@"currentPage"];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"navigationBarHidden"] || [keyPath isEqualToString:@"hidden"]) {
        [self setNavigationBarHidden:[[self valueForKey:@"navigationBarHidden"]boolValue] animated:NO];
    }
    else if ([keyPath isEqualToString:@"currentPage"]){
        [self pageChanged];
    }
}


#pragma mark - intenral mess
- (void)reloadChildViewControllersTryToRebuildStack:(BOOL)rebuildStack
{
    for (UIViewController *viewController in _internalViewControllers) {
        [viewController willMoveToParentViewController:nil];
        [viewController removeFromParentViewController];
        [viewController.view removeFromSuperview];
        [viewController didMoveToParentViewController:nil];
    }
    for (UIViewController *viewController in _internalViewControllers) {
        NSInteger index = [_internalViewControllers indexOfObject:viewController];
        viewController.view.frame = CGRectMake(self.containerScrollView.frame.size.width * index,
                                               0,
                                               self.containerScrollView.frame.size.width,
                                               self.containerScrollView.frame.size.height);
        
        [self addChildViewController:viewController];
        [self.containerScrollView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
    }
    
    self.containerScrollView.contentSize = CGSizeMake(self.containerScrollView.frame.size.width * [_internalViewControllers count], 1);
    if (rebuildStack) {
        [self rebuildNavBarStack];
    }
    if (self.isDisplayEdgeShadow) {
        for (UIViewController *viewController in _internalViewControllers) {
            CGRect shadowFrame = viewController.view.layer.bounds;
            CALayer *layer = viewController.view.layer;
            layer.shadowOffset = CGSizeMake(0, 0);
            if ([_internalViewControllers indexOfObject:viewController] == 0) {
                layer.shadowOpacity = .5f;
                shadowFrame.origin.x -= 3.0;
            }
            else if ([_internalViewControllers indexOfObject:viewController] == _internalViewControllers.count - 1) {
                layer.shadowOpacity = .5f;
                shadowFrame.origin.x += 5.0;
            }
            else{
                layer.shadowOpacity = 0.0f;
            }
            layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
        }
    }
    else{
        for (UIViewController *viewController in _internalViewControllers) {
            CALayer *layer = viewController.view.layer;
            layer.shadowOpacity = 0.0f;
        }
    }
}

- (void)rebuildNavBarStack
{
    NSMutableArray *items = [[NSMutableArray alloc]init];
    for (UIViewController *controller in _internalViewControllers) {
        [controller.navigationItem setHidesBackButton:YES];
        [items addObject:controller.navigationItem];
        NSUInteger index = [_internalViewControllers indexOfObject:controller];
        if (index == _currentPage) {
            break;
        }
    }
    [self.navigationBar setItems:items animated:self.isAnimatedNavbarChange];
}

- (void)pageChanged
{
    UIViewController *current = [self visibleViewController];
    [current viewDidAppear:YES];
    UIViewController *previousInStack = current.previousViewController;
    _tmpPreviousViewController = [_internalViewControllers objectAtIndex:_previousPage];
    if ([_tmpPreviousViewController respondsToSelector:@selector(childViewControllerCouldBecomeInactive)]) {
        [_tmpPreviousViewController performSelector:@selector(childViewControllerCouldBecomeInactive)];
    }

    if ([current respondsToSelector:@selector(childViewControllerCouldBecomeActive)]) {
        [current performSelector:@selector(childViewControllerCouldBecomeActive)];
    }
    NSString *title = @"Back";
    if (previousInStack.title) {
        title = previousInStack.title;
    }
    if (self.currentPage != 0) {
        if ([current respondsToSelector:@selector(childViewControllerCouldProvideTitle)]){
            [current performSelector:@selector(childViewControllerCouldProvideTitle)];
        }
        UINavigationItem *newItem = current.navigationItem;
        if (current.navigationItem.leftBarButtonItem || current.navigationItem.leftBarButtonItems) {
            if (current.navigationItem.leftBarButtonItems.count > 0) {
                newItem.leftBarButtonItems = current.navigationItem.leftBarButtonItems;
            }
            else{
                newItem.leftBarButtonItem = current.navigationItem.leftBarButtonItem;
            }
        }
        else{
            [newItem setHidesBackButton:YES];
            UIBarButtonItem *item;
            if (_customBackButtonItem) {
                _customBackButtonItem.title = previousInStack.title;
                item = _customBackButtonItem;
            }
            else{
                item = [[UIBarButtonItem alloc]initWithTitle:title
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(pushBack)];
            }
            
            newItem.leftBarButtonItem = item;
        }
        if (self.currentPage < _previousPage) {
            [self.navigationBar popNavigationItemAnimated:self.isAnimatedNavbarChange];
            _tmpStackedViewController = [self viewControllerForPage:_previousPage];
        }
        else{
            _tmpStackedViewController = nil;
            [self.navigationBar pushNavigationItem:newItem animated:self.isAnimatedNavbarChange];
        }
    }
    else{
        if ([current respondsToSelector:@selector(childViewControllerCouldProvideTitle)]){
            [current performSelector:@selector(childViewControllerCouldProvideTitle)];
        }
        [self rebuildNavBarStack];
        _tmpStackedViewController = [self viewControllerForPage:_previousPage];
    }
    _previousPage = self.currentPage;
    [self enableScrollToTop];
}

- (void)enableScrollToTop
{
    for (UIViewController *viewController in self.viewControllers) {
        NSInteger index = [self.viewControllers indexOfObject:viewController];
        if (index != self.currentPage) {
            for (UIView *subview in [viewController.view subviews]) {
                if ([subview respondsToSelector:@selector(scrollsToTop)]) {
                    [(UIScrollView *)subview setScrollsToTop:NO];
                }
            }
        }
        else{
            for (UIView *subview in [viewController.view subviews]) {
                if ([subview respondsToSelector:@selector(scrollsToTop)]) {
                    [(UIScrollView *)subview setScrollsToTop:YES];
                }
            }
            
        }
    }
}

- (void)pushBack
{
    [self popViewControllerAnimated:YES];
}

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated
{
    [self.containerScrollView
     setContentOffset:CGPointMake(self.view.frame.size.width * page, 0.0f)
     animated:animated];
}


- (UIViewController *)viewControllerForPage:(NSInteger)page
{
    NSAssert([_internalViewControllers count] > page,
             @"Requested controller is out of bound");
    return [_internalViewControllers objectAtIndex:page];
}


- (NSInteger)pageForViewController:(UIViewController *)viewController
{
    NSAssert([_internalViewControllers containsObject:viewController],
             @"Passed view controller is not a child or in the hierarchy of DMGesturesNavigationController");
    return [_internalViewControllers indexOfObject:viewController];
}


#pragma mark - External view controller mess
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
removeInBetweenViewControllers:(BOOL)removeInBetweenVC
{
    [self pushExternalViewController:viewController
                             animted:animated
      removeInBetweeenViewController:removeInBetweenVC];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self pushExternalViewController:viewController
                             animted:animated
      removeInBetweeenViewController:YES];
}

- (void)pushExternalViewController:(UIViewController *)viewController
                           animted:(BOOL)animated
    removeInBetweeenViewController:(BOOL)removeInBetweeenVC
{
    if (removeInBetweeenVC) {
        for (NSInteger i = 0; i <= _internalViewControllers.count - 1; i++) {
            if (i > self.currentPage) {
                UIViewController *controller = [_internalViewControllers objectAtIndex:i];
                [controller willMoveToParentViewController:nil];
                [controller removeFromParentViewController];
                [controller.view removeFromSuperview];
                [_internalViewControllers removeObject:controller];
                [controller didMoveToParentViewController:nil];
                i--;   
            }
        }
    }
    [_internalViewControllers addObject:viewController];
    if (removeInBetweeenVC) {
        [self reloadChildViewControllersTryToRebuildStack:NO];   
    }
    else{
        [self reloadChildViewControllersTryToRebuildStack:YES];
    }
    [self scrollToPage:_internalViewControllers.count - 1 animated:animated];
}

- (void)inserViewController:(UIViewController *)viewController
              atStackOffset:(NSInteger)offset
                   animated:(BOOL)animated
{
    if (offset > _internalViewControllers.count - 1) {
        offset = 1;
    }
    [_internalViewControllers insertObject:viewController atIndex:offset];
    [self reloadChildViewControllersTryToRebuildStack:YES];
    [self scrollToPage:offset animated:animated];
}

- (void)removeViewController:(UIViewController *)viewControlller
                    animated:(BOOL)animated
{
    NSAssert([self containViewController:viewControlller],
             @"The passed view controller is not in the hierarchy");
    NSAssert([self pageForViewController:viewControlller] > 0,
             @"You cannot remove the root view controller");
    [viewControlller willMoveToParentViewController:nil];
    if (_currentPage == [self pageForViewController:viewControlller]) {
        [self scrollToPage:_currentPage - 1 animated:YES];
    }
    if (self.popAnimationType == DMGesturedNavigationControllerPopAnimationNewWay) {
        [UIView animateWithDuration:0.30 animations:^{
            CGAffineTransform xForm = viewControlller.view.transform;
            viewControlller.view.transform = CGAffineTransformScale(xForm, 0.50, 0.50);
        }completion:^(BOOL finished) {
            [viewControlller.view removeFromSuperview];
            [viewControlller removeFromParentViewController];
            [_internalViewControllers removeObject:viewControlller];
            [viewControlller didMoveToParentViewController:nil];
            [self reloadChildViewControllersTryToRebuildStack:NO];
        }];
    }
    else{
        [viewControlller.view removeFromSuperview];
        [viewControlller removeFromParentViewController];
        [_internalViewControllers removeObject:viewControlller];
        [viewControlller didMoveToParentViewController:nil];
        [self reloadChildViewControllersTryToRebuildStack:YES];
    }
   
}

- (void)popToRootViewControllerAnimated:(BOOL)animated
{
    [self scrollToPage:0 animated:animated];
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    if (self.stackType == DMGesturedNavigationControllerStackLikeNavigationController &&
        self.popAnimationType == DMGesturedNavigationControllerPopAnimationNewWay) {
        UIViewController *vcToRemove = [_internalViewControllers objectAtIndex:_currentPage];
        [self removeViewController:vcToRemove animated:YES];
    }
    else{
        if (_currentPage >= 1) {
            [self scrollToPage:self.currentPage - 1 animated:animated];
        }
    }
}

- (void)navigateToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSAssert([_internalViewControllers containsObject:viewController],
             @"Passed view controller is not a child or in the hierarchy of DMGesturesNavigationController");
    NSInteger page = [_internalViewControllers indexOfObject:viewController];
    [self scrollToPage:page animated:animated];
}

- (UIViewController *)visibleViewController
{
    return [_internalViewControllers objectAtIndex:self.currentPage];
}

- (UIViewController *)topViewController
{
    return [_internalViewControllers objectAtIndex:0];
}

- (BOOL)containViewController:(UIViewController *)viewController
{
    return [_internalViewControllers containsObject:viewController];
}
         
#pragma mark - getters & setters

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [self.containerScrollView setBackgroundColor:backgroundColor];
}

- (UIColor *)backgroundColor
{
    return self.containerScrollView.backgroundColor;
}

- (void)setDisplayEdgeShadow:(BOOL)displayEdgeShadow
{
    _displayEdgeShadow = displayEdgeShadow;
    [self reloadChildViewControllersTryToRebuildStack:NO];
}

- (BOOL)isAllowSideBoucing
{
    return [self.containerScrollView bounces];
}

- (void)setAllowSideBoucing:(BOOL)allowSideBoucing
{
    [self.containerScrollView setBounces:allowSideBoucing];
}

- (BOOL)isAllowSwipeTransition
{
    return [self.containerScrollView isScrollEnabled];
}

- (void)setAllowSwipeTransition:(BOOL)allowSwipeTransition
{
    [self.containerScrollView setScrollEnabled:allowSwipeTransition];
}

- (NSInteger)currentOffset
{
    CGFloat pageWidth = self.containerScrollView.frame.size.width;
    return floor((self.containerScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (CGRect)rectForViewController:(UIViewController *)viewController
{
    return viewController.view.frame;
}


- (NSArray *)viewControllers
{
    return [NSArray arrayWithArray:_internalViewControllers];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    _internalViewControllers = [NSArray arrayWithArray:viewControllers];
    _currentPage = 0;
    _previousPage = 0;
    [self reloadChildViewControllersTryToRebuildStack:YES];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated
{
    _navigationBarHidden = navigationBarHidden;
    CGRect scrollFrame = self.containerScrollView.frame;
    if (navigationBarHidden) {
      scrollFrame.origin.y = 0;
      scrollFrame.size.height = self.view.frame.size.height;
    }
    else{
      scrollFrame.origin.y = kDefaultNavigationBarHeightPortrait;
      scrollFrame.size.height = self.view.frame.size.height - kDefaultNavigationBarHeightPortrait;
    }
    for (UIViewController *viewController in _internalViewControllers) {
        CGRect vcFrame = viewController.view.frame;
        CGRect navFrame = self.navigationBar.frame;
        if (navigationBarHidden) {
            vcFrame.origin.y = 0;
            vcFrame.size.height = self.containerScrollView.frame.size.height;
            navFrame.origin.y = -kDefaultNavigationBarHeightPortrait;
        }
        else{
            vcFrame.origin.y = 0;
            vcFrame.size.height = self.containerScrollView.frame.size.height;
            navFrame.origin.y = 0;
        }
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^{
                [self.navigationBar setFrame:navFrame];
                [viewController.view setFrame:vcFrame];
            }];
        }
        else{
            [self.navigationBar setFrame:navFrame];
            [viewController.view setFrame:vcFrame];
            [self.navigationBar setHidden:navigationBarHidden];
        }
    }
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.containerScrollView setFrame:scrollFrame];
        }];
    }
    else{
        [self.containerScrollView setFrame:scrollFrame];
    }
}


- (void)setCustomBackButtonItem:(UIBarButtonItem *)customBackButtonItem
{
    _customBackButtonItem = customBackButtonItem;
    [self.customBackButtonItem setTarget:self];
    [self.customBackButtonItem setAction:@selector(pushBack)];
    if (self.currentPage != 0) {
        UIViewController *current = [self visibleViewController];
        UINavigationItem *items = current.navigationItem;
        items.leftBarButtonItem = self.customBackButtonItem;
    }
}

#pragma mark - ScrollView
- (void)notifyVisiblesViewController
{
    for (UIViewController *controller in _internalViewControllers) {
        BOOL intersect = CGRectIntersectsRect(self.containerScrollView.bounds, controller.view.frame);
        if (intersect) {
            if ([controller respondsToSelector:@selector(childViewControllerVisiblePartDidChange:)]) {
                CGRect visibleFrame = CGRectIntersection(self.containerScrollView.bounds,
                                                         controller.view.frame);
                [controller performSelector:@selector(childViewControllerVisiblePartDidChange:)
                                 withObject:[NSNumber numberWithFloat:visibleFrame.size.width]];
            }
            if (!controller.isVisible) {
                controller.visible = YES;
                if ([controller respondsToSelector:@selector(childViewControllerdidShow)]) {
                    [controller performSelector:@selector(childViewControllerdidShow)];
                }
            }
        }
        else{
            if (controller.isVisible) {
                if ([controller respondsToSelector:@selector(childViewControllerdidHide)]) {
                    [controller performSelector:@selector(childViewControllerdidHide)];
                }
            }
            controller.visible = NO;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self notifyVisiblesViewController];
    NSInteger newOffset = [self currentOffset];
    if (newOffset != _currentPage) {
        self.currentPage = newOffset;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    if (self.isScalingWhenSwipe || self.isRotateYAxisWhenSwipe) {
        CGFloat offset = scrollView.contentOffset.x;
        for (UIViewController *viewController in self.viewControllers) {
            NSUInteger index = [self.viewControllers indexOfObject:viewController];
            CGFloat width = scrollView.frame.size.width;
            CGFloat originXForVC = index * width;
            CGFloat value = (offset - originXForVC)/width;
            CATransform3D scaleTransform = CATransform3DIdentity;
            CATransform3D rotateTransform = CATransform3DIdentity;
            
            if (self.isScalingWhenSwipe) {
                CGFloat scale = 1.f - fabs(value);
                if (scale > 1.f) scale = 1.f;
                if (scale < self.minimumScaleOnSwipe) scale = self.minimumScaleOnSwipe;
                scaleTransform = CATransform3DMakeScale(scale, scale, 0);
            }
            if (self.isRotateYAxisWhenSwipe) {
                CGFloat dX = (offset+viewController.view.frame.size.width/2) - (originXForVC+width/2);
                CGFloat angle = (fabs(dX) / (width/2)) * self.maximumInclinaisonAngle;
                CATransform3D layerTransform = CATransform3DIdentity;
                layerTransform.m34 = -1.0f / 300; // perspective effect
                rotateTransform = CATransform3DRotate(layerTransform,
                                                      angle / (180.f/M_PI),
                                                      0,
                                                      value,
                                                      0);
            }
            [viewController.view.layer setTransform:CATransform3DConcat(scaleTransform, rotateTransform)];
        }
    }

    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.1];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.isScalingWhenSwipe || self.isRotateYAxisWhenSwipe) {
        for (UIViewController *viewController in self.viewControllers) {
            [viewController.view setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f)];
        }
    }
    UIViewController *current = [self visibleViewController];    
    if ([current respondsToSelector:@selector(childViewControllerdidBecomeActive)]) {
        [current performSelector:@selector(childViewControllerdidBecomeActive)];
        current.active = YES;
    }
    if ([_tmpPreviousViewController respondsToSelector:@selector(childViewControllerdidResignActive)]) {
        [_tmpPreviousViewController performSelector:@selector(childViewControllerdidResignActive)];
        _tmpPreviousViewController.active = NO;
    }
    
    if (_tmpStackedViewController &&
        self.stackType == DMGesturedNavigationControllerStackLikeNavigationController) {
        [_tmpStackedViewController willMoveToParentViewController:nil];
        [_tmpStackedViewController.view removeFromSuperview];
        [_internalViewControllers removeObject:_tmpStackedViewController];
        [_tmpStackedViewController didMoveToParentViewController:nil];
        _tmpStackedViewController = nil;
        [self reloadChildViewControllersTryToRebuildStack:YES];
    }

    [self rebuildNavBarStack];
    
}

#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self reloadChildViewControllersTryToRebuildStack:YES];
}


#pragma mark - Memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

#pragma mark - Categories implementations
@implementation UIViewController (UIViewControllerGesturedNavigationControllerPrivate)
@dynamic visible;
@dynamic active;

- (void)setVisible:(BOOL)visible
{
    objc_setAssociatedObject(self,
                             &kVisible,
                             [NSNumber numberWithBool:visible],
                             OBJC_ASSOCIATION_RETAIN);
}

- (void)setActive:(BOOL)active
{
    objc_setAssociatedObject(self,
                             &kVisible,
                             [NSNumber numberWithBool:active],
                             OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation UIViewController (UIViewControllerGesturedNavigationController)
@dynamic previousViewController;
@dynamic nextViewController;
@dynamic gesturedNavigationController;
@dynamic visible;
@dynamic active;
@dynamic gesturedNavigationControllerOffset;

- (BOOL)isVisible
{
    NSNumber *result = objc_getAssociatedObject(self, &kVisible);
    return result.boolValue;
}

- (BOOL)isActive
{
    NSNumber *result = objc_getAssociatedObject(self, &kActive);
    return result.boolValue;
}


- (DMGesturedNavigationController *)gesturedNavigationController
{
    
    if([self.parentViewController isKindOfClass:[DMGesturedNavigationController class]]){
        return (DMGesturedNavigationController*)self.parentViewController;
    }
    else if([self.parentViewController isKindOfClass:[UINavigationController class]] &&
            [self.parentViewController.parentViewController isKindOfClass:[DMGesturedNavigationController class]]){
        return (DMGesturedNavigationController*)[self.parentViewController parentViewController];
    }
    else{
        return nil;
    }

}

- (UIViewController *)previousViewController
{
    DMGesturedNavigationController *parent = self.gesturedNavigationController;
    NSInteger currentPage = [parent pageForViewController:self];
    if (currentPage != 0 && parent.viewControllers.count > 1) {
        return [parent viewControllerForPage:currentPage - 1];
    }
    return nil;
}

- (UIViewController *)nextViewController
{
    DMGesturedNavigationController *parent = self.gesturedNavigationController;
    NSInteger currentPage = [parent pageForViewController:self];
    if (parent.viewControllers.count > currentPage + 1) {
        return [parent viewControllerForPage:currentPage + 1];
    }
    return nil;
}

- (NSInteger)gesturedNavigationControllerOffset
{
    if ([self.gesturedNavigationController containViewController:self]) {
        return [self.gesturedNavigationController pageForViewController:self];
    }
    return 0;

}

- (void)pushViewControllerToSelf
{
    [self.gesturedNavigationController navigateToViewController:self animated:YES];
}

@end
