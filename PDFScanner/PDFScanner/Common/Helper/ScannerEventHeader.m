

#import "ScannerEventHeader.h"

/*
//welcome页面
NSString * const welcome_page_view = @"welcome_page_view";
NSString * const welcome_close_click = @"welcome_close_click";
NSString * const welcome_continue_click = @"welcome_continue_click";
*/

// home页面
NSString * const home_page_view = @"home_page_view";//主页显示
NSString * const home_setting_click = @"home_setting_click";//左上角设置按钮点击
NSString * const home_create_folder_click = @"home_create_folder_click";//右上角创建文件夹点击
NSString * const home_list_click = @"home_list_click";//右上角列表模式点击
NSString * const home_grid_click = @"home_grid_click";//右上角网格模式点击
NSString * const home_select_mode_click = @"home_select_mode_click";//右上角select模式点击
NSString * const home_capture_click = @"home_capture_click";//开始扫描
NSString * const home_file_click = @"home_file_click";//Docs中文件被打开的次数
NSString * const home_folder_click = @"home_folder_click";//Docs中文件夹被打开的次数
// Selected
NSString * const selected_page_view = @"selected_page_view";//主页显示
NSString * const selected_share_click = @"selected_share_click";//tabbar中share 被点击
NSString * const selected_share_png_click = @"selected_share_png_click";//share 菜单中share with png 点击
NSString * const selected_share_pdf_click = @"selected_share_pdf_click";//share 菜单中share with pdf 点击
NSString * const selected_move_click = @"selected_move_click";//tabbar中move 被点击
NSString * const selected_delete_click = @"selected_delete_click";//tabbar中delete 被点击

// 扫描step1
NSString * const scanner_step1_view = @"scanner_step1_view";//扫描step1 页面显示
NSString * const scanner_step1_auto_click = @"scanner_step1_auto_click";//扫描step1中auto点击
NSString * const scanner_step1_manual_click = @"scanner_step1_manual_click";//扫描step1中Manual点击
NSString * const scanner_step1_capture_click = @"scanner_step1_capture_click";//扫描step1中点击拍照
NSString * const scanner_step1_cature_file_click = @"scanner_step1_cature_file_click";//扫描step1中右下角点击选择图片

// 扫描step2
NSString * const scanner_step2_view = @"scanner_step2_view";//扫描step2页面显示
NSString * const scanner_step2_clip_click = @"scanner_step2_clip_click";//扫描step2中四角上有裁剪行为
NSString * const scanner_step2_all_click = @"scanner_step2_all_click";//扫描step2中底部all点击
NSString * const scanner_step2_left_click = @"scanner_step2_left_click";//扫描step2中底部left点击
NSString * const scanner_step2_right_click = @"scanner_step2_right_click";//扫描step2中底部right点击
NSString * const scanner_step2_continue_click = @"scanner_step2_continue_click";//扫描step2中底部continue点击

// 扫描step3
NSString * const scanner_step3_view = @"scanner_step3_view";//扫描step3页面显示
NSString * const scanner_step3_filter_original_ret = @"scanner_step3_filter_original_ret";//扫描step3中filter滤镜done后选择了original
NSString * const scanner_step3_filter_scans_ret = @"scanner_step3_filter_scans_ret";//扫描step3中filter滤镜done后选择了scans
NSString * const scanner_step3_filter_magic_ret = @"scanner_step3_filter_magic_ret";//扫描step3中filter滤镜done后选择了magic
NSString * const scanner_step3_filter_bw_ret = @"scanner_step3_filter_bw_ret";//扫描step3中filter滤镜done后选择了b&w
NSString * const scanner_step3_filter_grayscale_ret = @"scanner_step3_filter_grayscale_ret";//扫描step3中filter滤镜done后选择了grayscale
NSString * const scanner_step3_filter_threshold_ret = @"scanner_step3_filter_threshold_ret";//扫描step3中filter滤镜done后选择了threshold
NSString * const scanner_step3_turn_click = @"scanner_step3_turn_click";//扫描step3中底部turn点击
NSString * const scanner_step3_brightness_click = @"scanner_step3_brightness_click";//扫描step3中底部brightness点击
NSString * const scanner_step3_contrast_click = @"scanner_step3_contrast_click";//扫描step3中底部contrast点击
NSString * const scanner_step3_done_click = @"scanner_step3_done_click";//扫描step3中底部done点击

