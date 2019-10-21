//
//  ViewController.m
//  ChangeLocation
//
//  Created by ljb48229 on 2018/1/26.
//  Copyright © 2018年 ljb48229. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ChangeLoction.h"

@interface ViewController ()<CLLocationManagerDelegate>

@property(nonatomic ,strong) CLLocationManager *manager;
@property (weak, nonatomic) IBOutlet UILabel *location2DLable;
@property (weak, nonatomic) IBOutlet UILabel *locationLable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //如果要想知道任意位置的坐标
    //1.去高德地图http://lbs.amap.com/console/show/picker，选中自己坐标
    //杭州  120.211963,30.274602
    //榆能横山电厂宿舍 109.41118,38.040963
    //成寿寺路21号院   116.444368,39.852638
    //太极来广营       116.471516,40.021688
    //深圳东风大厦     114.093446,22.541497
    //工人体育场       116.447155, 39.930516
    //工人体育馆       116.441868, 39.932259
    //太极公司        116.471516,40.021688
    //国投大厦        116.357475,39.929352
    //左岸公社        116.304359,39.984399
    //2.在进行坐标转换
    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(39.984399, 116.304359);
    CLLocationCoordinate2D WGSlocation2D = [ChangeLoction gcj02ToWgs84:location2D];
    NSLog(@"纬度：%f,经度：%f",WGSlocation2D.latitude , WGSlocation2D.longitude);
    //纬度：30.277029,经度：120.207428
    //3.去Location1.gpx修改经纬度
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _manager = [[CLLocationManager alloc] init];
    _manager.delegate = self;
//    [manager requestAlwaysAuthorization];
    [_manager requestWhenInUseAuthorization];
    _manager.desiredAccuracy = kCLLocationAccuracyBest;
    _manager.distanceFilter = 1.0;
    [_manager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    //1.如果打卡地点是这里，当前的经纬度。
    //2.直接copy下面的经纬度，无需转换
    //3.去Location1.gpx修改经纬度
    //当前的经纬度
    NSLog(@"当前的经纬度 %f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    self.location2DLable.text = [NSString stringWithFormat:@"纬度:%f,经度:%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
    
    //地理反编码 可以根据坐标(经纬度)确定位置信息(街道 门牌等)
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count >0) {
            CLPlacemark *placeMark = placemarks[0];
            NSString *currentCity = placeMark.locality;
            if (!currentCity) {
                currentCity = @"无法定位当前城市";
            }
            //看需求定义一个全局变量来接收赋值
            NSLog(@"当前国家 - %@",placeMark.country);//当前国家
            NSLog(@"当前城市 - %@",currentCity);//当前城市
            NSLog(@"当前位置 - %@",placeMark.subLocality);//当前位置
            NSLog(@"当前街道 - %@",placeMark.thoroughfare);//当前街道
            NSLog(@"具体地址 - %@",placeMark.name);//具体地址
            self.locationLable.text = [NSString stringWithFormat:@"%@,%@,%@,%@,%@",placeMark.country,currentCity,placeMark.subLocality,placeMark.thoroughfare,placeMark.name];
        }
    }];
}
@end
