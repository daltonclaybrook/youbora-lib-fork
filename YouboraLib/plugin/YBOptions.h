//
//  YBOptions.h
//  YouboraLib
//
//  Created by Joan on 17/03/2017.
//  Copyright © 2017 NPAW. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This class stores all the Youbora configuration settings.
 * Any value specified in this class, if set, will override the info the plugin is able to get on
 * its own.
 *
 * The only <b>required</b> option is the <accountCode>.
 */
@interface YBOptions : NSObject

/// ---------------------------------
/// @name Public properties
/// ---------------------------------

/**
 * If enabled the plugin won't send NQS requests.
 * Default: true
 */
@property(nonatomic, assign) bool enabled;

/**
 * Define the security of NQS calls.
 * If true it will use "https://".
 * If false it will use "http://".
 * Default: true
 */
@property(nonatomic, assign) bool httpSecure;

/**
 * Host of the Fastdata service.
 */
@property(nonatomic, strong) NSString * host;

/**
 * NicePeopleAtWork account code that indicates the customer account.
 */
@property(nonatomic, strong) NSString * accountCode;

/**
 * User ID value inside your system.
 */
@property(nonatomic, strong) NSString * username;

/**
 * If true the plugin will parse HLS files to use the first .ts file found as resource.
 * It might slow performance down.
 * Default: false
 */
@property(nonatomic, assign) bool parseHls;

/**
 * If defined, resource parse will try to fetch the CDN code from the custom header defined
 * by this property, e.g. "x-cdn-forward"
 */
@property(nonatomic, strong) NSString * parseCdnNameHeader;

/**
 * If true the plugin will query the CDN to retrieve the node name.
 * It might slow performance down.
 * Default: false
 */
@property(nonatomic, assign) bool parseCdnNode;

/**
 * List of CDN names to parse. This is only used when <parseCdnNode> is enabled.
 * Order is respected when trying to match against a CDN.
 * Default: ["Akamai", "Cloudfront", "Level3", "Fastly", "Highwinds"].
 */
@property(nonatomic, strong) NSMutableArray<NSString *> * parseCdnNodeList;

/**
 * IP of the viewer/user, e.g. "48.15.16.23".
 */
@property(nonatomic, strong) NSString * networkIP;

/**
 * Name of the internet service provider of the viewer/user.
 */
@property(nonatomic, strong) NSString * networkIsp;

/**
 * See a list of codes in <a href="http://mapi.youbora.com:8081/connectionTypes">http://mapi.youbora.com:8081/connectionTypes</a>.
 */
@property(nonatomic, strong) NSString * networkConnectionType;

/**
 * Youbora's device code. If specified it will rewrite info gotten from user agent.
 * See a list of codes in <a href="http://mapi.youbora.com:8081/devices">http://mapi.youbora.com:8081/devices</a>.
 */
@property(nonatomic, strong) NSString * deviceCode;

/**
 * URL/path of the current media resource.
 */
@property(nonatomic, strong) NSString * contentResource;

/**
 * @YES if the content is Live. @NO if VOD. Default: nil.
 */
@property(nonatomic, strong) NSValue * contentIsLive;

/**
 * Title of the media.
 */
@property(nonatomic, strong) NSString * contentTitle;

/**
 * Secondary title of the media. This could be program name, season, episode, etc.
 */
@property(nonatomic, strong) NSString * contentTitle2;

/**
 * Duration of the media <b>in seconds</b>.
 */
@property(nonatomic, strong) NSNumber * contentDuration; // double

/**
 * Custom unique code to identify the view.
 */
@property(nonatomic, strong) NSString * contentTransactionCode;

/**
 * Bitrate of the content in bits per second.
 */
@property(nonatomic, strong) NSNumber * contentBitrate; // long

/**
 * Throughput of the client bandwidth in bits per second.
 */
@property(nonatomic, strong) NSNumber * contentThroughput; // long

/**
 * Name or value of the current rendition (quality) of the content.
 */
@property(nonatomic, strong) NSString * contentRendition;

/**
 * Codename of the CDN where the content is streaming from.
 * See a list of codes in <a href="http://mapi.youbora.com:8081/cdns">http://mapi.youbora.com:8081/cdns</a>.
 */
@property(nonatomic, strong) NSString * contentCdn;

/**
 * Frames per second of the media being played.
 */
@property(nonatomic, strong) NSNumber * contentFps; // double

/**
 * NSDictionary containing mixed extra information about the content like: director, parental rating,
 * device info or the audio channels.
 */
@property(nonatomic, strong) NSDictionary * contentMetadata;

/**
 * NSDictionary containing mixed extra information about the ads like: director, parental rating,
 * device info or the audio channels.
 */
@property(nonatomic, strong) NSDictionary * adMetadata;

/**
 * Custom parameter 1.
 */
@property(nonatomic, strong) NSString * extraparam1;

/**
 * Custom parameter 2.
 */
@property(nonatomic, strong) NSString * extraparam2;

/**
 * Custom parameter 3.
 */
@property(nonatomic, strong) NSString * extraparam3;

/**
 * Custom parameter 4.
 */
@property(nonatomic, strong) NSString * extraparam4;

/**
 * Custom parameter 5.
 */
@property(nonatomic, strong) NSString * extraparam5;

/**
 * Custom parameter 6.
 */
@property(nonatomic, strong) NSString * extraparam6;

/**
 * Custom parameter 7.
 */
@property(nonatomic, strong) NSString * extraparam7;

/**
 * Custom parameter 8.
 */
@property(nonatomic, strong) NSString * extraparam8;

/**
 * Custom parameter 9.
 */
@property(nonatomic, strong) NSString * extraparam9;

/**
 * Custom parameter 10.
 */
@property(nonatomic, strong) NSString * extraparam10;

@end