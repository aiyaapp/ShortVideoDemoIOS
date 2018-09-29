//
//  AYRecordFaceEffectPlane.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/24.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "AYRecordFaceEffectPlane.h"
#import "AYRecordPlaneCollectionViewCell.h"

#import <Masonry/Masonry.h>
#import <pop/POP.h>

#define RECORD_FACE_EFFECT_PLANE_CELL @"RECORD_FACE_EFFECT_PLANE_CELL"

@interface AYRecordFaceEffectPlane()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *hideViewTrigger;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation AYRecordFaceEffectPlane

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
        self.hidden = YES;
    }
    return self;
}

- (void)setupView{
    _contentView = [[UIView alloc] init];
    
    _hideViewTrigger = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hideViewTrigger setBackgroundColor:[UIColor clearColor]];
    [self.hideViewTrigger addTarget:self action:@selector(onHideViewTiggerClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *titleLayout = [UIView new];
    [titleLayout setBackgroundColor:[UIColor blackColor]];
    
    UILabel *titleLb = [UILabel new];
    [titleLb setText:@"人脸特效"];
    [titleLb setTextColor:[UIColor whiteColor]];
    [titleLb setFont:[UIFont systemFontOfSize:12]];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.pagingEnabled = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.allowsSelection = YES;
    [self.collectionView registerClass:[AYRecordPlaneCollectionViewCell class] forCellWithReuseIdentifier:RECORD_FACE_EFFECT_PLANE_CELL];
    
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.hideViewTrigger];
    [self.contentView addSubview:titleLayout];
    [titleLayout addSubview:titleLb];
    [self.contentView addSubview:self.collectionView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.hideViewTrigger mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(titleLayout.mas_top);
    }];
    
    [titleLayout mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.collectionView.mas_top);
        make.height.mas_equalTo(25);
    }];
    
    [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(titleLayout.mas_centerX);
        make.centerY.equalTo(titleLayout.mas_centerY);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(180);
    }];
}

#pragma mark - delegate, data source
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.collectionView.frame.size.width / 4.0f, self.collectionView.frame.size.width / 4.0f);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.dataArr) {
        return self.dataArr.count % 4 == 0 ? self.dataArr.count / 4 : self.dataArr.count / 4 + 1 ;
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.dataArr){
        return (self.dataArr.count - section * 4) > 4 ? 4 : (self.dataArr.count - section * 4);
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AYRecordPlaneCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RECORD_FACE_EFFECT_PLANE_CELL forIndexPath:indexPath];
    
    //设置是否被选中
    NSInteger selection = indexPath.section;
    FaceEffectModel *faceEffectModel = [self.dataArr objectAtIndex:selection * 4 + indexPath.row];
    [cell setSelected:[faceEffectModel.text isEqualToString:self.selectedText]];
    
    //设置数据
    [cell setThumbnail:faceEffectModel.thumbnail];
    [cell setText:faceEffectModel.text];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordFaceEffectPlaneSelectedModel:)]) {
        NSInteger selection = indexPath.section;
        [self.delegate recordFaceEffectPlaneSelectedModel:[self.dataArr objectAtIndex:selection * 4 + indexPath.row]];
    }
}

#pragma mark - API
- (void)hideUseAnim:(BOOL)hidden{
    
    if (!hidden){
        [self setHidden:hidden];
    }
    
    POPSpringAnimation *centerAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    centerAnim.springSpeed = 10;
    centerAnim.springBounciness = 6;
    
    if (hidden) {
        centerAnim.fromValue = [NSValue valueWithCGPoint:self.center];
        centerAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y + 205 + centerAnim.springBounciness )];
    }else {
        centerAnim.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y + 205 + centerAnim.springBounciness )];
        centerAnim.toValue = [NSValue valueWithCGPoint:self.center];
    }
    
    [centerAnim setCompletionBlock:^(POPAnimation *anim, BOOL complete) {
        if (complete && hidden) {
            [self setHidden:hidden];
        }
        
        if (complete && !hidden) {
            self.hideViewTrigger.enabled = YES;
        }
    }];
    
    self.hideViewTrigger.enabled = NO;
    [self.contentView pop_removeAllAnimations];
    [self.contentView pop_addAnimation:centerAnim forKey:nil];
}

- (void)setDataArr:(NSArray<FaceEffectModel *> *)dataArr{
    _dataArr = dataArr;
    
    [self.collectionView reloadData];
}

#pragma mark - Button Target
- (void)onHideViewTiggerClick:(UIButton *)bt{
    [self hideUseAnim:YES];
}

@end
