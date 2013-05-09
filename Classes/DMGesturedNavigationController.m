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

const CGFloat kDefaultNavigationBarHeightPortrait = 44.0;

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

#pragma mark - Init stuff
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _internalViewControllers = [[NSMutableArray alloc]init];
        _navigationBarHidden = NO;
        _animatedNavbarChange = YES;
        _stackType = DMGesturedNavigationControllerStackNavigationFree;
        _popAnimationType = DMGesturedNavigationControllerPopAnimationNewWay;
        // Custom initialization
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
    _containerScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.containerScrollView setDelegate:self];
    [self.containerScrollView setPagingEnabled:YES];
    [self.containerScrollView setBackgroundColor:[UIColor clearColor]];
    [self.containerScrollView setShowsHorizontalScrollIndicator:NO];
    [self.containerScrollView setShowsVerticalScrollIndicator:YES];
    [self.view addSubview:self.containerScrollView];
    _navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kDefaultNavigationBarHeightPortrait)];
    [self.view addSubview:self.navigationBar];
    [self reloadChildViewControllersTryToRebuildStack:YES];
    _currentPage = 0;
    _previousPage = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [self removeObserver:self forKeyPath:@"navigationBarHidden"],
    [self removeObserver:self forKeyPath:@"currentPage"];
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addObserver:self forKeyPath:@"navigationBarHidden"
              options:NSKeyValueObservingOptionNew
              context:nil];
    [self addObserver:self forKeyPath:@"currentPage"
              options:NSKeyValueObservingOptionNew
              context:nil];
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
        CGFloat oY = kDefaultNavigationBarHeightPortrait;
        if (self.isNavigatioNBarHidden) {
            oY = 0;
        }
        viewController.view.frame = CGRectMake(self.containerScrollView.frame.size.width * index,
                                               oY,
                                               self.containerScrollView.frame.size.width,
                                               self.containerScrollView.frame.size.height);
        
        [self addChildViewController:viewController];
        [self.containerScrollView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
    }
    self.containerScrollView.contentSize = CGSizeMake(self.containerScrollView.frame.size.width * [_internalViewControllers count], 1);
    if (rebuildStack) {
        UINavigationItem *item = [self.navigationBar.items lastObject];
        UIViewController *current = [_internalViewControllers objectAtIndex:_currentPage];
        if ([item isEqual:current.navigationItem]) {
            [self rebuildNavBarStack];
        }
    }
}

- (void)rebuildNavBarStack
{
    NSMutableArray *items = [[NSMutableArray alloc]initWithCapacity:_internalViewControllers.count];
    for (UIViewController *controller in _internalViewControllers) {
        [controller.navigationItem setHidesBackButton:YES];
        [items addObject:controller.navigationItem];
    }
    [self.navigationBar setItems:[[items reverseObjectEnumerator]allObjects] animated:self.isAnimatedNavbarChange];
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
        UINavigationItem *newItem = current.navigationItem;
        if (current.navigationItem.leftBarButtonItem) {
            newItem.leftBarButtonItem = current.navigationItem.leftBarButtonItem;
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
        [self rebuildNavBarStack];
        _tmpStackedViewController = [self viewControllerForPage:_previousPage];
    }
    _previousPage = self.currentPage;
}

- (void)pushBack
{
    [self popViewConrollerAnimated:YES];
}

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated
{
    [self setAnimatedNavbarChange:animated];
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
    [self reloadChildViewControllersTryToRebuildStack:NO];
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

- (void)popViewConrollerAnimated:(BOOL)animated
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
    for (UIViewController *viewController in _internalViewControllers) {
        CGRect vcFrame = viewController.view.frame;
        CGRect navFrame = self.navigationBar.frame;
        if (navigationBarHidden) {
            vcFrame.origin.y = 0;
            navFrame.origin.y = -kDefaultNavigationBarHeightPortrait;
        }
        else{
            vcFrame.origin.y = kDefaultNavigationBarHeightPortrait;
            navFrame.origin.y = 0;
        }
        if (animated) {
            [UIView animateWithDuration:0.2 animations:^{
                [self.navigationBar setFrame:navFrame];
                [viewController.view setFrame:vcFrame];
            }completion:^(BOOL finished) {
                [self.navigationBar setHidden:navigationBarHidden];
            }];
        }
        else{
            [self.navigationBar setFrame:navFrame];
            [viewController.view setFrame:vcFrame];
            [self.navigationBar setHidden:navigationBarHidden];
        }
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
    [self performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:nil afterDelay:0.1];

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
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
        [self reloadChildViewControllersTryToRebuildStack:NO];
    }
    
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
@dynamic stackOffset;

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

- (NSInteger)stackOffset
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
