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
@property (nonatomic, strong) UIButton *timeTextButton;

@property (nonatomic, strong) UITableView *tableView;

//秒表运行状态
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) BOOL isFirstRun;

//按钮 - 左边按钮显示属性
@property (nonatomic, strong) CustomBtn *actionButton;

@property (nonatomic, copy) NSString *actionButtonStr;

//按钮 - 右边按钮显示属性
@property (nonatomic, strong) CustomBtn *statueButton;

@property (nonatomic, copy) NSString *statueButtonStr;

//时间属性
@property (nonatomic, assign) float *timeHour;

@property (nonatomic, strong) NSTimer *timer;
//时间数据
@property (nonatomic, assign) float time;
//时间间隔数据
@property (nonatomic, assign) float time_Lap;
//时间显示字符串
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, copy) NSString *timeLapStr;

//计数属性
@property (nonatomic, copy) NSArray *timeListArray;
@property (nonatomic, copy) NSArray *lapListArray;
@property (nonatomic, copy) NSArray *timeListArray_cache;
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
    if(self.isFirstRun && self.lapListArray == nil) {
        return 1;
    } else {
        return self.timeListArray.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"tableViewReCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    int row = (int)indexPath.row;
    if(row == 0){
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textAlignment = NSTextAlignmentNatural;
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        cell.backgroundColor = [UIColor blackColor];
        cell.detailTextLabel.text = self.timeLapStr;
        
        NSString *text;
        if(self.timeListArray.count == 0) {
            text = [NSString stringWithFormat:@"计次1"];
        } else {
            text =  [NSString stringWithFormat:@"计次%ld",self.timeListArray.count];
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
        cell.detailTextLabel.text = [self.timeListArray objectAtIndex:row - 1];
        
        NSString *text = [NSString stringWithFormat:@"计次%@",[self.lapListArray objectAtIndex:row]];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        
        cell.textLabel.text = text;
        cell.userInteractionEnabled = NO;
        return cell;
    }
}


#pragma mark - 按钮的点击事件
- (void)statueBtuttonClick:(CustomBtn *)btn {
    self.actionButton.enabled = true;
    // 按键的变换
    self.statueButtonStr = self.checked? @"启动": @"停止" ;
    self.actionButtonStr = [self getCurrentaActionButtonStr];
    [btn setTitle:self.statueButtonStr forState:UIControlStateNormal];
    [btn setBackgroundColor:self.checked? [UIColor colorWithRed:11/255.0 green:32/255.0 blue:15/255.0 alpha:1]: [UIColor colorWithRed:39/255.0 green:11/255.0 blue:10/255.0 alpha:1]];
    [btn setTitleColor:self.checked? [UIColor colorWithRed:57/255.0 green:204/255.0 blue:75/255.0 alpha:1]: [UIColor colorWithRed:226/255.0 green:68/255.0 blue:65/255.0 alpha:1] forState:UIControlStateNormal];
    [btn setTitleColor:self.checked? [UIColor colorWithRed:57/255.0 green:204/255.0 blue:75/255.0 alpha:0.3]: [UIColor colorWithRed:226/255.0 green:68/255.0 blue:65/255.0 alpha:0.3] forState:UIControlStateHighlighted];
    [self.actionButton setTitle:self.actionButtonStr forState:UIControlStateNormal];
    
    if(!self.checked) {
        //启动
        if(!self.isFirstRun)
            self.isFirstRun = !self.isFirstRun;
#pragma mark -- 开启线程，添加NSTimer
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
    self.checked = !self.checked;
    [self.tableView reloadData];
}

- (void)actionButtonClick:(CustomBtn *)btn {
    static int count = 1;
    if(!self.checked && ![self.timeStr isEqualToString:@"00:00.00"]) {
        //复位
        self.isFirstRun = false;
        self.time = 0.0;
        self.timeStr = @"00:00.00";
        [self.timeTextButton setTitle:self.timeStr forState:UIControlStateNormal];
        self.lapListArray = self.timeListArray = nil;
        count = 1;
        self.maxIndex = self.minIndex = 0;
        self.actionButtonStr = [self getCurrentaActionButtonStr];
        [self.actionButton setTitle:self.actionButtonStr forState:UIControlStateNormal];
        self.actionButton.enabled = false;
    } else {
        //计次
        if(self.timeListArray == nil) {
            self.timeListArray = [[NSMutableArray alloc] initWithObjects:self.timeLapStr, nil];
            self.lapListArray = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%d", count++], nil];//存储次数
            //记录第一次计次最后的时间
            self.time_Lap = self.time;
            self.timeListArray_cache = [[NSMutableArray alloc] initWithObjects:@(self.time_Lap), nil];
        }
        //修改运行状态
        self.isFirstRun = NO;
        //数据处理
        self.timeLapStr =  [NSString stringWithFormat:@"%02d:%05.2f",(int)(self.time_Lap/60),self.time_Lap - (60*(int)(self.time_Lap/60))];
        
        NSArray *arrayCache = [[NSArray alloc] initWithObjects:self.timeLapStr, nil];
        self.timeListArray = [arrayCache arrayByAddingObjectsFromArray:self.timeListArray];
        
        arrayCache = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%d", count++], nil];
        self.lapListArray = [arrayCache arrayByAddingObjectsFromArray:self.lapListArray];
        
        arrayCache = [[NSArray alloc] initWithObjects:@(self.time_Lap), nil];
        self.timeListArray_cache = [arrayCache arrayByAddingObjectsFromArray:self.timeListArray_cache];
        //冒泡排序获取最大和最小的Index
        NSMutableArray *result = [[NSMutableArray alloc] initWithArray:self.timeListArray_cache];
        for (int i= 0; i< result.count - 1; i++) {
            for (int j= 0; j < result.count - i - 2; j++){
                if ([result[j+1] floatValue] < [result[j] floatValue]) {
                    float temp = [result[j] floatValue];
                    result[j]= result[j + 1];
                    result[j + 1] = [NSNumber numberWithFloat:temp];
                }
            }
        }
        
        self.maxIndex = (int)[self.timeListArray_cache indexOfObject:result[result.count - 2]];
        self.minIndex = (int)[self.timeListArray_cache indexOfObject:result[0]];
    }
    //计数
    self.time_Lap = 0;
    [self.tableView reloadData];
}

// 按钮点击事件 识别不同按钮的点击
- (void)customBtnClick:(CustomBtn *)btn {
    if (btn == self.actionButton) {
        [self actionButtonClick:btn];
    } else if (btn == self.statueButton) {
        [self statueBtuttonClick:btn];
    }
}

#pragma mark - 更新时间  刷新Text
- (float)updateTime {
    self.time += 0.01;
    self.time_Lap += 0.01;
    self.timeStr = [NSString stringWithFormat:@"%02d:%05.2f",(int)(self.time/60),self.time - (60*(int)(self.time/60))];
    self.timeLapStr =  [NSString stringWithFormat:@"%02d:%05.2f",(int)(self.time_Lap/60),self.time_Lap - (60*(int)(self.time_Lap/60))];
#pragma mark - 切换线程更新UI
    //在主线程上更新UIButton的title
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timeTextButton setTitle:self.timeStr forState:UIControlStateNormal];
        NSIndexPath *idxPath = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:idxPath];
        cell.detailTextLabel.text = self.timeLapStr;
    });
    
    return self.time;
}

