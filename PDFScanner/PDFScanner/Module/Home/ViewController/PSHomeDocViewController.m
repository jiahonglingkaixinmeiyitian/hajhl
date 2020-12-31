//
//  PSHomeDocViewController.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSHomeDocViewController.h"
#import "PSSettingViewController.h"
#import "PSDocGridCell.h"
#import "PSDocListCell.h"
#import "PSDocHeaderView.h"
#import "PSFileModel.h"
#import "PSDocEditView.h"
#import "PSLockAppDialog.h"
#import "PSKeyChainHelper.h"
#import <PDFScanner-Swift.h>
#import "PSTrainedDataDownloader.h"
#import "PSBottomListDrawer.h"
#import "PSPDFUtil.h"
#import "PSShareHelper.h"
#import "PSMoveDirectoryDrawer.h"
#import "NSDate+String.h"
#import "PSMoveToRootDirectoryDrawer.h"
#import "PSSubscriptionGuideViewController.h"

typedef NS_ENUM(NSInteger, PSHomeDocLayout) {
    PSHomeDocLayoutGrid = 0,
    PSHomeDocLayoutList,
};

static NSInteger kGridColumnCount = 3; // 一行3列
static CGFloat kLayoutMargin = 24.f;
static CGFloat kInterItemSpacing = 16.f;
static CGFloat kHeaderHeight = 60.f;

@interface PSHomeDocViewController ()<ImageScannerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, PSDocEditViewDelegate>

/// Normal
@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIBarButtonItem *settingItem;
@property (nonatomic, strong) UIBarButtonItem *addDirItem;
@property (nonatomic, strong) UIBarButtonItem *layoutItem;
@property (nonatomic, strong) UIButton *layoutButton;
@property (nonatomic, strong) UIBarButtonItem *selectionItem;
/// Selection
@property (nonatomic, strong) UIBarButtonItem *cancelItem;
@property (nonatomic, strong) UIBarButtonItem *doneItem;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) PSDocEditView *editView;

/// state
@property (nonatomic, assign) PSHomeDocLayout doclayout; // default to Grid
@property (nonatomic, assign) BOOL isInSelection; // 是否处于选择状态，默认NO

@property (nonatomic, strong) PSFileModel *currentDirectory;    // 处于当前这个目录
@property (nonatomic, strong) RLMNotificationToken *notiToken; // 监听目录个数-空白页

@end

@implementation PSHomeDocViewController

-(void)dealloc {
    [_notiToken invalidate];
    _notiToken = nil;
}

- (instancetype)initWithDirectory:(PSFileModel *)directory {
    if (self = [super init]) {
        self.currentDirectory = directory;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.navigationController.viewControllers.count == 1) {
        [self launchHandle];
    }
    [ScannerEventManager eventWithName:home_page_view parameters:nil];
    [self checkAppLockStatus];
    [self addGestures];
    [self addNotifications];
    [self configNavigationItems];
    [self configViews];
}

-(void)launchHandle{
//    PSSubscriptionGuideViewController *guidePage = [[PSSubscriptionGuideViewController alloc]init];
//    [self.navigationController pushViewController:guidePage animated:NO];
//    return;
//    用户第一次下载或者删除后再次下载，或者升级，并且是非VIP时，显示引导页
    if ([USER().appVersion?:@"0.0.0" compare:AppVersion] == NSOrderedAscending&&!USER().is_vip) {
        PSSubscriptionGuideViewController *guidePage = [[PSSubscriptionGuideViewController alloc]init];
        [self.navigationController pushViewController:guidePage animated:NO];
        
        [[PSUserInfoManager sharedInstance] setAppVersion:AppVersion];;
    }else{
//        if (!USER().is_vip) {
//            UPLaunchController *launch = [[UPLaunchController alloc]init];
//            [self.navigationController pushViewController:launch animated:NO];
//        }
    }
//
//    [[UPUpdateApp sharedInstance] appUpdate];
//
////    内购推广
//    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"AppStorePurchaseExtension" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
//        if (!USER().is_vip) {
//            if (!self.isExtension) {
//             self.needExtension = YES;
//            }else{
//                [self goIntoPurchaseController:YES];//广告关闭后，才收到内购推广时弹出
//            }
//        }
//    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];   // 刷新
}

