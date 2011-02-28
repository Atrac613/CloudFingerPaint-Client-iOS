//
//  RootViewController.m
//  CloudFingerPaint-Client-iOS
//
//  Created by Noguchi Osamu on 11/03/01.
//  Copyright 2011 envision. All rights reserved.
//

#import "RootViewController.h"
#import "JSON/JSON.h"

@implementation RootViewController

@synthesize drawImage;
@synthesize alertView;
@synthesize indicator;
@synthesize httpResponseData;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.navigationController setNavigationBarHidden:YES];
	
	drawImage = [[UIImageView alloc] initWithImage:nil];
	drawImage.frame = self.view.frame;
	[self.view addSubview:drawImage];
	self.view.backgroundColor = [UIColor whiteColor];
	mouseMoved = 0;
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	mouseSwiped = NO;
	
	UITouch *touch = [touches anyObject];
	
	lastPoint = [touch locationInView:self.view];
	lastPoint.y -= 20;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	mouseSwiped = YES;
	
	UITouch *touch = [touches anyObject];	
	CGPoint currentPoint = [touch locationInView:self.view];
	currentPoint.y -= 20;
	
	UIGraphicsBeginImageContext(self.view.frame.size);
	[drawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
	CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
	CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
	CGContextBeginPath(UIGraphicsGetCurrentContext());
	CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
	CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
	CGContextStrokePath(UIGraphicsGetCurrentContext());
	drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	lastPoint = currentPoint;
	
	mouseMoved++;
	
	if (mouseMoved == 10) {
		mouseMoved = 0;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if(!mouseSwiped) {
		UIGraphicsBeginImageContext(self.view.frame.size);
		[drawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
		CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
		CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
		CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
		CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
		CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
		CGContextStrokePath(UIGraphicsGetCurrentContext());
		CGContextFlush(UIGraphicsGetCurrentContext());
		drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        //sendButton.enabled = YES;
	}
}

-(IBAction)clearFingerPaint:(id)sender {
	NSLog(@"Clear Finger Paint.");
	
	drawImage.image = nil;
}

-(IBAction)printFingerPaint:(id)sender {
	NSLog(@"Print Finger Paint.");
	
	// インジケーターアニメーションの作成。
	alertView = [[UIAlertView alloc] initWithTitle:@"処理を実行中です...\n" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView show];
	indicator = [[UIActivityIndicatorView alloc] init];
    [indicator setFrame:CGRectMake(0,0,40,40)];
    [indicator setCenter:CGPointMake(alertView.bounds.size.width / 2, alertView.bounds.size.height - 45)];
	[indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setHidesWhenStopped:YES];
	[indicator startAnimating];
	[alertView addSubview:indicator];
	[indicator release];
	
	[self performSelectorOnMainThread:@selector(uploadFingerPaint) withObject:self waitUntilDone:YES];
	
}

-(void)uploadFingerPaint{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *urlString = @"http://cloud-finger-paint.appspot.com/cfp/api/upload";
	
	CGRect screenRect = CGRectMake(0, 0, drawImage.frame.size.width, drawImage.frame.size.height);
	UIGraphicsBeginImageContext(screenRect.size);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[[UIColor whiteColor] set];
	CGContextFillRect(ctx, screenRect);
	
	[self.drawImage.layer renderInContext:ctx];
	
	UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
	UIImageWriteToSavedPhotosAlbum(screenImage, nil, nil, nil);
	UIGraphicsEndImageContext();
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSData *imageData = UIImagePNGRepresentation(screenImage);
	
	NSMutableData *body = [NSMutableData data];
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"image\"; filename=\"ipodfile.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	// アップロード処理実行。
	[NSURLConnection connectionWithRequest:request delegate:self];	
	
	[pool release];
}


/***
 * データ受信開始時に呼ばれる
 **/
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    if (httpResponseData != nil) [httpResponseData release];
    httpResponseData = [[NSMutableData data] retain];
}

/***
 * データ受信時に呼ばれる
 **/
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [httpResponseData appendData:data];
}

/***
 * データ受信完了時に呼ばれる
 **/
- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    NSString *returnString = [self data2str:httpResponseData];
    NSLog(@"returnString: %@", returnString);
	
    //変数の解放
    [httpResponseData release];
    httpResponseData=nil;
	
    //インジケーターのアニメーションの停止
    [indicator stopAnimating];
	[alertView dismissWithClickedButtonIndex:0 animated:YES];
	
	alertView = [[UIAlertView alloc]initWithTitle:@"Cloud Finger Paint" message:@"印刷キューに登録失敗しました。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	id jsonTmpDic		= [returnString JSONValue];
	
	if ([jsonTmpDic isKindOfClass:[NSDictionary class]]) {
		if ([jsonTmpDic valueForKey:@"status"]) {
			alertView = [[UIAlertView alloc]initWithTitle:@"Cloud Finger Paint" message:@"印刷キューに登録しました。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		}
	}
	
	[alertView show];
}

/***
 * データ受信失敗時に呼ばれる
 **/
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    NSLog(@"通信エラー");
	
    //インジケーターのアニメーションの停止
    [indicator stopAnimating];
	[alertView dismissWithClickedButtonIndex:0 animated:YES];
	alertView = [[UIAlertView alloc]initWithTitle:@"IO Error" message:@"通信に失敗しました。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
}

/***
 * データ→文字列
 **/
- (NSString*)data2str:(NSData*)data {
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end

