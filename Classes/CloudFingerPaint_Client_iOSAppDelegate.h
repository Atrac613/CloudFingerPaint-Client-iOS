//
//  CloudFingerPaint_Client_iOSAppDelegate.h
//  CloudFingerPaint-Client-iOS
//
//  Created by Noguchi Osamu on 11/03/01.
//  Copyright 2011 envision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloudFingerPaint_Client_iOSAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