- (void)checkAppLockStatus {
    if (self.currentDirectory.isRoot && [PSKeyChainHelper passwordForAppLock]) {
        PSLockAppDialog *dialog = [[PSLockAppDialog alloc] initWithType:PSLockAppTypeUnlock];
        [self presentViewController:dialog animated:NO completion:nil];
    }
}

- (void)addGestures {
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.collectionView addGestureRecognizer:gesture];
}

- (void)addNotifications {
    WS(ws)
    self.notiToken = [self.currentDirectory.fileOrDirs addNotificationBlock:^(RLMArray<PSFileModel *> * _Nullable array, RLMCollectionChange * _Nullable changes, NSError * _Nullable error) {
        if (!array.isInvalidated) {
            ws.emptyImageView.hidden = array.count > 0;
        }
        RLMResults<PSFileModel *> *selectedModels = [ws.currentDirectory.fileOrDirs objectsWhere:@"isSelected == true"];
        [ws.editView operationSelection:(selectedModels.count > 0)];
        [ws.collectionView reloadData];
    }];
}

- (void)configNavigationItems {
    if (self.isInSelection) {
        self.navigationItem.leftBarButtonItem = self.cancelItem;
        self.navigationItem.rightBarButtonItems = @[self.doneItem];
    } else {
        if (self.currentDirectory.isRoot) {
            self.navigationItem.leftBarButtonItem = self.settingItem;
            self.navigationItem.rightBarButtonItems = @[self.selectionItem, self.layoutItem, self.addDirItem];
        } else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
            // 二级目录不能添加子目录，目前设计只有两级，不过也支持多级目录
            self.navigationItem.rightBarButtonItems = @[self.selectionItem, self.layoutItem /*, self.addDirItem */ ];
        }
        
    }
}

- (void)configViews {
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.view addSubview:self.editView];
    [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_bottom);
    }];
    [self.view addSubview:self.emptyImageView];
    [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-89-AppSafeAreaInset.bottom);
    }];
    [self.view addSubview:self.scanButton];
    [self.scanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-58-AppSafeAreaInset.bottom);
        make.centerX.equalTo(self.view);
    }];
}

-(void)imageScannerControllerDidCancel:(ImageScannerController *)scanner{
    [scanner dismissViewControllerAnimated:true completion:nil];
}

-(void)editScanStepTwoDoneWithImage:(UIImage *)image scanner:(ImageScannerController *)scanner edit:(BOOL)edit{
    [scanner dismissViewControllerAnimated:true completion:nil];
    if (!edit) {
        // 用户拍照、选择照片处理后点击done按钮后，自动弹出刚才添加的文件
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
}

-(void)imageScannerController:(ImageScannerController *)scanner didFailWithError:(NSError *)error{
//    [scanner dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Action Methods

- (void)longPressed:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:[gesture locationInView:self.collectionView]];
            if (selectedIndexPath) {
                [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectedIndexPath];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            [self.collectionView updateInteractiveMovementTargetPosition:[gesture locationInView:gesture.view]];
            break;
        case UIGestureRecognizerStateEnded:
            [self.collectionView endInteractiveMovement];
            break;
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}

- (void)openSettingVC:(id)sender {

    [ScannerEventManager eventWithName:home_setting_click parameters:nil];
    PSSettingViewController *vc = [[PSSettingViewController alloc] init];
    [self presentViewController:WrapInNavigationBar(vc) animated:YES completion:nil];
}

- (void)scanAction:(id)sender {
    [ScannerEventManager eventWithName:home_capture_click parameters:nil];
    ImageScannerController *nvc = [[ImageScannerController alloc] initWithDelegate:self];
    nvc.modalPresentationStyle = UIModalPresentationFullScreen;
    nvc.selectedDirectory = self.currentDirectory;
    nvc.titleStr = [NSString stringWithFormat:@"New doc %@", [NSDate getCurrentEnglishDateStr]];
    [self presentViewController:nvc animated:true completion:nil];
}

- (void)addFolder:(id)sender {
    
    [ScannerEventManager eventWithName:home_create_folder_click parameters:nil];
    UIAlertController *addDirDialog = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"homefolder.create_new_folder.title", nil) message:NSLocalizedString(@"homefolder.create_new_folder.message", nil) preferredStyle:UIAlertControllerStyleAlert];
    [addDirDialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"homefolder.create_new_folder.placeholder", nil);
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"homefolder.create_new_folder.cancel.text", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"homefolder.create_new_folder.confirm.text", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self _createDirectory:addDirDialog.textFields.firstObject.text];
    }];
    [addDirDialog addAction:cancelAction];
    [addDirDialog addAction:createAction];
    [self presentViewController:addDirDialog animated:YES completion:nil];
}

