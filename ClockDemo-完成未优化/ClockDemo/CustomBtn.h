//
//  CustomBtn.h
//  ClockDemo
//
//  Created by Toy Su on 2019/9/26.
//  Copyright © 2019 Intretech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"

NS_ASSUME_NONNULL_BEGIN
@class CustomBtn;
@protocol CustomBtnDelegate <NSObject>

- (void)customBtnClick:(CustomBtn *)btn;

@end

@interface CustomBtn : UIButton

@property (nonatomic, strong) UIButton *exBtn;

@property (nonatomic, strong) UIButton *contentBtn;

@property (nonatomic, copy) UIColor *btnColor;

@property (nonatomic, copy) NSString *btnStr;

@property (nonatomic, strong) NSString *btnState;

@property (nonatomic, copy) NSString *ID;

//创建代理属性
@property (nonatomic, weak) id<CustomBtnDelegate> delegate;


- (instancetype)initWithID:(NSString *)ID Title:(NSString *)btnTitle andTitleColor:(UIColor *)titleColor andBtnColor:(UIColor *)btnColor;

+ (instancetype)btnWithID:(NSString *)ID Title:(NSString *)btnTitle andTitleColor:(UIColor *)titleColor andBtnColor:(UIColor *)btnColor;


@end

NS_ASSUME_NONNULL_END
