//
//  ViewController.m
//  DMGesturedNavigationController
//
//  Created by Thomas Ricouard on 04/05/13.
//  Copyright (c) 2013 Thomas Ricouard. All rights reserved.
//

#import "ViewController.h"
#import "WithinNavigationViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onBarbuttonItem)];
    self.navigationItem.rightBarButtonItem = item;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)onBarbuttonItem
{
   [self.gesturedNavigationController.parentViewController dismissViewControllerAnimated:YES completion:^{
       
   }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)childViewControllerdidBecomeActive
{
    NSLog(@"View Controller %d: Became active", [self gesturedNavigationControllerOffset]);
}

- (void)childViewControllerdidResignActive
{
    NSLog(@"View Controller %d: Resigned active", [self gesturedNavigationControllerOffset]);
}

- (void)childViewControllerdidShow
{
    NSLog(@"View Controller %d: Did show", [self gesturedNavigationControllerOffset]);
        self.title = [NSString stringWithFormat:@"VC: %d", [self gesturedNavigationControllerOffset]];
}

- (void)childViewControllerdidHide
{
    NSLog(@"View Controller %d: Became active", [self gesturedNavigationControllerOffset]);
}

- (void)childViewControllerCouldBecomeActive
{
      NSLog(@"View Controller %d: Could become active", [self gesturedNavigationControllerOffset]);
    //Good idea to customize transition
    /*
    [UIView animateWithDuration:0.30 animations:^{
        [self.view setAlpha:1.0];
    }];
     */
}

- (void)childViewControllerCouldBecomeInactive
{
    NSLog(@"View Controller %d: Could become innactive", [self gesturedNavigationControllerOffset]);
    /*
    [UIView animateWithDuration:0.30 animations:^{
        [self.view setAlpha:0.50];
    }];
     */
}

- (void)childViewControllerVisiblePartDidChange:(NSNumber *)visiblePartWidth
{
    NSLog(@"View controller %d: Visible width %f", [self gesturedNavigationControllerOffset], visiblePartWidth.floatValue );
}

- (IBAction)onHideNavBar:(id)sender {
    [self.gesturedNavigationController
     setNavigationBarHidden:!self.gesturedNavigationController.isNavigatioNBarHidden
     animated:YES];
}

- (IBAction)onRemove:(id)sender {
    [self.gesturedNavigationController removeViewController:self animated:YES];
}

- (IBAction)onInsert:(id)sender {
    ViewController *controller = [[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
    [controller.view setBackgroundColor:[UIColor darkGrayColor]];
    [self.gesturedNavigationController inserViewController:controller atStackOffset:2 animated:YES];
}

- (IBAction)onPushNew:(id)sender {
    ViewController *controller = [[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
    [controller.view setBackgroundColor:[UIColor darkGrayColor]];
    [self.gesturedNavigationController pushViewController:controller animated:YES removeInBetweenViewControllers:NO];
}

- (IBAction)onPushNewVC:(id)sender {
    ViewController *controller = [[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
    [controller.view setBackgroundColor:[UIColor darkGrayColor]];
    [self.gesturedNavigationController pushViewController:controller animated:YES];
}

- (IBAction)pushVC:(id)sender {
    
    WithinNavigationViewController *vc = [[WithinNavigationViewController alloc]initWithNibName:nil bundle:nil];
    [self.gesturedNavigationController.navigationController pushViewController:vc animated:YES];
}
@end