- (void)selection:(id)sender {
    [ScannerEventManager eventWithName:home_select_mode_click parameters:nil];
    self.isInSelection = YES;
}

- (void)cancelSelection:(id)sender {
    self.isInSelection = NO;
}

- (void)clickDone:(id)sender {
    self.isInSelection = NO;
}

- (void)changeLayout:(id)sender {
    
    if (self.doclayout == PSHomeDocLayoutGrid) {
        [ScannerEventManager eventWithName:home_grid_click parameters:nil];
        self.doclayout = PSHomeDocLayoutList;
        [self.layoutButton setImage:[UIImage imageNamed:@"home_directory_grid_item"] forState:UIControlStateNormal];
    } else {
        [ScannerEventManager eventWithName:home_list_click parameters:nil];
        self.doclayout = PSHomeDocLayoutGrid;
        [self.layoutButton setImage:[UIImage imageNamed:@"home_directory_list_item"] forState:UIControlStateNormal];
    }
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
        // do something on completion
    }];
}

- (void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_createDirectory:(NSString *)directoryName {
    NSString *trimmedDirName = [directoryName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedDirName.length == 0) {
        [self ps_showHint:@"Directory name can't be empty"];
        return;
    }
    RLMRealm *realm = [RLMRealm defaultRealm];

    PSFileModel *dir = [[PSFileModel alloc] init];
    dir.name = trimmedDirName;
    dir.isDir = YES;
    
    [realm transactionWithBlock:^{
        [self.currentDirectory.fileOrDirs insertObject:dir atIndex:0]; // 放到最前面
        [realm addObject:dir];
    }];
    
    [self.collectionView performBatchUpdates:^{
        //
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
    } completion:^(BOOL finished) {
        [self.collectionView reloadData];
    }];
    
}

- (void)_clearSelection {
    // clean selection
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        for (PSFileModel *model in self.currentDirectory.fileOrDirs) {
            model.isSelected = NO;
        }
    }];
}

- (void)_showEditView:(BOOL)show {
    [UIView animateWithDuration:0.25 animations:^{
        self.scanButton.alpha = show ? 0 : 1.f;
        CGFloat editViewHeight = [self.editView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        [self.editView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_bottom).offset(show ? -editViewHeight : 0);
        }];
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, show ? editViewHeight : 0, 0);
        [self.view layoutIfNeeded];
    }];
}

- (void)_deleteDirOrFiles:(id<NSFastEnumeration>)models {
        
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"Selected files(s) will be deleted permanently!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    WS(ws)
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        //
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm deleteObjects:models];
        }];
        ws.isInSelection = NO;
    }];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)_shareWithIndex:(NSInteger)index {

    RLMResults<PSFileModel *> *selectedFolders = [self.currentDirectory.dirs objectsWhere:@"isSelected == true"];
    if (selectedFolders.count > 0) {
        [self ps_showHint:@"Folder(s) can not be shared."];
        return;
    }
    RLMResults<PSFileModel *> *selectedFiles = [self.currentDirectory.files objectsWhere:@"isSelected == true"];
    if (selectedFiles.count == 0) {
        [self ps_showHint:@"Please at least select one file."];
        return;
    }
    
    NSMutableArray *items = @[].mutableCopy;
    NSMutableArray *fileNames = @[].mutableCopy;
    if (index == 0) {
        // png
        for (PSFileModel *file in selectedFiles) {
            NSInteger i = 1;
            for (NSData *imageData in file.imageDatas) {
                [items addObject:imageData];
                [fileNames addObject:[NSString stringWithFormat:@"%@_%ld.png", file.name, i]];
                i++;
            }
        }
    } else {
        // pdf
        for (PSFileModel *file in selectedFiles) {
            NSData *pdfData = [PSPDFUtil generatePDFDataWithImageDatas:(NSArray *)file.imageDatas];
            [items addObject:pdfData];
            [fileNames addObject:[NSString stringWithFormat:@"%@.pdf", file.name]];
        }
    }
    [PSShareHelper shareWithDatas:items fileNames:fileNames inViewController:self];
}