#warning 返回当前actionButton的Text by Toy at 2019/9/26
#warning 代理方法可以通过对比传进来的self来判断调用的对象 by Toy at 2019/10/9
- (NSString *)getCurrentaActionButtonStr {
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
    //初始化属性
    [self initTimerProperty];
    #warning  局部变量定义在使用前 by Toy at 2019/10/8
    //设置界面背景颜色
    #warning 如果有 . 则避免使用[] by Toy at 2019/10/8
    self.view.backgroundColor = [UIColor blackColor];
    
    //tableView
    UITableView *tableView = [[UITableView alloc] init];
#warning 初始化格式按UITableView写，先配置好再用全局变量指向局部 by Toy at 2019/10/8
    tableView.backgroundColor = [UIColor blackColor];
    tableView.separatorColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:86/255.0 alpha:0.8];
    tableView.separatorInset = UIEdgeInsetsZero;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    
    //时间Label     timeTextButton
    #warning 变量命名规则（btn、Lab、Str） by Toy at 2019/10/8
    UIButton *timeTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    #warning 初始化格式按UITableView写，先配置好再用全局变量指向局部 by Toy at 2019/10/8
    timeTextButton.userInteractionEnabled = false;
    timeTextButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:80];
    timeTextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [timeTextButton setTitle:self.timeStr forState:UIControlStateNormal];
    #warning 无用注释及代码可以删除别留着 by Toy at 2019/10/8
    self.timeTextButton = timeTextButton;
    
    //左边自定义控件
    #warning 尽可能描述清楚按钮的作用在名称上 by Toy at 2019/10/8
    CustomBtn *actionButton = [CustomBtn btnWithTitle:self.actionButtonStr andTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] andBtnColor:[UIColor colorWithRed:80/255.0 green:80/255.0 blue:86/255.0 alpha:0.3]];
    actionButton.delegate = self;
    [actionButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3] forState:UIControlStateHighlighted];
    actionButton.enabled = false;
    self.actionButton = actionButton;
    
    //右边自定义d控件
    CustomBtn *statueButton = [CustomBtn btnWithTitle:self.statueButtonStr andTitleColor:[UIColor colorWithRed:57/255.0 green:204/255.0 blue:75/255.0 alpha:1] andBtnColor:[UIColor colorWithRed:11/255.0 green:32/255.0 blue:15/255.0 alpha:1]];
    [statueButton setTitleColor:[UIColor colorWithRed:57/255.0 green:204/255.0 blue:75/255.0 alpha:0.3] forState:UIControlStateHighlighted];
    statueButton.delegate = self;
    self.statueButton = statueButton;
    
    
    //添加到父视图
    [self.view addSubview:tableView];
    [self.view addSubview:timeTextButton];
    [self.view addSubview:actionButton];
    [self.view addSubview:statueButton];

    #warning 先创建好控件再统一进行约束不易出错且便于后期的修改，减少固定数值的约束 by Toy at 2019/10/8
    //添加timelabel约束
    [self.timeTextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(100);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.equalTo(@150);
     }];
    //添加自定义actionButton的约束
    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeTextButton.mas_left);
        make.size.width.height.equalTo(@70);
        make.top.equalTo(timeTextButton.mas_bottom).offset(50);
    }];
    
    //添加自定义statueButton的约束
    [self.statueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.timeTextButton.mas_right);
        make.size.width.equalTo(self.actionButton.mas_width);
        make.size.height.equalTo(self.actionButton.mas_height);
        make.top.equalTo(self.actionButton.mas_top);z
    }];
    
    //添加tableView的约束
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.actionButton.mas_bottom).offset(5);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.timeTextButton.mas_left);
        make.right.equalTo(self.timeTextButton.mas_right);
    }];
}

#pragma mark - 初始化属性
- (void)initTimerProperty {
    self.timeStr = @"00:00.00";
    self.actionButtonStr = @"计次";
    self.statueButtonStr = @"启动";
}

@end
