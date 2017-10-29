//
//  AHTextInputView.m
//  AHTextInputToolBar
//
//  Created by Aalen on 2017/10/25.
//  Copyright © 2017年 Aalen. All rights reserved.
//

#import "AHTextInputView.h"

static const NSUInteger kDefaultMaxCharacterCount = 300;

@interface AHTextInputView ()

@property (assign, nonatomic) CGFloat originHeight;
@property (assign, nonatomic) NSUInteger maxCharacterCount;

@end

@implementation AHTextInputView

- (instancetype)init
{
	return [self initWithFrame: CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame: frame maxCharacterCount: kDefaultMaxCharacterCount];
}

- (instancetype)initWithFrame:(CGRect)frame maxCharacterCount:(NSUInteger)maxCharacterCount
{
	if(self = [super initWithFrame:frame])
	{
		_originHeight = frame.size.height;
		_maxCharacterCount = maxCharacterCount;
		[self initUI];
		self.returnKeyType = UIReturnKeySend;
		self.delegate = self;
		
		if(0 == _maxCharacterCount)
		{
			_maxCharacterCount = kDefaultMaxCharacterCount;
		}
	}
	return self;
}

- (void)initUI
{
	self.font = [UIFont systemFontOfSize: 15.0];
	self.layer.masksToBounds = YES;
	self.layer.cornerRadius = 4.0;
	self.layer.borderWidth = 0.5;
	self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)resetTextView
{
	self.text = @"";
	CGRect frame = self.frame;
	frame.size.height = _originHeight;
	self.frame = frame;
}

#pragma mark Text view delegate...

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if([text isEqualToString: @"\n"])
	{
		NSRange transformRange = [textView.text rangeOfString: @"￼"];
		if(0 < transformRange.length)
		{
			return NO;
		}
		if(_textInputViewDelegate)
		{
			if([_textInputViewDelegate respondsToSelector: @selector(onTextInputViewSendButtonPressed)])
			{
				[_textInputViewDelegate onTextInputViewSendButtonPressed];
			}
		}
		return NO;
	}
	
	//字符限制导致undo崩溃...
	if(textView.undoManager.isUndoing)
	{
		if((textView.text.length == range.location) && (1 == range.length) && (nil == text || [@"" isEqualToString: text]))
		{
			return NO;
		}
		else if((textView.text.length < range.length) && (nil == text || [@"" isEqualToString: text]))
		{
			return NO;
		}
		else if(range.location < textView.text.length && textView.text.length <= range.length)
		{
			return NO;
		}
		if(_maxCharacterCount <= range.location)
		{
			return NO;
		}
	}
	//
	
	//字数限制...
	NSString *temp = [textView.text stringByReplacingCharactersInRange: range withString: text];
	if(_maxCharacterCount < temp.length)
	{
		textView.text = [temp substringToIndex: _maxCharacterCount];
		return NO;
	}
	//
	
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
	if(_maxCharacterCount < textView.text.length)
	{
		@try {
			[textView setText: [textView.text substringToIndex: _maxCharacterCount]];
		}
		@catch (NSException *exception) {
			
		}
	}
}

@end