// 文件详情页
NSString * const file_page_view = @"file_page_view";//文件详情页面显示
NSString * const file_add_new_click = @"file_add_new_click";//文件详情页下部，新增单页的加号按钮，点击
NSString * const file_share_click = @"file_share_click";//文件详情页tabbar中，share点击
NSString * const file_share_png_click = @"file_share_png_click";//share菜单中，share png 图片
NSString * const file_share_pdf_click = @"file_share_pdf_click";//share菜单中，share pdf 文件
NSString * const file_edit_click = @"file_edit_click";//文件详情页tabbar中, 重新编辑edit，点击
NSString * const file_sign_click = @"file_sign_click";//文件详情页tabbar中, sign 点击
NSString * const file_sign_continue_click = @"file_sign_continue_click";//sign 子页中，continue按钮 点击
NSString * const file_ocr_click = @"file_ocr_click";//文件详情页tabbar中, ocr 点击

// OCR结果页面
NSString * const ocr_page_view = @"ocr_page_view";//ocr页面显示
NSString * const ocr_language_click = @"ocr_language_click";//tabbar里 选择language，点击
NSString * const ocr_language_download = @"ocr_language_download";//language选择页中，哪一个语言被下载(***, 替换为国家代码cn,fr,de,it .......
NSString * const ocr_language_download_success = @"ocr_language_download_success";//language选择页中，哪一个语言被下载(***, 替换为国家代码cn,fr,de,it ......., 下载成功
NSString * const ocr_copy_click = @"ocr_copy_click";//tabbar里 copy 点击
NSString * const ocr_share_click = @"ocr_share_click";//tabbar里 share 点击
NSString * const ocr_share_txt_click = @"ocr_share_txt_click";//share菜单里，share with txt 点击
NSString * const ocr_share_png_click = @"ocr_share_png_click";//share菜单里，share with png 点击
NSString * const ocr_share_pdf_click = @"ocr_share_pdf_click";//share菜单里，share with pdf 点击

//引导页
NSString * const guide_page_view = @"guide_page_view";
NSString * const guide_close_click = @"guide_close_click";

NSString * const guide_show_package = @"guide_show_package";

NSString * const guide_subscribe_click = @"guide_subscribe_click";
NSString * const guide_subscribe_success = @"guide_subscribe_success";
NSString * const guide_subscribe_failure = @"guide_subscribe_failure";
NSString * const guide_subscribe_verifySuccess = @"guide_subscribe_verifySuccess";
NSString * const guide_subscribe_verifyFailure = @"guide_subscribe_verifyFailure";

NSString * const guide_trail_w_click = @"guide_trail_w_click";
NSString * const guide_trail_w_success = @"guide_trail_w_success";
NSString * const guide_trail_w_failure = @"guide_trail_w_failure";
NSString * const guide_trail_w_verifySuccess = @"guide_trail_w_verifySuccess";
NSString * const guide_trail_w_verifyFailure = @"guide_trail_w_verifyFailure";


NSString * const guide_trail_m_click = @"guide_trail_m_click";
NSString * const guide_trail_m_success = @"guide_trail_m_success";
NSString * const guide_trail_m_failure = @"guide_trail_m_failure";
NSString * const guide_trail_m_verifySuccess = @"guide_trail_m_verifySuccess";
NSString * const guide_trail_m_verifyFailure = @"guide_trail_m_verifyFailure";


NSString * const guide_trail_y_click = @"guide_trail_y_click";
NSString * const guide_trail_y_success = @"guide_trail_y_success";
NSString * const guide_trail_y_failure = @"guide_trail_y_failure";
NSString * const guide_trail_y_verifySuccess = @"guide_trail_y_verifySuccess";
NSString * const guide_trail_y_verifyFailure = @"guide_trail_y_verifyFailure";

//引导页中因为网络等原因没有返回数据的错误
NSString * const guide_trail_w_unusualFailure = @"guide_trail_w_unusualFailure";
NSString * const guide_trail_m_unusualFailure = @"guide_trail_m_unusualFailure";
NSString * const guide_trail_y_unusualFailure = @"guide_trail_y_unusualFailure";
NSString * const guide_subscribe_unusualFailure = @"guide_subscribe_unusualFailure";

NSString * const guide_page_view1 = @"guide_page_view1";
NSString * const guide_page_view2 = @"guide_page_view2";
NSString * const guide_page_view3 = @"guide_page_view3";

