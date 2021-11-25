//
//  CTContentSimpleViewController.m
//  CTNotificationContent
//
//  Created by Sonal Kachare on 26/11/21.
//  Copyright © 2021 CleverTap. All rights reserved.
//

#import "CTContentSimpleViewController.h"

@interface CTContentSimpleViewController () {
    
}
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation CTContentSimpleViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.contentView = [[UIView alloc] initWithFrame:self.view.frame];
    self.contentView.backgroundColor = UIColor.redColor;
    [self.view addSubview:self.contentView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