- (void)_changeNameDialog:(PSFileModel *)model {
    UIAlertController *changeNameDialog = [UIAlertController alertControllerWithTitle:model.isDir ? @"Change folder name" : @"Change file name" message:model.isDir ? @"Type new folder name below" : @"Type new file name below" preferredStyle:UIAlertControllerStyleAlert];
    [changeNameDialog addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = model.name;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self _changeName:changeNameDialog.textFields.firstObject.text model:model];
    }];
    [changeNameDialog addAction:cancelAction];
    [changeNameDialog addAction:createAction];
    [self presentViewController:changeNameDialog animated:YES completion:nil];
}

- (void)_changeName:(NSString *)newName model:(PSFileModel *)model {
    NSString *trimmedDirName = [newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedDirName.length == 0) {
        [self ps_showHint:model.isDir ? @"Folder name can't be empty" : @"File name can't be empty"];
        return;
    }
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        model.name = trimmedDirName;
    }];
    [self.collectionView reloadData];
}

#pragma mark - PSDocEditViewDelegate

- (void)clickShareButtonWithEditView:(PSDocEditView *)editView {
    [ScannerEventManager eventWithName:selected_share_click parameters:nil];
    RLMResults<PSFileModel *> *selectedFiles = [self.currentDirectory.files objectsWhere:@"isSelected == true"];
    if (selectedFiles.count == 0) {
        [self ps_showHint:@"Please at least select a file."];
        return;
    }
    
    PSBottomListDrawer *drawer = [[PSBottomListDrawer alloc] initWithItems:@[@{@"leftName": @"home_share_png_icon", @"rightText": @"Share with PNG"}, @{@"leftName": @"home_share_pdf_icon", @"rightText": @"Share with PDF"}]];
    [drawer setPickListItemBlock:^(NSInteger itemIndex) {
        if (itemIndex == 0) {
            [ScannerEventManager eventWithName:selected_share_png_click parameters:nil];
        } else if (itemIndex == 1) {
            [ScannerEventManager eventWithName:selected_share_pdf_click parameters:nil];
        }
        [self _shareWithIndex:itemIndex];
    }];
    [drawer presentToKeyWindow];
}

- (void)clickMoveButtonWithEditView:(PSDocEditView *)editView {
    
    [ScannerEventManager eventWithName:selected_move_click parameters:nil];
    /// 忽略选中的文件夹
    RLMResults<PSFileModel *> *selectedFiles = [self.currentDirectory.files objectsWhere:@"isSelected == true"];
    if (selectedFiles.count == 0) {
        [self ps_showHint:@"Please at least select a file."];
        return;
    }
    if (self.currentDirectory.isRoot) {
        PSMoveDirectoryDrawer *drawer = [[PSMoveDirectoryDrawer alloc] initWithCurrentDirectory:self.currentDirectory movingFiles:selectedFiles];
        [drawer setMoveDirSuccessBlock:^{
            self.isInSelection = NO;    // 移动操作结束后取消选择
        }];
        [drawer presentToKeyWindow];
    } else {
        PSMoveToRootDirectoryDrawer *drawer = [[PSMoveToRootDirectoryDrawer alloc] initWithMovingFiles:selectedFiles];
        [drawer setMoveDirSuccessBlock:^{
            self.isInSelection = NO;
        }];
        [drawer presentToKeyWindow];
    }
}

- (void)clickDeleteButtonWithEditView:(PSDocEditView *)editView {
    [ScannerEventManager eventWithName:selected_delete_click parameters:nil];
    RLMResults<PSFileModel *> *selectedModels = [self.currentDirectory.fileOrDirs objectsWhere:@"isSelected == true"];
    [self _deleteDirOrFiles:selectedModels];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) {
        return;
    }
    if (scrollView.contentOffset.y < kHeaderHeight / 2) {
        [scrollView setContentOffset:CGPointZero animated:YES];
    } else if (scrollView.contentOffset.y <= kHeaderHeight) {
        [scrollView setContentOffset:CGPointMake(0, kHeaderHeight) animated:YES];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PSFileModel *model = self.currentDirectory.fileOrDirs[indexPath.item];
    if (self.isInSelection) {
        // 选择状态不可点击
        return;
    }
    if (model.isDir) {
        // 如果是目录，跳转到下一级
        [ScannerEventManager eventWithName:home_folder_click parameters:nil];
        PSHomeDocViewController *vc = [[PSHomeDocViewController alloc] initWithDirectory:model];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        // 文件，进入到文件
        [ScannerEventManager eventWithName:home_file_click parameters:nil];
        NSMutableArray<UIImage *> *arr = [NSMutableArray array];
        for (NSData *imageData in model.imageDatas) {
            [arr addObject:[UIImage imageWithData:imageData]];
            
        }
        EditScanStepThreeVC *threeVC = [[EditScanStepThreeVC alloc] init];
        threeVC.images = [arr copy];
        ImageScannerController *nvc = [[ImageScannerController alloc] initWithRootViewController:threeVC titleStr:model.name];
        nvc.selectedDirectory = model;
        nvc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nvc animated:true completion:nil];
       
    }
    
}

