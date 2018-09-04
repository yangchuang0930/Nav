//
//  HomeViewController.m
//
//  Created by yangchuang on 2017/9/18.
//  Copyright © 2017年 yc. All rights reserved.
//

#import "HomeViewController.h"

#define headImgWidth 55


@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    UITableView *mainTableView;
    UIImageView *HeadImageView;
    
    CGFloat lastOffsetY;
    UIImageView *navImageView;
    
    UIImageView *headImg;
    UILabel *nameLable;
    UIImageView *smallImgView;
    
    
    CGFloat needMoveY;//Y方向可移动的距离
    CGFloat MoveMultiple;//Y方向每移动一个像素，headImg的X方向需移动的倍数
    CGFloat widthMultiple;//头像的宽度倍数
}
@end

@implementation HomeViewController

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    mainTableView.backgroundColor = [UIColor whiteColor];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    NSArray *Animation_ImageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"Animation_1"], [UIImage imageNamed:@"Animation_2"],[UIImage imageNamed:@"Animation_3"] , [UIImage imageNamed:@"Animation_2"], nil];
    [header setImages:Animation_ImageArray forState:MJRefreshStateRefreshing];
    // 设置header
    mainTableView.mj_header = header;
    [self.view addSubview:mainTableView];
    
    
    //tableView的headView
    HeadImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 145)];
    HeadImageView.image = [UIImage imageNamed:@"headBg"];
    //头像
    headImg = [[UIImageView alloc]initWithFrame:CGRectMake(25,HeadImageView.height-13-headImgWidth, headImgWidth,headImgWidth)];
    headImg.image = [UIImage imageNamed:@"gestureHead"];
    [HeadImageView addSubview:headImg];
    
    //登陆、注册
    nameLable = [[UILabel alloc]initWithFrame:CGRectMake(headImg.max_X+30, headImg.y, headImg.width, headImg.height)];
    nameLable.text = @"登录 | 注册                                >";
    nameLable.textColor = [UIColor whiteColor];
    nameLable.font = [UIFont systemFontOfSize:18];
    [nameLable sizeToFit];
    nameLable.centerY = headImg.centerY;
    [HeadImageView addSubview:nameLable];
    
    [self createNavView];
    mainTableView.tableHeaderView = HeadImageView;
    
}

#pragma mark - createView
-(void)createNavView{
    //虚拟导航栏，存放title，设置，客服，信息btn
    navImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,self.view.width, 64)];
    [self.view addSubview:navImageView];
    //title
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 30, 44)];
    titleLable.centerX = navImageView.centerX;
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.text = @"我的";
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.font = [UIFont systemFontOfSize:16];
    [titleLable sizeToFit];
    [navImageView addSubview:titleLable];
    //设置
    UIButton *setBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
    titleLable.centerY = setBtn.centerY;
    [setBtn setImage:[UIImage imageNamed:@"blueSetting"] forState:UIControlStateNormal];
    [navImageView addSubview:setBtn];
    
    //消息
    UIButton *newsBtn = [[UIButton alloc]initWithFrame:CGRectMake(navImageView.width-setBtn.width, setBtn.y, setBtn.width, setBtn.height)];
    [newsBtn setImage:[UIImage imageNamed:@"blueMessage"] forState:UIControlStateNormal];
    [navImageView addSubview:newsBtn];
    //客服
    UIButton *askBtn = [[UIButton alloc]initWithFrame:CGRectMake(newsBtn.x-newsBtn.width, newsBtn.y, newsBtn.width, newsBtn.height)];
    [askBtn setImage:[UIImage imageNamed:@"blueOnLine"] forState:UIControlStateNormal];
    [navImageView addSubview:askBtn];
    
    //小headImg
    smallImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    smallImgView.centerY = titleLable.centerY - 3;
    smallImgView.x = titleLable.x - 10- 30;
    [navImageView addSubview:smallImgView];
    
    
    //    创建完所有的东西之后计算需要移动的位置和距离
    
    [self dealPosition];
}

-(void)dealPosition{
    //头像距离左端的距离不能直接用offset来决定，因为屏幕宽度不一样，要根据屏幕宽度来计算出一个倍数
    //1、计算出总共需要向右移动多少距离
    CGFloat needMoveX = smallImgView.x - headImg.x;
    //2、找出上下移动多少距离就得到位
    needMoveY = HeadImageView.height - navImageView.height;
    //3、根据这两个参数，计算出倍数，然后重新定义leftPadding
    MoveMultiple = needMoveY/needMoveX;
    
    
//    1、首先确定初始大小和末尾大小的差
//    初始是headImgWidth，末尾是25
//    2、然后是Y移动的距离
//    3、根据移动的倍数计算应该减少多少
    CGFloat subWidth = headImg.width - smallImgView.width;
    widthMultiple = (CGFloat)subWidth / needMoveY;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;//计算当前偏移位置
    navImageView.alpha = 1;
    
    CGFloat leftPadding = offsetY/MoveMultiple + 25;//头像距左端原有25像素；moveX = moveY/倍数;将x设置给headImg；
    CGFloat headWidth = headImgWidth - offsetY*widthMultiple;//计算头像移动过程中的宽度
    
    if (offsetY > needMoveY) {//和nav重合的状态，直接显示navImageView
        //        1、设置navImageView的背景图片；小头像出现
        navImageView.image = [UIImage imageNamed:@"mineNavBar"];
        smallImgView.image = [UIImage imageNamed:@"gestureHead"];
        
    }else if (offsetY <= 0) {//说明是下拉，隐藏 navView
        CGFloat imgAlpha = 1 + offsetY/40;//下拉40个像素就完全隐藏
        navImageView.alpha = imgAlpha;
        headImg.frame = CGRectMake(25, HeadImageView.height-13-headImgWidth, headImgWidth, headImgWidth);
        nameLable.alpha = 1;
    }else{//移动过程
        navImageView.image = [UIImage imageNamed:@""];
        smallImgView.image = [UIImage imageNamed:@""];
        headImg.frame = CGRectMake(leftPadding, HeadImageView.height-13-headWidth, headWidth, headWidth);
        nameLable.x = headImg.max_X + 30;
        nameLable.alpha = 1 - offsetY/needMoveY;
    }
}


#pragma mark -tablviewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.text = [NSString stringWithFormat:@"indexPath: %ld",(long)indexPath.row];
        
    }
    return cell;
}

#pragma mark -BtnClicked

-(void)loadData{//    下拉刷新
    navImageView.alpha = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [mainTableView.mj_header endRefreshing];
    });
}

@end
