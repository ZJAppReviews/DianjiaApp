//
//  SupplierViewController.m
//  YHB_Prj
//
//  Created by Johnny's on 15/8/25.
//  Copyright (c) 2015年 striveliu. All rights reserved.
//

#import "SupplierViewController.h"
#import "SupplierTableViewCell.h"
#import "SupplierDetailViewController.h"
#import "SupplierManage.h"
#import "SVPullToRefresh.h"

@interface SupplierViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) UITableView *supplierTableView;
@property(nonatomic, strong) SupplierManage *manage;
@property(nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation SupplierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"供货商管理";
    
    _supplierTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-64) style:UITableViewStylePlain];
    _supplierTableView.backgroundColor = [UIColor whiteColor];
    _supplierTableView.delegate = self;
    _supplierTableView.dataSource = self;
    _supplierTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_supplierTableView];
    
    self.dataArray = [NSMutableArray arrayWithCapacity:0];
    
    [self addTableViewTrag];
    
    _manage = [[SupplierManage alloc] init];
    [_manage getSupplierListWithFinishBlock:^(NSArray *resultArr) {
        self.dataArray = [resultArr mutableCopy];
        [_supplierTableView reloadData];
    }];
}

#pragma mark 增加上拉下拉
- (void)addTableViewTrag
{
    __weak SupplierViewController *weakself = self;
    [weakself.supplierTableView addPullToRefreshWithActionHandler:^{
        [self.manage getSupplierListWithFinishBlock:^(NSArray *resultArr) {
            self.dataArray = [resultArr mutableCopy];
            [_supplierTableView reloadData];
            [weakself.supplierTableView.pullToRefreshView stopAnimating];
        }];
    }];
    
    
//    [weakself.supplierTableView addInfiniteScrollingWithActionHandler:^{
//        [weakself.supplierTableView.infiniteScrollingView stopAnimating];
//    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SupplierTableViewCell heightForSupplierCell];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"SupplierCell";
    SupplierTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"SupplierTableViewCell" bundle:nil] forCellReuseIdentifier:cellId];
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    SupplierMode *mode = [self.dataArray objectAtIndex:indexPath.row];
    [cell setCellWithSupplierMode:mode];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SupplierTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.cellImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"mine_menu_%d", (int)indexPath.row]];
    //    cell.cellTitleLabel.text = _cellTitleArray[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    SupplierMode *mode = [self.dataArray objectAtIndex:indexPath.row];
    SupplierDetailViewController *vc = [[SupplierDetailViewController alloc] initWithSupplierMode:mode withDeleteBlock:^{
        [_dataArray removeObjectAtIndex:indexPath.row];
        [_supplierTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } withChangeBlock:^(SupplierMode *aMode) {
        [_dataArray replaceObjectAtIndex:indexPath.row withObject:aMode];
        [_supplierTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end