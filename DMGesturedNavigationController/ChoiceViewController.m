//
//  ChoiceViewController.m
//  DMGesturedNavigationController
//
//  Created by Thomas Ricouard on 5/7/13.
//  Copyright (c) 2013 Thomas Ricouard. All rights reserved.
//

#import "ChoiceViewController.h"
#import "ViewController.h"
#import "DMGesturedNavigationController.h"
#import "WithinNavigationViewController.h"

@interface ChoiceViewController ()

@end

@implementation ChoiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onFreeNavigation:(id)sender {
    
    ViewController *controller1 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [controller1.view setBackgroundColor:[UIColor blueColor]];
    ViewController *controller2 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [controller2.view setBackgroundColor:[UIColor redColor]];
    ViewController *controller3 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [controller3.view setBackgroundColor:[UIColor greenColor]];
    ViewController *controller4 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [controller4.view setBackgroundColor:[UIColor orangeColor]];
    DMGesturedNavigationController *container = [[DMGesturedNavigationController alloc]initWithViewControllers:
  @[controller1, controller2, controller3, controller4] navigationarBarHeight:44.0f];
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:container];
    [container.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    [container setAnimatedNavbarChange:NO];
    [navigation setNavigationBarHidden:YES animated:NO];
    [self presentViewController:navigation animated:YES completion:^{
        
    }];
}

- (IBAction)onLockedStack:(id)sender {
    ViewController *controller1 = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [controller1.view setBackgroundColor:[UIColor blueColor]];
    controller1.title = @"First";
    DMGesturedNavigationController *container = [[DMGesturedNavigationController alloc]initWithViewControllers:@[controller1]
                                                                                         navigationarBarHeight:44.0f];
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:container];
    [container.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    [container setAnimatedNavbarChange:YES];
    [container setStackType:DMGesturedNavigationControllerStackLikeNavigationController];
    [navigation setNavigationBarHidden:YES animated:NO];
    [container setPopAnimationType:DMGesturedNavigationControllerPopAnimationClassic];
    [self presentViewController:navigation animated:YES completion:^{
        
    }];
}
@end
