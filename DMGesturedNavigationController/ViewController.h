//
//  ViewController.h
//  DMGesturedNavigationController
//
//  Created by Thomas Ricouard on 04/05/13.
//  Copyright (c) 2013 Thomas Ricouard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMGesturedNavigationController.h"

@interface ViewController : UIViewController <DMGesturedChildViewController>
- (IBAction)onPushNewVC:(id)sender;
- (IBAction)pushVC:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *pushNewVC;
@end
