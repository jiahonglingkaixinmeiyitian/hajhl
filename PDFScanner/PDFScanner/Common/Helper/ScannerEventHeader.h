#import <Foundation/Foundation.h>

/*
//welcome页面
extern NSString * const welcome_page_view;//welcome 页面显示
extern NSString * const welcome_close_click;//右上角按钮点击
extern NSString * const welcome_continue_click;//Continue 按钮点击

*/

// home页面
extern NSString * const home_page_view;//主页显示
extern NSString * const home_setting_click;//左上角设置按钮点击
extern NSString * const home_create_folder_click;//右上角创建文件夹点击
extern NSString * const home_list_click;//右上角列表模式点击
extern NSString * const home_grid_click;//右上角网格模式点击
extern NSString * const home_select_mode_click;//右上角select模式点击
extern NSString * const home_capture_click;//开始扫描
extern NSString * const home_file_click;//Docs中文件被打开的次数
extern NSString * const home_folder_click;//Docs中文件夹被打开的次数
// Selected
extern NSString * const selected_page_view;//主页显示
extern NSString * const selected_share_click;//tabbar中share 被点击
extern NSString * const selected_share_png_click;//share 菜单中share with png 点击
extern NSString * const selected_share_pdf_click;//share 菜单中share with pdf 点击
extern NSString * const selected_move_click;//tabbar中move 被点击
extern NSString * const selected_delete_click;//tabbar中delete 被点击

// 扫描step1
extern NSString * const scanner_step1_view;//扫描step1 页面显示
extern NSString * const scanner_step1_auto_click;//扫描step1中auto点击
extern NSString * const scanner_step1_manual_click;//扫描step1中Manual点击
extern NSString * const scanner_step1_capture_click;//扫描step1中点击拍照
extern NSString * const scanner_step1_cature_file_click;//扫描step1中右下角点击选择图片

// 扫描step2
extern NSString * const scanner_step2_view;//扫描step2页面显示
extern NSString * const scanner_step2_clip_click;//扫描step2中四角上有裁剪行为
extern NSString * const scanner_step2_all_click;//扫描step2中底部all点击
extern NSString * const scanner_step2_left_click;//扫描step2中底部left点击
extern NSString * const scanner_step2_right_click;//扫描step2中底部right点击
extern NSString * const scanner_step2_continue_click;//扫描step2中底部continue点击

// 扫描step3
extern NSString * const scanner_step3_view;//扫描step3页面显示
extern NSString * const scanner_step3_filter_original_ret;//扫描step3中filter滤镜done后选择了original
extern NSString * const scanner_step3_filter_scans_ret;//扫描step3中filter滤镜done后选择了scans
extern NSString * const scanner_step3_filter_magic_ret;//扫描step3中filter滤镜done后选择了magic
extern NSString * const scanner_step3_filter_bw_ret;//扫描step3中filter滤镜done后选择了b&w
extern NSString * const scanner_step3_filter_grayscale_ret;//扫描step3中filter滤镜done后选择了grayscale
extern NSString * const scanner_step3_filter_threshold_ret;//扫描step3中filter滤镜done后选择了threshold
extern NSString * const scanner_step3_turn_click;//扫描step3中底部turn点击
extern NSString * const scanner_step3_brightness_click;//扫描step3中底部brightness点击
extern NSString * const scanner_step3_contrast_click;//扫描step3中底部contrast点击
extern NSString * const scanner_step3_done_click;//扫描step3中底部done点击

// 文件详情页
extern NSString * const file_page_view;//文件详情页面显示
extern NSString * const file_add_new_click;//文件详情页下部，新增单页的加号按钮，点击
extern NSString * const file_share_click;//文件详情页tabbar中，share点击
extern NSString * const file_share_png_click;//share菜单中，share png 图片
extern NSString * const file_share_pdf_click;//share菜单中，share pdf 文件
extern NSString * const file_edit_click;//文件详情页tabbar中, 重新编辑edit，点击
extern NSString * const file_sign_click;//文件详情页tabbar中, sign 点击
extern NSString * const file_sign_continue_click;//sign 子页中，continue按钮 点击
extern NSString * const file_ocr_click;//文件详情页tabbar中, ocr 点击

// OCR结果页面
extern NSString * const ocr_page_view;//ocr页面显示
extern NSString * const ocr_language_click;//tabbar里 选择language，点击
extern NSString * const ocr_language_download;//language选择页中，哪一个语言被下载(***, 替换为国家代码cn,fr,de,it .......
extern NSString * const ocr_language_download_success;//language选择页中，哪一个语言被下载(***, 替换为国家代码cn,fr,de,it ......., 下载成功
extern NSString * const ocr_copy_click;//tabbar里 copy 点击
extern NSString * const ocr_share_click;//tabbar里 share 点击
extern NSString * const ocr_share_txt_click;//share菜单里，share with txt 点击
extern NSString * const ocr_share_png_click;//share菜单里，share with png 点击
extern NSString * const ocr_share_pdf_click;//share菜单里，share with pdf 点击


