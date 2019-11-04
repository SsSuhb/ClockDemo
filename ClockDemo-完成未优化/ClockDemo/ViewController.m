//
//  ViewController.m
//  ClockDemo
//
//  Created by Toy Su on 2019/9/24.
//  Copyright © 2019 Intretech. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "CustomBtn.h"

@interface ViewController () <CustomBtnDelegate,UITableViewDataSource,UITableViewDelegate>

//秒表的控件
@property (nonatomic, strong) CustomBtn *btnLeft;

@property (nonatomic, strong) CustomBtn *btnRight;

@property (nonatomic, strong) UIButton *timeText;

@property (nonatomic, strong) UITableView *tableView;

//秒表运行状态
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) BOOL isFirstRun;

//按钮 - 左边按钮显示属性
@property (nonatomic, copy) NSString *btnLeftStr;

@property (nonatomic, strong) UIColor *btnLeftColor;

@property (nonatomic, strong) UIColor *btnLeftStrColor;

@property (nonatomic, strong) UIColor *btnLeftStrHighlightedColor;
//按钮 - 右边按钮显示属性
@property (nonatomic, copy) NSString *btnRightStr;

@property (nonatomic, strong) UIColor *btnRightColor;

@property (nonatomic, strong) UIColor *btnRightStrColor;

@property (nonatomic, strong) UIColor *btnRightStrHighlightedColor;

//时间属性
@property (nonatomic, assign) float *timeHour;
@property (nonatomic, strong) NSTimer *timer;
//时间数据
@property (nonatomic, assign) float time;
//时间间隔数据
@property (nonatomic, assign) float time_Lap;
//时间显示字符串
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, copy) NSString *timeStr_Lap;

//计数属性
@property (nonatomic, strong) NSArray *list_Time;
@property (nonatomic, strong) NSArray *list_Lap;
@property (nonatomic, strong) NSArray *list_time_cache;
@property (nonatomic, assign) int maxIndex; // 记录最大的索引
@property (nonatomic, assign) int minIndex; // 记录最小的索引

@end

@implementation ViewController

#warning TableView方法 by Toy at 2019/9/26
//设置有多少组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//设置有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.isFirstRun && self.list_Lap == nil) {
        return 1;
    } else {
        return self.list_Time.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"tableViewReCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    int row = (int)indexPath.row;
//    NSLog(@"%d",self.list_Time.count - row);
    if(row == 0){
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textAlignment = NSTextAlignmentNatural;
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        cell.backgroundColor = [UIColor blackColor];
        cell.detailTextLabel.text = self.timeStr_Lap;
        
        NSString *text;
        if(self.list_Time.count == 0) {
            text = [NSString stringWithFormat:@"计次1"];
        } else {
            text =  [NSString stringWithFormat:@"计次%ld",self.list_Time.count];
        }
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = text;
        cell.userInteractionEnabled = NO;
        return cell;
    } else {
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        if((row - 1) == self.minIndex)
            cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor colorWithRed:57/255.0 green:204/255.0 blue:75/255.0 alpha:1];
        if((row - 1) == self.maxIndex)
            cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor colorWithRed:226/255.0 green:68/255.0 blue:65/255.0 alpha:1];
        cell.detailTextLabel.textAlignment = NSTextAlignmentNatural;
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        cell.backgroundColor = [UIColor blackColor];
        cell.detailTextLabel.text = [self.list_Time objectAtIndex:row - 1];
        
        NSString *text = [NSString stringWithFormat:@"计次%@",[self.list_Lap objectAtIndex:row]];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        
        cell.textLabel.text = text;
        cell.userInteractionEnabled = NO;
        return cell;
    }
}


