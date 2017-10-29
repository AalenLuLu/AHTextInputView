//
//  AHTextInputToolBar.m
//  AHTextInputToolBar
//
//  Created by Aalen on 2017/10/25.
//  Copyright © 2017年 Aalen. All rights reserved.
//

#import "AHTextInputToolBar.h"
#import "AHTextInputView.h"

static const CGFloat kDefaultMaxHeight = 122.0;
static const CGFloat kButtonGap = 8.0;

@interface AHTextInputToolBar () <AHTextInputViewDelegate>

@property (strong, nonatomic) AHTextInputView *textInputView;
@property (assign, nonatomic) CGFloat originFrameY;
@property (assign, nonatomic) CGFloat originHeight;
@property (assign, nonatomic) CGFloat maxHeight;
@property (assign, nonatomic) NSUInteger maxCharacterCount;
@property (assign, nonatomic) BOOL isInBackground;

@end

@implementation AHTextInputToolBar

- (void)dealloc
{
	[self unregisterNotifications];
	[_textInputView removeObserver: self forKeyPath: @"contentSize"];
}

- (instancetype)init
{
	return [self initWithFrame: CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame maxCharacterCount:0];
}

- (instancetype)initWithFrame:(CGRect)frame maxCharacterCount:(NSUInteger)maxCharacterCount
{
	if(44.0 > frame.size.height)
	{
		frame.size.height = 44.0;
	}
	if(self = [super initWithFrame: frame])
	{
		_maxCharacterCount = maxCharacterCount;
		[self initUI];
		[self registerNotifications];
	}
	return self;
}

- (void)initUI
{
	self.backgroundColor = [UIColor colorWithRed: 0xed / 255.0 green: 0xed / 255.0 blue: 0xed / 255.0 alpha: 1.0];
	
	_maxHeight = kDefaultMaxHeight;							//默认最大高度...
	_originFrameY = self.frame.origin.y;					//保存创建时偏移...
	_originHeight = self.frame.size.height;					//保存创建时高度...
	
	[self addSubview: self.textInputView];
	[self.textInputView addObserver: self forKeyPath: @"contentSize" options: NSKeyValueObservingOptionNew context: nil];
}

#pragma mark - interfaces...

- (void)setFont:(UIFont *)font
{
	self.textInputView.font = font;
}

- (void)reset
{
	[self.textInputView resetTextView];
}

#pragma mark - private function...

- (void)changeToolbarHeightWithTextInputView
{
	CGRect frame = _textInputView.frame;
	CGFloat height = _maxHeight < _textInputView.contentSize.height ? _maxHeight : _textInputView.contentSize.height;
	height = height < _textInputView.originHeight ? _textInputView.originHeight : height;
	if(frame.size.height != height)
	{
		frame.size.height = height;
		[_textInputView setFrame: frame];
	}
	
	//toolbar...
	CGRect textInputViewFrame = _textInputView.frame;
	CGRect toolbarFrame = self.frame;
	toolbarFrame.size.height = textInputViewFrame.size.height + 2 * textInputViewFrame.origin.y;
	toolbarFrame.origin.y -= toolbarFrame.size.height - self.frame.size.height;
	[self setFrame: toolbarFrame];
	//	[self onFrameChanged];
}

- (void)resetToolbarHeight
{
	CGRect frame = self.frame;
	if(_textInputView.hidden)
	{
		frame.origin.y = _originFrameY;
		frame.size.height = _originHeight;
		[self setFrame: frame];
		//	[self onFrameChanged];
	}
	else
	{
		[self changeToolbarHeightWithTextInputView];
	}
}

- (void)onFrameChanged
{
	if(_delegate)
	{
		if([_delegate respondsToSelector: @selector(onToolbarFrameChanged:)])
		{
			[_delegate onToolbarFrameChanged: self.frame];
		}
	}
}

#pragma mark - AHTextInputView delegate...

- (void)onTextInputViewSendButtonPressed
{
	if(_delegate)
	{
		if([_delegate respondsToSelector: @selector(onSendButtonPressed)])
		{
			[_delegate onSendButtonPressed];
		}
	}
}

#pragma mark - notifications...