- (nullable UIContextMenuConfiguration *)collectionView:(UICollectionView *)collectionView contextMenuConfigurationForItemAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point API_AVAILABLE(ios(13.0)) {
    
    PSFileModel *model = self.currentDirectory.fileOrDirs[indexPath.item];
    if (self.isInSelection) {
        return nil; // 选择状态没有context menu
    }
    
    NSMutableArray *actions = @[].mutableCopy;
    WS(ws)
    UIAction *changeNameAction = [UIAction actionWithTitle:model.isDir ? @"Change folder name" : @"Change file name" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [ws _changeNameDialog:model];
    }];
    [actions addObject:changeNameAction];
    
    UIAction *deleteAction = [UIAction actionWithTitle:model.isDir ? @"Delete folder" : @"Delete file" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [ws _deleteDirOrFiles:@[model]];
    }];
    [actions addObject:deleteAction];
    
    UIAction *editAction = [UIAction actionWithTitle:@"Edit" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        ws.isInSelection = YES;
    }];
    [actions addObject:editAction];
    
    return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
        return [UIMenu menuWithTitle:@"Actions" children:actions];
    }];
}

#pragma mark - UICollectionViewDataSource

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.isInSelection;;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [self.currentDirectory.fileOrDirs moveObjectAtIndex:sourceIndexPath.item toIndex:destinationIndexPath.item];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentDirectory.fileOrDirs.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    
    if (self.doclayout == PSHomeDocLayoutGrid) {
        PSDocGridCell *gridCell = [collectionView dequeueReusableCellWithReuseIdentifier:[PSDocGridCell ps_reuseIdentifier] forIndexPath:indexPath];
        if (indexPath.item < self.currentDirectory.fileOrDirs.count) {
            [gridCell configWithModel:self.currentDirectory.fileOrDirs[indexPath.item] isEditMode:self.isInSelection];
        }
        cell = gridCell;
    } else {
        PSDocListCell *listCell = [collectionView dequeueReusableCellWithReuseIdentifier:[PSDocListCell ps_reuseIdentifier] forIndexPath:indexPath];
        if (indexPath.item < self.currentDirectory.fileOrDirs.count) {
            [listCell configWithModel:self.currentDirectory.fileOrDirs[indexPath.item] isEditMode:self.isInSelection];
        }
        cell = listCell;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        PSDocHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[PSDocHeaderView ps_reuseIdentifier] forIndexPath:indexPath];
        NSInteger count = self.currentDirectory.fileOrDirs.count;
        NSString *headerDocName = self.isInSelection ? @"Selected" : self.currentDirectory.name;
        [headerView updateDocName:headerDocName count:count];
        WS(ws)
        [headerView setChangeNameBlock:^{
            if (!ws.isInSelection) {
                [ws _changeNameDialog:ws.currentDirectory];
            }
        }];
        return headerView;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.doclayout == PSHomeDocLayoutGrid) {
        CGFloat itemWidth = (SCREEN_WIDTH - kLayoutMargin * 2 - (kGridColumnCount - 1) * kInterItemSpacing) / kGridColumnCount;
        CGFloat itemHeight = itemWidth / (111.f / 175.f);
        return CGSizeMake(itemWidth, itemHeight);
    } else {
        CGFloat itemWidth = SCREEN_WIDTH - kLayoutMargin * 2;
        CGFloat itemHeight = itemWidth / (366.f / 88.f);
        return CGSizeMake(itemWidth, itemHeight);
    }
}

