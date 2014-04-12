//
//  BBUFullIssueNavigator.m
//  BBUFullIssueNavigator
//
//  Created by Boris Bügling on 12/04/14.
//    Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <objc/runtime.h>

#import "BBUFullIssueNavigator.h"
#import "NSObject+YOLO.h"

static BBUFullIssueNavigator *sharedPlugin;

@interface NSObject (ShutUpWarnings)

@property(nonatomic) int width;

-(int)rowHeightForItem:(id)item outlineView:(NSView*)outlineView;
-(int)yl_rowHeightForItem:(id)item outlineView:(NSView*)outlineView;

@end

#pragma mark -

@interface BBUFullIssueNavigator()

@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation BBUFullIssueNavigator

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        
        [[objc_getClass("IDEIssueNavigatorDataCell") new] yl_swizzleSelector:@selector(rowHeightForItem:outlineView:) withBlock:^(id sself, id item, NSView* outlineView) {
            int height = [sself yl_rowHeightForItem:item outlineView:outlineView];

            if ([item subtitle]) {
                height += [[item subtitle] boundingRectWithSize:NSMakeSize([(NSObject*)sself width], INT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: [NSFont fontWithName:@"LucidaGrande" size:11.0] }].size.height;
            }
            
            return height;
        }];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
