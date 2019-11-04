//
//  CustomBtn.m
//  ClockDemo
//
//  Created by Toy Su on 2019/9/26.
//  Copyright © 2019 Intretech. All rights reserved.
//

#import "CustomBtn.h"

@implementation CustomBtn

-(instancetype)initWithID:(NSString *)ID Title:(NSString *)btnTitle andTitleColor:(UIColor *)titleColor andBtnColor:(UIColor *)btnColor {
    if(self == [super init]) {
        //设置自身的参数
//        CustomBtn *externalBtn = [[UIButton alloc] init];
        self.layer.cornerRadius = 35; //设置圆形的程度
        self.layer.masksToBounds = YES; //设置是否切圆
        self.layer.borderColor = btnColor.CGColor; //设置圆周围的颜色
        self.layer.borderWidth = 2; //设置圆环的粗细宽度
        self.ID = ID;

        //内部的圆形Btn
        UIButton *contentBtn = [[UIButton alloc] init];
        [contentBtn setTitle:btnTitle forState:UIControlStateNormal];
        [contentBtn setTitleColor:titleColor forState:UIControlStateNormal];
        contentBtn.layer.cornerRadius = 30;
        [contentBtn setBackgroundColor:btnColor];
        contentBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        contentBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:contentBtn];
        self.contentBtn = contentBtn;
        
        //添加约束
        [contentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(4);
            make.right.equalTo(self.mas_right).offset(-4);
            make.bottom.equalTo(self.mas_bottom).offset(-4);
            make.left.equalTo(self.mas_left).offset(4);
        }];
        [self.contentBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
//        self = externalBtn;
    }
    return self;
}

+ (instancetype)btnWithID:(NSString *)ID Title:(NSString *)btnTitle andTitleColor:(UIColor *)titleColor andBtnColor:(UIColor *)btnColor {
    return [[CustomBtn alloc] initWithID:ID Title:btnTitle andTitleColor:titleColor andBtnColor:btnColor];
}

#warning 代理实现方法 by Toy at 2019/9/26
- (void)btnClick {
    if([self.delegate respondsToSelector:@selector(customBtnClick:)]) {
        //调用代理方法
        [self.delegate customBtnClick:self];
    }
}

#warning 重写set方法为内部的Button赋值 by Toy at 2019/9/26
-(void)setTitle:(NSString *)title forState:(UIControlState)state {
    [self.contentBtn setTitle:title forState:state];
}

-(void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [self.contentBtn setTitleColor:color forState:state];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.layer.borderColor = backgroundColor.CGColor;
    [self.contentBtn setBackgroundColor:backgroundColor];
}

- (NSString *)currentTitle {
    if (self.contentBtn.currentTitle != NULL) {
        return self.contentBtn.currentTitle;
    }
    return self.currentTitle;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
