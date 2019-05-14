
//
//  ViewController.m
//  视频捕捉
//
//  Created by 吴琼 on 2019/1/8.
//  Copyright © 2019年 lcWorld. All rights reserved.
//
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define TabBar_Height 49.0
#define Nav_StatusBar_Height [UIApplication sharedApplication].statusBarFrame.size.height
#define SEPARATELINE_COLOR [UIColor redColor]

#import "ViewController.h"
#import "VideoDataOutputVC.h"//视频捕获
#import "faceVC.h"//人脸识别

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *soures;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.soures addObject:@{@"title":@"视频捕捉",@"class":@"VideoDataOutputVC"}];
    [self.soures addObject:@{@"title":@"人脸识别",@"class":@"faceVC"}];
    [self addUI];
    [self setViewFrame];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)addUI{
    [self.view addSubview:self.tableView];
}
- (void)setViewFrame
{

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.soures.count;
}
- (UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.soures[indexPath.row][@"title"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * class = self.soures[indexPath.row][@"class"];
    UIViewController * vc = [[NSClassFromString(class) alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, Nav_StatusBar_Height, ScreenWidth, ScreenHeight - Nav_StatusBar_Height - TabBar_Height) style:UITableViewStylePlain];
        _tableView.separatorColor = SEPARATELINE_COLOR;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 18, 0, 18);
        _tableView.backgroundColor = self.view.backgroundColor;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}
- (NSMutableArray *)soures
{
    if (!_soures) {
        _soures = [NSMutableArray new];
    }
    return _soures;
}

@end

