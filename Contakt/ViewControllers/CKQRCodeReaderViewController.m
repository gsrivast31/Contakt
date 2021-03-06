//
//  CKQRCodeReaderViewController.m
//  Contakt
//
//  Created by GAURAV SRIVASTAVA on 17/01/15.
//  Copyright (c) 2015 GAURAV SRIVASTAVA. All rights reserved.
//

#import "CKQRCodeReaderViewController.h"
#import "CKCoreDataStack.h"
#import "CKContact.h"
#import <AVFoundation/AVFoundation.h>


@interface CKQRCodeReaderViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL isReading;

@property (weak, nonatomic) IBOutlet UIView *videoPreview;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;

-(BOOL)startReading;
-(void)stopReading;

@end

@implementation CKQRCodeReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _captureSession = nil;
    _isReading = NO;
    
    self.videoButton.titleLabel.font = [UIFont flatFontOfSize:16];
    [self.videoButton setTitle:@"Stop" forState:UIControlStateNormal];
    [self.videoButton setBackgroundColor:[UIColor whiteColor]];
    [self.videoButton setAlpha:0.6f];
    [self.videoButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.videoButton.userInteractionEnabled = YES;
    
    self.videoButton.layer.cornerRadius = CGRectGetWidth(self.videoButton.frame) / 2.0f;
    self.videoButton.layer.borderColor = [[UIColor grayColor] CGColor];
    self.videoButton.layer.borderWidth = 2.0f;
    self.videoButton.layer.masksToBounds = YES;
    self.videoButton.clipsToBounds = YES;
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopCamera)];
    [self.videoButton addGestureRecognizer:gesture];
    
    [self startReading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private method implementation

- (void)stopCamera {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)startReading {
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:self.videoPreview.frame];
    [self.videoPreview.layer insertSublayer:_videoPreviewLayer atIndex:0];
    
    // Start video capture.
    [_captureSession startRunning];
    
    _isReading = YES;
    
    return YES;
}

-(void)stopReading{
    _isReading = NO;
    
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
    [self stopCamera];
}

-(void)updateContact:(NSString*)value {
    if (_isReading && [CKHelper isStringValid:value]) {
        [self.delegate didReadQRCode:value];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // If the found metadata is equal to the QR code metadata then update the status label's text,
            // stop reading and change the bar button item's title and the flag's value.
            // Everything is done on the main thread.
            __weak typeof(self) weakSelf = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = self;
                [strongSelf updateContact:[metadataObj stringValue]];
                [strongSelf stopReading];
            });
            
            // If the audio player is not nil, then play the sound effect.
            if (_audioPlayer) {
                [_audioPlayer play];
            }
        }
    }
}


@end
