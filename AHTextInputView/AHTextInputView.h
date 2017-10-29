//
//  AHTextInputView.h
//  AHTextInputToolBar
//
//  Created by Aalen on 2017/10/25.
//  Copyright © 2017年 Aalen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AHTextInputViewDelegate <NSObject>

@required
- (void)onTextInputViewSendButtonPressed;

@end

@interface AHTextInputView : UITextView <UITextViewDelegate>

@property (weak, nonatomic) id<AHTextInputViewDelegate> textInputViewDelegate;
@property (assign, readonly, nonatomic) CGFloat originHeight;

- (instancetype)initWithFrame: (CGRect)frame maxCharacterCount: (NSUInteger)maxCharacterCount;
- (void)resetTextView;

@end