#pragma mark - 按钮的点击事件
#warning 启动/停止按钮 by Toy at 2019/9/26
- (void)btnRigthClick:(CustomBtn *)btn {
    self.btnLeft.enabled = true;
    // 按键的变换
    self.btnRightStr = self.checked? @"启动": @"停止" ;
    self.btnRightColor = self.checked? [UIColor colorWithRed:11/255.0 green:32/255.0 blue:15/255.0 alpha:1]: [UIColor colorWithRed:39/255.0 green:11/255.0 blue:10/255.0 alpha:1];
    self.btnRightStrColor = self.checked? [UIColor colorWithRed:57/255.0 green:204/255.0 blue:75/255.0 alpha:1]: [UIColor colorWithRed:226/255.0 green:68/255.0 blue:65/255.0 alpha:1];
    self.btnRightStrHighlightedColor = self.checked? [UIColor colorWithRed:57/255.0 green:204/255.0 blue:75/255.0 alpha:0.3]: [UIColor colorWithRed:226/255.0 green:68/255.0 blue:65/255.0 alpha:0.3];
    self.btnLeftStr = [self currentBtnLeftStr];
    [btn setTitle:self.btnRightStr forState:UIControlStateNormal];
    [btn setBackgroundColor:self.btnRightColor];
    [btn setTitleColor:self.btnRightStrColor forState:UIControlStateNormal];
    [btn setTitleColor:self.btnRightStrHighlightedColor forState:UIControlStateHighlighted];
    [self.btnLeft setTitle:self.btnLeftStr forState:UIControlStateNormal];
    
    if(!self.checked) {
        //启动
        if(!self.isFirstRun)
            self.isFirstRun = !self.isFirstRun;
        //另一个线程上开启NSTimer
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
        
    } else {
        //停止
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.timer invalidate];
        });
       
    }
    [self.tableView reloadData];
    self.checked = !self.checked;
}
#warning 复位/计数按钮 by Toy at 2019/9/26
- (void)btnLeftClick:(CustomBtn *)btn {
    static int count = 1;
    if(!self.checked && ![self.timeStr isEqualToString:@"00:00.00"]) {
        //复位
        self.isFirstRun = false;
        self.time = self.time_Lap = 0.0;
        self.timeStr = @"00:00.00";
        [self.timeText setTitle:self.timeStr forState:UIControlStateNormal];
        self.list_Lap = self.list_Time = nil;
        count = 1;
        self.maxIndex = self.minIndex = self.time_Lap = 0;
        self.btnLeftStr = [self currentBtnLeftStr];;
        [self.btnLeft setTitle:self.btnLeftStr forState:UIControlStateNormal];
        self.btnLeft.enabled = false;
        //刷新tableView
        [self.tableView reloadData];
    } else {
        //计次
        if(self.list_Time == nil) {
            self.list_Time = [[NSMutableArray alloc] initWithObjects:self.timeStr_Lap, nil];
            self.list_Lap = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%d", count++], nil];//存储次数
            //记录第一次计次最后的时间   
            self.time_Lap = self.time;
            self.list_time_cache = [[NSMutableArray alloc] initWithObjects:@(self.time_Lap), nil];
        }
        //修改运行状态
        self.isFirstRun = NO;
        //数据处理
//        NSLog(@"%f,%f",self.time,self.time_Lap);
        self.timeStr_Lap =  [NSString stringWithFormat:@"%02d:%05.2f",(int)(self.time_Lap/60),self.time_Lap - (60*(int)(self.time_Lap/60))];
        
        NSArray *arrayCache = [[NSArray alloc] initWithObjects:self.timeStr_Lap, nil];
        self.list_Time = [arrayCache arrayByAddingObjectsFromArray:self.list_Time];
        
        arrayCache = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%d", count++], nil];
        self.list_Lap = [arrayCache arrayByAddingObjectsFromArray:self.list_Lap];
        
        arrayCache = [[NSArray alloc] initWithObjects:@(self.time_Lap), nil];
        self.list_time_cache = [arrayCache arrayByAddingObjectsFromArray:self.list_time_cache];
        //冒泡排序获取最大和最小的Index
        NSMutableArray *result = [[NSMutableArray alloc] initWithArray:self.list_time_cache];
        for (int i= 0; i< result.count - 1; i++) {
            for (int j= 0; j < result.count - i - 2; j++){
                if ([result[j+1] floatValue] < [result[j] floatValue]) {
                    float temp = [result[j] floatValue];
                    result[j]= result[j + 1];
                    result[j + 1] = [NSNumber numberWithFloat:temp];
                }
            }
        }
        
        self.maxIndex = (int)[self.list_time_cache indexOfObject:result[result.count - 2]];
        self.minIndex = (int)[self.list_time_cache indexOfObject:result[0]];
    }
    //计数
    self.time_Lap = 0;
    [self.tableView reloadData];
}

// 按钮点击事件 识别不同按钮的点击
#warning 代理方法可以通过对比传进来的self来判断调用的对象 by Toy at 2019/10/9
- (void)customBtnClick:(CustomBtn *)btn {
//    if (btn == self.btnLeft) {
//        [self btnLeftClick:btn];
//    } else if (btn == self.btnRight) {
//        [self btnRigthClick:btn];
//    }
//
    
    if([btn.ID isEqualToString:@"Left"]) {
        [self btnLeftClick:btn];
    }
    if([btn.ID isEqualToString:@"Right"]) {
        [self btnRigthClick:btn];
    }
}

#pragma mark - 更新时间刷新单个Cell
- (float)updateTime {
    self.time += 0.01;
    self.time_Lap += 0.01;
    self.timeStr = [NSString stringWithFormat:@"%02d:%05.2f",(int)(self.time/60),self.time - (60*(int)(self.time/60))];
    self.timeStr_Lap =  [NSString stringWithFormat:@"%02d:%05.2f",(int)(self.time_Lap/60),self.time_Lap - (60*(int)(self.time_Lap/60))];
    //在主线程上更新UIButton的title
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.timeText setTitle:self.timeStr forState:UIControlStateNormal];
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:idxPath];
        cell.detailTextLabel.text = self.timeStr_Lap;
    }];
    return self.time;
}

