//
//  AHTextInputToolBar.h
//  AHTextInputToolBar
//
//  Created by Aalen on 2017/10/25.
//  Copyright © 2017年 Aalen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AHTextInputToolBarDelegate <NSObject>

@required
- (void)onToolbarFrameChanged: (CGRect)frame;
- (void)onSendButtonPressed;

@end

@interface AHTextInputToolBar : UIView

@property (weak, nonatomic) id<AHTextInputToolBarDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame maxCharacterCount: (NSUInteger)maxCharacterCount;
- (void)setFont: (UIFont *)font;
- (void)reset;

@end