//内购推广
NSString * const internal_purchase_extension = @"internal_purchase_extension";

//主付费页
NSString * const main_purchase_page_view = @"main_purchase_page_view";
NSString * const main_purchase_close_click = @"main_purchase_close_click";

NSString * const main_purchase_click = @"main_purchase_click";
NSString * const main_purchase_success = @"main_purchase_success";
NSString * const main_purchase_failure = @"main_purchase_failure";
NSString * const main_purchase_verifySuccess = @"main_purchase_verifySuccess";
NSString * const main_purchase_verifyFailure = @"main_purchase_verifyFailure";

NSString * const main_purchase_w_click = @"main_purchase_w_click";
NSString * const main_purchase_w_success = @"main_purchase_w_success";
NSString * const main_purchase_w_failure = @"main_purchase_w_failure";
NSString * const main_purchase_w_verifySuccess = @"main_purchase_w_verifySuccess";
NSString * const main_purchase_w_verifyFailure = @"main_purchase_w_verifyFailure";

NSString * const main_purchase_y_click = @"main_purchase_y_click";
NSString * const main_purchase_y_success = @"main_purchase_y_success";
NSString * const main_purchase_y_failure = @"main_purchase_y_failure";
NSString * const main_purchase_y_verifySuccess = @"main_purchase_y_verifySuccess";
NSString * const main_purchase_y_verifyFailure = @"main_purchase_y_verifyFailure";

//主付费页因为网络等原因没有返回数据的错误
NSString * const main_purchase_w_unusualFailure = @"main_purchase_w_unusualFailure";
NSString * const main_purchase_y_unusualFailure = @"main_purchase_y_unusualFailure";
NSString * const main_purchase_unusualFailure = @"main_purchase_unusualFailure";

//设置中回复
NSString * const setting_restore_click = @"setting_restore_click";
NSString * const setting_restore_success = @"setting_restore_success";
NSString * const setting_restore_failure = @"setting_restore_failure";
NSString * const setting_restore_verifySuccess = @"setting_restore_verifySuccess";
NSString * const setting_restore_verifyFailure = @"setting_restore_verifyFailure";

//整个app，购买总事件
NSString * const app_purchase_total_click = @"app_purchase_total_click";
NSString * const app_purchase_total_success = @"app_purchase_total_success";
NSString * const app_purchase_total_failure = @"app_purchase_total_failure";
NSString * const app_purchase_total_verifySuccess = @"app_purchase_total_verifySuccess";
NSString * const app_purchase_total_verifyFailure = @"app_purchase_total_verifyFailure";
//app内，因为网络等原因没有返回数据的错误
NSString * const app_purchase_total_unusualFailure = @"app_purchase_total_unusualFailure";

//掉单
NSString * const app_purchaseLoss_total_verifySuccess = @"app_purchaseLoss_total_verifySuccess";
NSString * const app_purchaseLoss_total_verifyFailure = @"app_purchaseLoss_total_verifyFailure";
NSString * const app_purchaseLoss_total_unusualFailure = @"app_purchaseLoss_total_unusualFailure";


/*************************************  分割线  *************************************/

NSString * const UPApplicationID = @"83h2f6xi2ayo";
NSString * const guide_trail_w_click_token = @"76ix5v";
NSString * const guide_trail_w_success_token = @"qhfi9w";
NSString * const guide_trail_m_click_token = @"alk1xw";
NSString * const guide_trail_m_success_token = @"qbou3r";
NSString * const guide_trail_y_click_token = @"bia7rn";
NSString * const guide_trail_y_success_token = @"j0r0vp";
NSString * const guide_trail_click_token = @"q9qrzi";
NSString * const guide_trail_success_token = @"zh8nc2";

NSString * const main_purchase_y_click_token = @"u3chfx";
NSString * const main_purchase_y_success_token = @"zahzqv";
NSString * const main_purchase_w_click_token = @"vk1ap6";
NSString * const main_purchase_w_success_token = @"dir8lh";
NSString * const main_purchase_click_token = @"38xl62";
NSString * const main_purchase_success_token = @"qqdy7y";

NSString * const app_purchase_total_click_token = @"fje3lw";
NSString * const app_purchase_total_success_token = @"udzdvo";

/*************************************  分割线  *************************************/