#warning 返回当前btnLeft的Text by Toy at 2019/9/26
- (NSString *)currentBtnLeftStr {
    if(![self.timeStr isEqualToString:@"00:00.00"] && self.checked)
    {
        return @"复位";
    }
    if(!self.checked && ![self.timeStr isEqualToString:@"00:00.00"]) {
        return @"计次";
    }
    return @"计次";
}

#pragma mark -设置状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle
{
    //方法一
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
#warning 无用注释及代码可以删除别留着 by Toy at 2019/10/8
    // Do any additional setup after loading the view.
    
    //初始化属性
    [self initTimerProperty];
#warning  局部变量定义在使用前 by Toy at 2019/10/8
    UIColor *exColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:86/255.0 alpha:0.8]; //设按钮圆周围的颜色
    //设置界面背景颜色
#warning 如果有 . 则避免使用[] by Toy at 2019/10/8
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    //tableView
    UITableView *tableView = [[UITableView alloc] init];
    [tableView setBackgroundColor:[UIColor blackColor]];
    tableView.separatorColor = exColor;
    tableView.separatorInset = UIEdgeInsetsZero;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    
    //时间Label     timeText
#warning 变量命名规则（btn、Lab、Str） by Toy at 2019/10/8
    UIButton *timeText = [UIButton buttonWithType:UIButtonTypeCustom];
#warning 初始化格式按UITableView写，先配置好再用全局变量指向局部 by Toy at 2019/10/8
    self.timeText = timeText;
    self.timeText.userInteractionEnabled = false;
    self.timeText.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:80];
    self.timeText.titleLabel.textAlignment = NSTextAlignmentCenter;
#warning 无用注释及代码可以删除别留着 by Toy at 2019/10/8
//    timeText.titleLabel.font = [UIFont monospacedSystemFontOfSize:67 weight:UIFontWeightRegular];
    [self.timeText setTitle:self.timeStr forState:UIControlStateNormal];
    
#warning 尽可能描述清楚按钮的作用在名称上 by Toy at 2019/10/8
    //左边自定义控件
    CustomBtn *btnLeft = [CustomBtn btnWithID:@"Left" Title:self.btnLeftStr andTitleColor:self.btnLeftStrColor andBtnColor:self.btnLeftColor];
    btnLeft.delegate = self;
    [btnLeft setTitleColor:self.btnLeftStrHighlightedColor forState:UIControlStateHighlighted];
    self.btnLeft = btnLeft;
    self.btnLeft.enabled = false;
    
    //右边自定义d控件
    CustomBtn *btnRight = [CustomBtn btnWithID:@"Right" Title:self.btnRightStr andTitleColor:self.btnRightStrColor andBtnColor:self.btnRightColor];
    [btnRight setTitleColor:self.btnRightStrHighlightedColor forState:UIControlStateHighlighted];
    btnRight.delegate = self;
    self.btnRight = btnRight;
    
    
    //添加到父视图
    [self.view addSubview:tableView];
    [self.view addSubview:timeText];
    [self.view addSubview:btnLeft];
    [self.view addSubview:btnRight];

#warning 先创建好控件再统一进行约束不易出错且便于后期的修改，减少固定数值的约束 by Toy at 2019/10/8
    //添加timelabel约束
    [timeText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(100);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.equalTo(@150);
     }];
    //添加自定义btnLeft的约束
    [btnLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.size.width.height.equalTo(@70);
        make.top.equalTo(timeText.mas_bottom).offset(50);
    }];
    
    //添加自定义btnRight的约束
    [btnRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.size.width.height.equalTo(@70);
        make.top.equalTo(timeText.mas_bottom).offset(50);
    }];
    
    //添加tableView的约束
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeText.mas_bottom).offset(120);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
}

#pragma mark - 初始化属性
- (void)initTimerProperty {
    self.timeStr = @"00:00.00";
    self.btnLeftStr = @"计次";
    self.btnRightStr = @"启动";
    self.btnLeftColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:86/255.0 alpha:0.3];
    self.btnLeftStrColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.btnLeftStrHighlightedColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    self.btnRightColor = [UIColor colorWithRed:11/255.0 green:32/255.0 blue:15/255.0 alpha:1];
    self.btnRightStrColor = [UIColor colorWithRed:57/255.0 green:204/255.0 blue:75/255.0 alpha:1];
    self.btnRightStrHighlightedColor = [UIColor colorWithRed:57/255.0 green:204/255.0 blue:75/255.0 alpha:0.3];
}

@end
