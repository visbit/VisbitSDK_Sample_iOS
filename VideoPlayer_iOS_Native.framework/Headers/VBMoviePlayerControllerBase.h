//
//  VBMoviePlayerControllerBase.h
//  VideoPlayer
//
//  Created by Ji Fang on 4/4/16.
//  Copyright © 2016 visbit. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const VBVideoQualityAuto;

@interface VBMoviePlayerControllerBase : UIViewController

- (instancetype)initWithVideoID:(NSString *)videoID
                       duration:(CGFloat)duration
                    offlineMode:(BOOL)offlineMode
                   previewToken:(NSString *)previewToken;

@property (nonatomic, assign)   BOOL vrModeEnabled;

@property (nonatomic, assign, getter=isGyroEnabled) BOOL gyroEnabled;

@property (nonatomic, copy)     NSString *quality;

@property (nonatomic, readonly) BOOL    ready;

@property (nonatomic, readonly) CGFloat rate;

@property (nonatomic, readonly) CGFloat currentTime;

@property (nonatomic, readonly) CGFloat duration;

@property (nonatomic, strong) NSArray <NSString *> *resolutions;

- (void)play;

- (void)pause;

- (void)close;

- (void)seekToTime:(NSTimeInterval)videoPlaytime;

- (void)onVideoMetadataLoaded;

@end
