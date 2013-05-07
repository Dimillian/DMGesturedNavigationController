//
//  WithinNavigationViewController.m
//  DMGesturedNavigationController
//
//  Created by Thomas Ricouard on 5/7/13.
//  Copyright (c) 2013 Thomas Ricouard. All rights reserved.
//

#import "WithinNavigationViewController.h"
#import "DMGesturedNavigationController.h"

@interface WithinNavigationViewController ()

@end

@implementation WithinNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
       [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"Normal navigation controller";
	// Do any additional setup after loading the view.
}

- (void)push
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