- (void)registerNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onKeyboardShow:) name: UIKeyboardWillShowNotification object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onKeyboardHide:) name: UIKeyboardWillHideNotification object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(applicationWillResignActive:) name: UIApplicationWillResignActiveNotification object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(applicationDidBecomeActive:) name: UIApplicationDidBecomeActiveNotification object: nil];
}

- (void)unregisterNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillShowNotification object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillHideNotification object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationWillResignActiveNotification object: nil];
	[[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidBecomeActiveNotification object: nil];
}

- (void)onKeyboardShow: (NSNotification *)notification
{
	if(!_isInBackground)
	{
		NSDictionary *userInfo = notification.userInfo;
		[self moveKeyboard: userInfo isShow: YES];
	}
}

- (void)onKeyboardHide: (NSNotification *)notification
{
	if(!_isInBackground)
	{
		NSDictionary *userInfo = notification.userInfo;
		[self moveKeyboard: userInfo isShow: NO];
	}
}

/**
 * UIKeyboardAnimationCurveUserInfoKey = 7;
 * UIKeyboardAnimationDurationUserInfoKey = "0.25";
 * UIKeyboardBoundsUserInfoKey = "NSRect: {{0, 0}, {414, 262}}";
 * UIKeyboardCenterBeginUserInfoKey = "NSPoint: {207, 623}";
 * UIKeyboardCenterEndUserInfoKey = "NSPoint: {207, 605}";
 * UIKeyboardFrameBeginUserInfoKey = "NSRect: {{0, 510}, {414, 226}}";
 * UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 474}, {414, 262}}";
 **/
- (void)moveKeyboard: (NSDictionary *)userInfo isShow: (BOOL)isShow
{
	NSString *strDuration = [userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey];
	NSValue *value = [userInfo objectForKey: UIKeyboardFrameEndUserInfoKey];
	float duration = strDuration.floatValue;
	CGRect rect = [value CGRectValue];
	
	CGRect frame = self.frame;
	
	CGFloat safeAreaBottom = 0;
	if([self.superview respondsToSelector: @selector(safeAreaInsets)])
	{
		safeAreaBottom = self.superview.safeAreaInsets.bottom;
	}
	
	if(isShow)
	{
		frame.origin.y = self.superview.bounds.size.height - frame.size.height - rect.size.height - safeAreaBottom;
	}
	else
	{
		frame.origin.y = self.superview.bounds.size.height - frame.size.height - safeAreaBottom;
	}
	
	[UIView animateWithDuration: duration delay: 0 options: UIViewAnimationOptionBeginFromCurrentState animations: ^{
		[self setFrame: frame];
	} completion: nil];
}

- (void)applicationWillResignActive: (NSNotification *)notification
{
	_isInBackground = YES;
}

- (void)applicationDidBecomeActive: (NSNotification *)notification
{
	_isInBackground = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([object isEqual: _textInputView])
	{
		if([@"contentSize" isEqualToString: keyPath])
		{
			[self changeToolbarHeightWithTextInputView];
		}
	}
}

#pragma mark - override...

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self onFrameChanged];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor colorWithRed: 0xb6 / 255.0 green: 0xb6 / 255.0 blue: 0xb6 / 255.0 alpha: 1.0] set];
	CGContextSetLineWidth(context, 0.5);
	CGContextMoveToPoint(context, 0, 0.25);
	CGContextAddLineToPoint(context, self.bounds.size.width, 0.25);
	CGContextStrokePath(context);
}

#pragma mark - lazy load...

- (AHTextInputView *)textInputView
{
	if(nil == _textInputView)
	{
		CGSize size = [UIScreen mainScreen].bounds.size;
		
		CGFloat leftSpace = kButtonGap;
		CGFloat rightSpace = kButtonGap;
		if(0 == _maxCharacterCount)
		{
			_textInputView = [[AHTextInputView alloc] initWithFrame: CGRectMake(leftSpace, 6.0, size.width - leftSpace - rightSpace, _originHeight - 12.0)];
		}
		else
		{
			_textInputView = [[AHTextInputView alloc] initWithFrame: CGRectMake(leftSpace, 6.0, size.width - leftSpace - rightSpace, _originHeight - 12.0) maxCharacterCount: _maxCharacterCount];
		}
		
		_textInputView.textInputViewDelegate = self;
	}
	return _textInputView;
}

@end
