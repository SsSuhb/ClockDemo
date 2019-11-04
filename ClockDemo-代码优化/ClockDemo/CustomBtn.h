//
//  CustomBtn.h
//  ClockDemo
//
//  Created by Toy Su on 2019/9/26.
//  Copyright © 2019 Intretech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class CustomBtn;
@protocol CustomBtnDelegate <NSObject>

- (void)customBtnClick:(CustomBtn *)btn;

@end

@interface CustomBtn : UIButton

//创建代理属性
@property (nonatomic, weak) id<CustomBtnDelegate> delegate;


- (instancetype)initWithTitle:(NSString *)btnTitle andTitleColor:(UIColor *)titleColor andBtnColor:(UIColor *)btnColor;

+ (instancetype)btnWithTitle:(NSString *)btnTitle andTitleColor:(UIColor *)titleColor andBtnColor:(UIColor *)btnColor;


@end

NS_ASSUME_NONNULL_END
