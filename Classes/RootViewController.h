//
//  RootViewController.h
//  CloudFingerPaint-Client-iOS
//
//  Created by Noguchi Osamu on 11/03/01.
//  Copyright 2011 envision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RootViewController : UIViewController {
	CGPoint lastPoint;
	UIImageView *drawImage;
	BOOL mouseSwiped;	
	int mouseMoved;
	UIAlertView *alertView;
	NSMutableData *httpResponseData;
	UIActivityIndicatorView *indicator;
}

@property (nonatomic, retain) UIImageView *drawImage;
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) NSMutableData *httpResponseData;

-(IBAction)clearFingerPaint:(id)sender;
-(IBAction)printFingerPaint:(id)sender;

-(NSString*)data2str:(NSData*)data;
-(void)uploadFingerPaint;

@end