#pragma mark - Property Getters

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        NSString *dirName = [NSString stringWithFormat:@" %@", self.currentDirectory.belongedDir.name];
        if (self.currentDirectory.belongedDir.name.length > 10) {
            dirName = [NSString stringWithFormat:@" %@...", [self.currentDirectory.belongedDir.name substringWithRange:NSMakeRange(0, 10)]];
        }
        [_backButton setTitle:dirName forState:UIControlStateNormal]; // 空一格间距
        [_backButton setImage:[UIImage imageNamed:@"navigation_back_icon"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setTitleColor:[UIColor themeColor] forState:UIControlStateNormal];
        _backButton.titleLabel.font = [UIFont appBoldFontSize:18.f];
    }
    return _backButton;
}

- (UIBarButtonItem *)settingItem {
    if (!_settingItem) {
        _settingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_directory_setting_item"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettingVC:)];
    }
    return _settingItem;
}

- (UIBarButtonItem *)addDirItem {
    if (!_addDirItem) {
        _addDirItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_directory_add_folder_item"] style:UIBarButtonItemStylePlain target:self action:@selector(addFolder:)];
    }
    return _addDirItem;
}

- (UIBarButtonItem *)layoutItem {
    if (!_layoutItem) {
        _layoutItem = [[UIBarButtonItem alloc] initWithCustomView:self.layoutButton];
    }
    return _layoutItem;
}

- (UIButton *)layoutButton {
    if (!_layoutButton) {
        _layoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _layoutButton.tintColor = [UIColor clearColor];
        [_layoutButton setImage:[UIImage imageNamed:@"home_directory_list_item"] forState:UIControlStateNormal];
        [_layoutButton addTarget:self action:@selector(changeLayout:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _layoutButton;
}

- (UIBarButtonItem *)selectionItem {
    if (!_selectionItem) {
        _selectionItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_directory_select_item"] style:UIBarButtonItemStylePlain target:self action:@selector(selection:)];
    }
    return _selectionItem;
}

- (UIBarButtonItem *)cancelItem {
    if (!_cancelItem) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"Cancel" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor themeColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont appBoldFontSize:18.f];
        [button addTarget:self action:@selector(cancelSelection:) forControlEvents:UIControlEventTouchUpInside];
        _cancelItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _cancelItem;
}

- (UIBarButtonItem *)doneItem {
    if (!_doneItem) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0xD13D1E) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont appBoldFontSize:18.f];
        [button addTarget:self action:@selector(clickDone:) forControlEvents:UIControlEventTouchUpInside];
        _doneItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return _doneItem;
}

- (UIButton *)scanButton {
    if (!_scanButton) {
        _scanButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_scanButton setImage:[UIImage imageNamed:@"home_directory_scan_button"] forState:UIControlStateNormal];
        [_scanButton addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanButton;
}

- (UIImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_directory_empty_icon"]];
        _emptyImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _emptyImageView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, kHeaderHeight);
        layout.minimumInteritemSpacing = kInterItemSpacing;
        layout.minimumLineSpacing = kInterItemSpacing;
        layout.sectionInset = UIEdgeInsetsMake(12, kLayoutMargin, 58+80+kLayoutMargin+AppSafeAreaInset.bottom, kLayoutMargin);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[PSDocHeaderView ps_nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[PSDocHeaderView ps_reuseIdentifier]];
        [_collectionView registerNib:[PSDocListCell ps_nib] forCellWithReuseIdentifier:[PSDocListCell ps_reuseIdentifier]];
        [_collectionView registerNib:[PSDocGridCell ps_nib] forCellWithReuseIdentifier:[PSDocGridCell ps_reuseIdentifier]];
    }
    return _collectionView;
}

- (PSDocEditView *)editView {
    if (!_editView) {
        _editView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([PSDocEditView class]) owner:self options:nil].firstObject;
        _editView.delegate = self;
    }
    return _editView;
}

- (void)setIsInSelection:(BOOL)isInSelection {
    _isInSelection = isInSelection;
    if (isInSelection) {
        [ScannerEventManager eventWithName:selected_page_view parameters:nil];
    }
    [self configNavigationItems];
    [self _showEditView:isInSelection];
    if (!isInSelection) {
        [self _clearSelection];
    }
    [self.collectionView reloadData];
}

@end
