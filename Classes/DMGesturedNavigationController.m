//
//  DMGesturedNavigationController.m
//  DMGesturedNavigationController
//
//  Created by Thomas Ricouard on 04/05/13.
//  Copyright (c) 2013 Thomas Ricouard. All rights reserved.
//

#import "DMGesturedNavigationController.h"

@interface DMGesturedNavigationController ()
{
    NSMutableArray *_internalViewControllers;
}

@property (nonatomic, readwrite, strong) NSArray *_viewControllers;
@property (nonatomic, readwrite, strong) UIViewController *visibleViewController;
@property (nonatomic, strong) UIScrollView *containerScrollView;
@end

@implementation DMGesturedNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _internalViewControllers = [[NSMutableArray alloc]init];
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
        _internalViewControllers =
        [_internalViewControllers initWithArray:viewControllers];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    _containerScrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    [self.containerScrollView setDelegate:self];
    [self.view addSubview:self.containerScrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
         
#pragma mark - getter
- (UIViewController *)visibleViewController
{
    return nil;
}

- (NSArray *)viewControllers
{
    return [NSArray arrayWithArray:_internalViewControllers];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
