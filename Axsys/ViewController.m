//
//  ViewController.m
//  DTMHeatMapExample
//
//  Created by Bryan Oltman on 1/7/15.
//  Copyright (c) 2015 Dataminr. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (NSDictionary *)parseLatLonFile:(NSString *)fileName
{
    NSMutableDictionary *ret = [NSMutableDictionary new];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName
                                                     ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSArray *parts = [line componentsSeparatedByString:@","];
        NSString *latStr = parts[0];
        NSString *lonStr = parts[1];
        
        CLLocationDegrees latitude = [latStr doubleValue];
        CLLocationDegrees longitude = [lonStr doubleValue];
        
        // For this example, each location is weighted equally
        double weight = 1;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude
                                                          longitude:longitude];
        MKMapPoint point = MKMapPointForCoordinate(location.coordinate);
        NSValue *pointValue = [NSValue value:&point
                                withObjCType:@encode(MKMapPoint)];
        ret[pointValue] = @(weight);
    }
    
    return ret;
}

@end