//引导页
extern NSString * const guide_page_view;//引导页面显示
extern NSString * const guide_close_click;//右上角关闭按钮点击

extern NSString * const guide_show_package;//用户打开引导页时，页面上显示出的套餐
//guide_show_package_US_week:意思是美国用户在引导页看到的是周套餐
//guide_show_package_US_month:意思是美国用户在引导页看到的是月套餐
//guide_show_package_US_year:意思是美国用户在引导页看到的是年套餐

//guide_show_package_BR_week:意思是巴西用户在引导页看到的是周套餐
//guide_show_package_BR_month:意思是巴西用户在引导页看到的是月套餐
//guide_show_package_BR_year:意思是巴西用户在引导页看到的是年套餐

//guide_show_package_other_week:意思是除了美国和巴西其他地区用户在引导页看到的是周套餐
//guide_show_package_other_month:意思是除了美国和巴西其他地区用户在引导页看到的是月套餐
//guide_show_package_other_year:意思是除了美国和巴西其他地区用户在引导页看到的是年套餐

//引导页中总事件
extern NSString * const guide_subscribe_click;//引导页订阅按钮点击(包含周套餐,月套餐,年套餐)
extern NSString * const guide_subscribe_success;//引导页订阅成功(包含周套餐,月套餐,年套餐)
extern NSString * const guide_subscribe_failure;//引导页订阅失败(包含周套餐,月套餐,年套餐)
extern NSString * const guide_subscribe_verifySuccess;//引导页订阅成功后，后台验证成功(包含周套餐,月套餐,年套餐)
extern NSString * const guide_subscribe_verifyFailure;//引导页订阅成功后，后台验证失败(包含周套餐,月套餐,年套餐)

extern NSString * const guide_trail_w_click;//4.99周套餐时，点击
extern NSString * const guide_trail_w_success;//4.99周套餐，trail成功
extern NSString * const guide_trail_w_failure;//4.99周套餐，trail失败--------
extern NSString * const guide_trail_w_verifySuccess;//4.99周套餐，trail成功后，后台验证成功--------
extern NSString * const guide_trail_w_verifyFailure;//4.99周套餐，trail成功后，后台验证失败--------

extern NSString * const guide_trail_m_click;//9.99月套餐时，点击
extern NSString * const guide_trail_m_success;//9.99月套餐，trail成功
extern NSString * const guide_trail_m_failure;//9.99月套餐，trail失败--------
extern NSString * const guide_trail_m_verifySuccess;//9.99月套餐，trail成功后，后台验证成功--------
extern NSString * const guide_trail_m_verifyFailure;//9.99月套餐，trail成功后，后台验证失败--------

extern NSString * const guide_trail_y_click;//39.99年套餐时，点击
extern NSString * const guide_trail_y_success;//39.99年套餐，trail成功
extern NSString * const guide_trail_y_failure;//39.99年套餐，trail失败--------
extern NSString * const guide_trail_y_verifySuccess;//39.99年套餐，trail成功后，后台验证成功--------
extern NSString * const guide_trail_y_verifyFailure;//39.99年套餐，trail成功后，后台验证失败--------

//引导页中因为网络等原因没有返回数据的错误
extern NSString * const guide_trail_w_unusualFailure;//引导页4.99周套餐，没有数据返回时的验证失败--------（）
extern NSString * const guide_trail_m_unusualFailure;//引导页9.99月套餐，没有数据返回时的验证失败--------（）
extern NSString * const guide_trail_y_unusualFailure;//引导页39.99年套餐，没有数据返回时的验证失败--------（）
extern NSString * const guide_subscribe_unusualFailure;//引导页所有套餐，没有数据返回时的验证失败--------（）

extern NSString * const guide_page_view1;//引导页面tab2显示
extern NSString * const guide_page_view2;//引导页面tab3显示
extern NSString * const guide_page_view3;//引导页面tab4显示



//内购推广
extern NSString * const internal_purchase_extension;//内购推广---------

//主付费页
extern NSString * const main_purchase_page_view;//主付费显示
extern NSString * const main_purchase_close_click;//付费页关闭

