//
//  ViewController.m
//  AHTextInputViewDemo
//
//  Created by Aalen on 2017/10/29.
//  Copyright © 2017年 Aalen. All rights reserved.
//

#import "ViewController.h"
#import "AHTextInputToolBar.h"

@interface ViewController () <AHTextInputToolBarDelegate>

@property (strong, nonatomic) AHTextInputToolBar *toolBar;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self.view addSubview: self.toolBar];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewSafeAreaInsetsDidChange
{
	[super viewSafeAreaInsetsDidChange];
	CGRect frame = self.toolBar.frame;
	frame.origin = CGPointMake(0, self.view.bounds.size.height - self.toolBar.frame.size.height - self.view.safeAreaInsets.bottom);
	self.toolBar.frame = frame;
}

- (void)onToolbarFrameChanged:(CGRect)frame
{
	NSLog(@"%s: %@", __func__, NSStringFromCGRect(frame));
}

- (void)onSendButtonPressed
{
	NSLog(@"%s", __func__);
	[_toolBar reset];
}

- (AHTextInputToolBar *)toolBar
{
	if(nil == _toolBar)
	{
		_toolBar = [[AHTextInputToolBar alloc] initWithFrame: CGRectMake(0, self.view.bounds.size.height - 50.0 - self.view.safeAreaInsets.bottom, self.view.bounds.size.width, 50.0) maxCharacterCount: 50];
		_toolBar.delegate = self;
	}
	return _toolBar;
}

@end
