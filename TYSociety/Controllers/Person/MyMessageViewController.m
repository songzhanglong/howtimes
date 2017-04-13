//
//  MyMessageViewController.m
//  TYSociety
//
//  Created by zhangxs on 16/6/30.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MyMessageViewController.h"

@interface MyMessageViewController ()
{
    NSArray *_names,*_imgs;
}
@end
@implementation MyMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.titleLable.text = @"我的消息";
    self.navigationController.navigationBar.translucent = NO;
    //[self createRightBarButton];
    
    _names = @[@"@我的",@"收到的评论",@"收到的赞",@"通知"];
    _imgs = @[@"msg_my.png",@"msg_comments.png",@"msg_praise.png",@"msg_noti.png"];
    [self createTableViewAndRequestAction:nil Param:nil Header:NO Foot:NO];
    [self.tableView setAutoresizingMask:UIViewAutoresizingNone];
    [self.tableView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 50)];
    [self.tableView setBackgroundColor:CreateColor(241, 242, 245)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)createRightBarButton
{
    UIButton *rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setFrame:CGRectMake(0, 0, 15 + 25, 15 + 20)];
    [rightBut setImage:CREATE_IMG(@"msg_add") forState:UIControlStateNormal];
    [rightBut setImageEdgeInsets:UIEdgeInsetsMake(10, 25, 10, 0)];
    [rightBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBut setTitleColor:TextSelectColor forState:UIControlStateHighlighted];
    [rightBut addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBut setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    [self.navigationItem setRightBarButtonItems:@[rightItem] animated:YES];
}

- (void)addAction:(id)sender
{
    
}

- (void)createFooterView
{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64 - 50, SCREEN_WIDTH, 50)];
    [footView setBackgroundColor:CreateColor(241, 242, 245)];
    [footView setUserInteractionEnabled:YES];
    [self.view addSubview:footView];
    
    UILabel *wline = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    [wline setBackgroundColor:CreateColor(237, 237, 239)];
    [footView addSubview:wline];
    
    for (int i = 0; i < 2; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //79  66
        [btn setImage:CREATE_IMG((i == 0) ? @"msg_btn_msg" : @"msg_btn_friend") forState:UIControlStateNormal];
        [btn setFrame:CGRectMake(SCREEN_WIDTH / 2 * i, wline.frameBottom, SCREEN_WIDTH / 2, 49)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(7, (SCREEN_WIDTH / 2 - 79.0 / 3) / 2, 49 - 22 - 7, (SCREEN_WIDTH / 2 - 79.0 / 3) / 2)];
        [footView addSubview:btn];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(btn.frameX, 29, btn.frameWidth, 20)];
        [tipLabel setBackgroundColor:[UIColor clearColor]];
        [tipLabel setText:(i == 0) ? @"消息" : @"童友"];
        [tipLabel setTextColor:(i == 0) ? CreateColor(146, 110, 253) : CreateColor(86, 86, 86)];
        [tipLabel setTextAlignment:NSTextAlignmentCenter];
        [tipLabel setFont:[UIFont systemFontOfSize:12]];
        [footView addSubview:tipLabel];
    }
    
    UILabel *hline = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, wline.frameBottom, 1, 49)];
    [hline setBackgroundColor:CreateColor(237, 237, 239)];
    [footView addSubview:hline];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *msgCellId = @"messageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:msgCellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:msgCellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = rgba(86, 86, 86, 1);
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    }
    
    cell.imageView.image = [UIImage imageNamed:_imgs[indexPath.row]];
    cell.textLabel.text = _names[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

@end