extern NSString * const main_purchase_click;//主付费页订阅按钮点击(包含周套餐和年套餐)-------------
extern NSString * const main_purchase_success;//主付费页订阅成功(包含周套餐和年套餐)------------
extern NSString * const main_purchase_failure;//主付费页订阅失败(包含周套餐和年套餐)----------
extern NSString * const main_purchase_verifySuccess;//主付费页订阅成功后，后台验证成功(包含周套餐和年套餐)----------
extern NSString * const main_purchase_verifyFailure;//主付费页订阅成功后，后台验证失败(包含周套餐和年套餐)----------

extern NSString * const main_purchase_w_click;//4.99周套餐点击
extern NSString * const main_purchase_w_success;//4.99周套餐付款成功
extern NSString * const main_purchase_w_failure;//4.99周套餐付款失败--------
extern NSString * const main_purchase_w_verifySuccess;//4.99周套餐付款成功后，后台验证成功--------
extern NSString * const main_purchase_w_verifyFailure;//4.99周套餐付款成功后，后台验证失败--------

extern NSString * const main_purchase_y_click;//39.99年套餐点击
extern NSString * const main_purchase_y_success;//39.99年套餐付款成功
extern NSString * const main_purchase_y_failure;//39.99年套餐付款失败-------
extern NSString * const main_purchase_y_verifySuccess;//39.99年套餐付款成功后，后台验证成功--------
extern NSString * const main_purchase_y_verifyFailure;//39.99年套餐付款成功后，后台验证失败--------

//主付费页因为网络等原因没有返回数据的错误
extern NSString * const main_purchase_w_unusualFailure;//主付费4.99周套餐，没有数据返回时的验证失败--------（）
extern NSString * const main_purchase_y_unusualFailure;//主付费39.99年套餐，没有数据返回时的验证失败--------（）
extern NSString * const main_purchase_unusualFailure;//主付费页所有套餐，没有数据返回时的验证失败--------（）

extern NSString * const setting_restore_click;//设置中restore 点击
extern NSString * const setting_restore_success;//设置页面中restore成功------
extern NSString * const setting_restore_failure;//设置页面中restore失败--------
extern NSString * const setting_restore_verifySuccess;//设置页面中restore成功后，后台验证成功--------
extern NSString * const setting_restore_verifyFailure;//设置页面中restore成功后，后台验证失败--------


//app内，购买总事件
extern NSString * const app_purchase_total_click;//app中购买按钮点击总和--------
extern NSString * const app_purchase_total_success;//app中付款成功总和--------
extern NSString * const app_purchase_total_failure;//app中付款失败总和--------
extern NSString * const app_purchase_total_verifySuccess;//app中付款成功后验证成功总和--------
extern NSString * const app_purchase_total_verifyFailure;//app中付款成功后验证失败总和--------
//app内，因为网络等原因没有返回数据的错误
extern NSString * const app_purchase_total_unusualFailure;//app中，没有数据返回时的验证失败总和--------（）

extern NSString * const app_purchaseLoss_total_verifySuccess;//掉单验证成功总和--------（）
extern NSString * const app_purchaseLoss_total_verifyFailure;//掉单验证失败总和--------（）
extern NSString * const app_purchaseLoss_total_unusualFailure;//掉单没有数据返回时的验证失败总和--------（）

/*************************************  分割线  *************************************/

extern NSString * const UPApplicationID;//应用ID
extern NSString * const guide_trail_w_click_token;//试用，4.99周套餐点击
extern NSString * const guide_trail_w_success_token;//试用，4.99周套餐付款成功
extern NSString * const guide_trail_m_click_token;//试用，9.99周套餐点击
extern NSString * const guide_trail_m_success_token;//试用，9.99周套餐付款成功
extern NSString * const guide_trail_y_click_token;//试用，39.99月套餐点击
extern NSString * const guide_trail_y_success_token;//试用，39.99月套餐付款成功
extern NSString * const guide_trail_click_token;//试用，引导页所有套餐点击
extern NSString * const guide_trail_success_token;//试用，引导页所有套餐付款成功

extern NSString * const main_purchase_y_click_token;//试用，39.99年套餐点击
extern NSString * const main_purchase_y_success_token;//试用，39.99年套餐付款成功
extern NSString * const main_purchase_w_click_token;//试用，4.99周套餐点击
extern NSString * const main_purchase_w_success_token;//试用，4.99周套餐付款成功
extern NSString * const main_purchase_click_token;//试用，周套餐和年套餐点击
extern NSString * const main_purchase_success_token;//试用，周套餐和年套餐付款成功

extern NSString * const app_purchase_total_click_token;//所有套餐点击
extern NSString * const app_purchase_total_success_token;//所有套餐付款成功



