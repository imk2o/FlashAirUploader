//
//  FAUViewController.m
//  FlashAirUploader
//
//  Created by k2o on 2014/02/16.
//  Copyright (c) 2014年 imk2o. All rights reserved.
//

#import "FAUViewController.h"
#import "UIImage+Sizing.h"

@interface FAUViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (IBAction)chooseImage:(id)sender;
- (IBAction)takePicture:(id)sender;

@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@end

@implementation FAUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chooseImage:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;

    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (IBAction)takePicture:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:NULL];
     
    // image to JPEG
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage* image = [originalImage resizedImageWithMinSize:300];
    NSData* data = UIImageJPEGRepresentation(image, 0.8);

    // config
    NSString* date = [NSString stringWithFormat:@"%lld", (int64_t)[[NSDate date] timeIntervalSince1970]];
    NSString* path = @"test";
    
    // Set Write-Protect and upload directory and System-Time
    // Make System-Time
    NSDate *systemdate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateCompnents;
    dateCompnents =[calendar components:NSYearCalendarUnit
                    | NSMonthCalendarUnit
                    | NSDayCalendarUnit
                    | NSHourCalendarUnit
                    | NSMinuteCalendarUnit
                    | NSSecondCalendarUnit fromDate:systemdate];
    
    NSInteger year =([dateCompnents year]-1980) << 9;
    NSInteger month = ([dateCompnents month]) << 5;
    NSInteger day = [dateCompnents day];
    NSInteger hour = [dateCompnents hour] << 11;
    NSInteger minute = [dateCompnents minute]<< 5;
    NSInteger second = floor([dateCompnents second]/2);
    
    NSString *datePart = [@"0x" stringByAppendingString:[NSString stringWithFormat:@"%x%x" ,year+month+day,hour+minute+second]];
    
    // Make Filename
    NSString *filename=[[date stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByAppendingString :@".jpg"];
    
    // Make url
    NSString *urlStr = @"http://flashair_penko/upload.cgi";
    urlStr = [urlStr stringByAppendingString:@"?WRITEPROTECT=ON&UPDIR="];
    urlStr = [urlStr stringByAppendingString:path];
    urlStr = [urlStr stringByAppendingString:@"&FTIME="];
    urlStr = [urlStr stringByAppendingString:datePart];
    NSURL *url = [NSURL URLWithString:urlStr];
    // Run cgi
    NSError *error;
    NSString *rtnStr =[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if ([error.domain isEqualToString:NSCocoaErrorDomain]){
        NSLog(@"upload.cgi %@\n",error);
        return;
    }else{
        if(![rtnStr isEqualToString:@"SUCCESS"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.title
                                                            message:@"upload.cgi:setup failed" delegate:nil
                                                  cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            return;
        }
    }
    
    // File upload
    
    //url
    url=[NSURL URLWithString:@"http://flashair_penko/upload.cgi"];
    
    //boundary
    CFUUIDRef uuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, uuid);
	CFRelease(uuid);
    NSString *boundary = [NSString stringWithFormat:@"flashair-%@",uuidString];
    
    //header
    NSString *header = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    //body
    NSMutableData *body=[NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",filename] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
    
    //Request
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:header forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    
    NSURLResponse *response;
    
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response
                                                       error:&error];
    rtnStr=[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    
    if ([error.domain isEqualToString:NSCocoaErrorDomain]){
        NSLog(@"upload.cgi %@\n",error);
        return;
    }else{
        if([rtnStr rangeOfString:@"Success"].location==NSNotFound){     //v2.0
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.title
                                                            message:@"upload.cgi: POST failed" delegate:nil
                                                  cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            return;
        }
    }
}

@end
