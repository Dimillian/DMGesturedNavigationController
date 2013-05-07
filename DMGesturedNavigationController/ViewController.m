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

- (void)didBecomeActive
{

}

- (void)didResignActive
{

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
