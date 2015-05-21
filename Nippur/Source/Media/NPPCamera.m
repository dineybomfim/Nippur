/*
 *	NPPCamera.m
 *	Copyright (c) 2011-2015 db-in. More information at: http://db-in.com/nippur
 *	
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *	THE SOFTWARE.
 */

#import "NPPCamera.h"

static AVCaptureConnection *nppCameraConnection(NSString *mediaType, NSArray *connections)
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}
 
 
 
 
@protocol AVCamRecorderDelegate;

@interface AVCamRecorder : NSObject <AVCaptureFileOutputRecordingDelegate>
{
}

@property (nonatomic, NPP_RETAIN) AVCaptureSession *session;
@property (nonatomic, NPP_RETAIN) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, NPP_COPY) NSURL *outputFileURL;
@property (nonatomic, readonly) BOOL recordsVideo;
@property (nonatomic, readonly) BOOL recordsAudio;
@property (nonatomic, readonly,getter=isRecording) BOOL recording;
@property (nonatomic, NPP_ASSIGN) id <NSObject,AVCamRecorderDelegate> delegate;

-(id)initWithSession:(AVCaptureSession *)session outputFileURL:(NSURL *)outputFileURL;
-(void)startRecordingWithOrientation:(AVCaptureVideoOrientation)videoOrientation;
-(void)stopRecording;

@end

@protocol AVCamRecorderDelegate
@required
-(void)recorderRecordingDidBegin:(AVCamRecorder *)recorder;
-(void)recorder:(AVCamRecorder *)recorder recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error;
@end

@implementation AVCamRecorder

@synthesize session;
@synthesize movieFileOutput;
@synthesize outputFileURL;
@synthesize delegate;

- (id) initWithSession:(AVCaptureSession *)aSession outputFileURL:(NSURL *)anOutputFileURL
{
	self = [super init];
	if (self != nil) {
		AVCaptureMovieFileOutput *aMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
		if ([aSession canAddOutput:aMovieFileOutput])
			[aSession addOutput:aMovieFileOutput];
		[self setMovieFileOutput:aMovieFileOutput];
		nppRelease(aMovieFileOutput);
		
		[self setSession:aSession];
		[self setOutputFileURL:anOutputFileURL];
	}
	
	return self;
}

- (void) dealloc
{
	[session removeOutput:[self movieFileOutput]];
	nppRelease(session);
	nppRelease(outputFileURL);
	nppRelease(movieFileOutput);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

-(BOOL)recordsVideo
{
	AVCaptureConnection *videoConnection = nppCameraConnection(AVMediaTypeVideo, [[self movieFileOutput] connections]);
	return [videoConnection isActive];
}

-(BOOL)recordsAudio
{
	AVCaptureConnection *audioConnection = nppCameraConnection(AVMediaTypeAudio, [[self movieFileOutput] connections]);
	return [audioConnection isActive];
}

-(BOOL)isRecording
{
	return [[self movieFileOutput] isRecording];
}

-(void)startRecordingWithOrientation:(AVCaptureVideoOrientation)videoOrientation;
{
	AVCaptureConnection *videoConnection = nppCameraConnection(AVMediaTypeVideo, [[self movieFileOutput] connections]);
	if ([videoConnection isVideoOrientationSupported])
		[videoConnection setVideoOrientation:videoOrientation];
	
	[[self movieFileOutput] startRecordingToOutputFileURL:[self outputFileURL] recordingDelegate:self];
}

-(void)stopRecording
{
	[[self movieFileOutput] stopRecording];
}

- (void)			 captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
		  fromConnections:(NSArray *)connections
{
	if ([[self delegate] respondsToSelector:@selector(recorderRecordingDidBegin:)]) {
		[[self delegate] recorderRecordingDidBegin:self];
	}
}

- (void)			  captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)anOutputFileURL
		   fromConnections:(NSArray *)connections
					 error:(NSError *)error
{
	if ([[self delegate] respondsToSelector:@selector(recorder:recordingDidFinishToOutputFileURL:error:)]) {
		[[self delegate] recorder:self recordingDidFinishToOutputFileURL:anOutputFileURL error:error];
	}
}

@end

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static UIImage *nppCameraImage(CMSampleBufferRef sampleBuffer, AVCaptureVideoOrientation orientation)
{
	UIImage *image = nil;
	if (sampleBuffer == NULL)
	{
		return image;
	}
	
	// Get a CMSampleBuffer's Core Video image buffer for the media data
	CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	// Lock the base address of the pixel buffer
	CVPixelBufferLockBaseAddress(imageBuffer, 0);
	
	// Get the number of bytes per row for the pixel buffer
	void *pixelData = CVPixelBufferGetBaseAddress(imageBuffer);
	
	// Get initial setup.
	size_t bpr = CVPixelBufferGetBytesPerRow(imageBuffer);
	size_t width = CVPixelBufferGetWidth(imageBuffer);
	size_t height = CVPixelBufferGetHeight(imageBuffer);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
	
	// Create a bitmap graphics context with the sample buffer data
	CGContextRef context = CGBitmapContextCreate(pixelData, width, height, 8, bpr, colorSpace, bitmapInfo);
	// Create a Quartz image from the pixel data in the bitmap graphics context
	CGImageRef quartzImage = CGBitmapContextCreateImage(context);
	
	// Create an image object from the Quartz image
	UIImageOrientation iOrientation;
	switch (orientation)
	{
		case AVCaptureVideoOrientationLandscapeLeft:
			iOrientation = UIImageOrientationDownMirrored;
			break;
		case AVCaptureVideoOrientationLandscapeRight:
			iOrientation = UIImageOrientationUpMirrored;
			break;
		case AVCaptureVideoOrientationPortraitUpsideDown:
			iOrientation = UIImageOrientationRightMirrored;
			break;
		case AVCaptureVideoOrientationPortrait:
		default:
			iOrientation = UIImageOrientationLeftMirrored;
			break;
	}
	image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:iOrientation];
	
	// Free up the context and color space
	CGImageRelease(quartzImage);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
	return image;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPCamera() <UIGestureRecognizerDelegate, AVCamRecorderDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
@private
	NPPCameraSource				_camera;
	CGSize						_size;
	
	CMSampleBufferRef			_lastBuffer;
	BOOL						_isBufferLocked;
}

@property (nonatomic, NPP_RETAIN) AVCaptureSession *session;
@property (nonatomic) AVCaptureVideoOrientation orientation;
@property (nonatomic, NPP_RETAIN) AVCaptureDeviceInput *videoInput;
@property (nonatomic, NPP_RETAIN) AVCaptureDeviceInput *audioInput;
@property (nonatomic, NPP_RETAIN) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, NPP_RETAIN) AVCaptureVideoDataOutput *dataOutput;
@property (nonatomic, NPP_RETAIN) AVCamRecorder *recorder;
@property (nonatomic, NPP_ASSIGN) id deviceConnectedObserver;
@property (nonatomic, NPP_ASSIGN) id deviceDisconnectedObserver;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

- (BOOL) setupSession;
- (void) startRecording;
- (void) stopRecording;
- (NSUInteger) cameraCount;
- (NSUInteger) micCount;

- (AVCaptureDevice *) cameraWithPosition:(NPPCameraSource)camera;
- (AVCaptureDevice *) audioDevice;
- (NSURL *) tempFileURL;
- (void) removeFile:(NSURL *)outputFileURL;
- (void) copyFileToDocuments:(NSURL *)fileURL;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPCamera

NPP_SINGLETON_IMPLEMENTATION(NPPCamera);

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize session = _session;
@synthesize orientation = _orientation;
@synthesize videoInput = _videoInput;
@synthesize audioInput = _audioInput;
@synthesize stillImageOutput = _stillImageOutput;
@synthesize dataOutput = _dataOutput;
@synthesize recorder = _recorder;
@synthesize deviceConnectedObserver = _deviceConnectedObserver;
@synthesize deviceDisconnectedObserver = _deviceDisconnectedObserver;
@synthesize backgroundRecordingID = _backgroundRecordingID;

@dynamic camera, size;

- (NPPCameraSource) camera { return NPPCameraSourceFront; };
- (void) setCamera:(NPPCameraSource)value
{
	_camera = value;
	
	if ([self cameraCount] > 1)
	{
		AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:_camera] error:nil];
		
		if (videoInput != nil)
		{
			[_session beginConfiguration];
			[_session removeInput:_videoInput];
			if ([_session canAddInput:videoInput])
			{
				[_session addInput:videoInput];
				self.videoInput = videoInput;
			}
			else
			{
				self.videoInput = nil;
			}
			
			[_session commitConfiguration];
			nppRelease(videoInput);
		}
	}
}

- (CGSize) size { return CGSizeMake(0, 0); }
- (void) setSize:(CGSize)value
{
	_size = value;
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		[self setupVideo];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void)setupVideo
{
	__block id bself = self;
	void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification)
	{
		AVCaptureDevice *device = [notification object];
		
		BOOL sessionHasDeviceWithMatchingMediaType = NO;
		NSString *deviceMediaType = nil;
		if ([device hasMediaType:AVMediaTypeAudio])
		{
			deviceMediaType = AVMediaTypeAudio;
		}
		else if ([device hasMediaType:AVMediaTypeVideo])
		{
			deviceMediaType = AVMediaTypeVideo;
		}
		
		if (deviceMediaType != nil)
		{
			for (AVCaptureDeviceInput *input in [_session inputs])
			{
				if ([[input device] hasMediaType:deviceMediaType])
				{
					sessionHasDeviceWithMatchingMediaType = YES;
					break;
				}
			}
			
			if (!sessionHasDeviceWithMatchingMediaType)
			{
				NSError	*error;
				AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
				if ([_session canAddInput:input])
					[_session addInput:input];
			}
		}
	};
	
	void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification)
	{
		AVCaptureDevice *device = [notification object];
		
		if ([device hasMediaType:AVMediaTypeAudio])
		{
			[_session removeInput:[bself audioInput]];
			[bself setAudioInput:nil];
		}
		else if ([device hasMediaType:AVMediaTypeVideo])
		{
			[_session removeInput:[bself videoInput]];
			[bself setVideoInput:nil];
		}
	};
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	self.deviceConnectedObserver = [notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:nil usingBlock:deviceConnectedBlock];
	self.deviceDisconnectedObserver = [notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:nil usingBlock:deviceDisconnectedBlock];
	[notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[self deviceOrientationDidChange];
	
	if ([self setupSession])
	{
		// Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
		{
			[_session startRunning];
		});
		
		[self focusAtPoint:CGPointMake(0.5f, 0.5f)];
		[self exposureAtPoint:CGPointMake(0.5f, 0.5f)];
	}
}

- (BOOL) setupSession
{
	BOOL success = NO;
	
	// Set torch and flash mode to auto.
	_camera = NPPCameraSourceFront;
	AVCaptureDevice *camera = [self cameraWithPosition:_camera];
	if ([camera hasFlash]) {
		if ([camera lockForConfiguration:nil]) {
			if ([camera isFlashModeSupported:AVCaptureFlashModeAuto]) {
				[camera setFlashMode:AVCaptureFlashModeAuto];
			}
			[camera unlockForConfiguration];
		}
	}
	if ([camera hasTorch]) {
		if ([camera lockForConfiguration:nil]) {
			if ([camera isTorchModeSupported:AVCaptureTorchModeAuto]) {
				[camera setTorchMode:AVCaptureTorchModeAuto];
			}
			[camera unlockForConfiguration];
		}
	}
	
	// Init the device inputs
	AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:nil];
	//AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
	
	// Setup the still image file output
	AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
	[imageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG forKey:AVVideoCodecKey]];
	
	// Setup the data output
	AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
	[dataOutput setAlwaysDiscardsLateVideoFrames:YES];
	dataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
	//dataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
	dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
	[dataOutput setSampleBufferDelegate:self queue:queue];
#ifndef NPP_ARC
	dispatch_release(queue);
#endif
	
	// Create session (use default AVCaptureSessionPresetHigh)
	AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
	captureSession.sessionPreset = AVCaptureSessionPresetHigh;
	
	// Add inputs and output to the capture session
	if ([captureSession canAddInput:videoInput]) {
		[captureSession addInput:videoInput];
	}
	
//	if ([captureSession canAddInput:audioInput]) {
//		[captureSession addInput:audioInput];
//	}
	
	if ([captureSession canAddOutput:imageOutput]) {
		//[captureSession addOutput:imageOutput];
		[captureSession addOutput:dataOutput];
	}
	
	
	// Specify the pixel format
	
	// If you wish to cap the frame rate to a known value, such as 15 fps, set
	// minFrameDuration.
	//output.minFrameDuration = CMTimeMake(1, 15);
	
	self.videoInput = videoInput;
	self.session = captureSession;
	self.dataOutput = dataOutput;
	self.stillImageOutput = imageOutput;
	//self.audioInput = audioInput;
	
	nppRelease(dataOutput);
	nppRelease(imageOutput);
	nppRelease(videoInput);
	//nppRelease(audioInput);
	nppRelease(captureSession);
	
//	// Set up the movie file output
//	NSURL *outputFileURL = [self tempFileURL];
//	AVCamRecorder *newRecorder = [[AVCamRecorder alloc] initWithSession:_session outputFileURL:outputFileURL];
//	[newRecorder setDelegate:self];
//	
//	// Send an error to the delegate if video recording is unavailable
//	if (![newRecorder recordsVideo] && [newRecorder recordsAudio]) {
//	NSString *localizedDescription = @"Video recording unavailable";
//	NSString *localizedFailureReason = @"Movies recorded on this device will only contain audio.";
//	NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
//	localizedDescription, NSLocalizedDescriptionKey,
//	localizedFailureReason, NSLocalizedFailureReasonErrorKey,
//	nil];
//	NSError *noVideoError = [NSError errorWithDomain:@"AVCam" code:0 userInfo:errorDict];
//	nppLog(@"%@", noVideoError);
//	}
//	
//	self.recorder = newRecorder;
//	nppRelease(newRecorder);
	
	success = YES;
	
	return success;
}

// Delegate routine that is called when a sample buffer was written
- (void) captureOutput:(AVCaptureOutput *)captureOutput
 didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
		fromConnection:(AVCaptureConnection *)connection
{
	dispatch_sync(dispatch_get_main_queue(), ^(void)
	{
		if (!_isBufferLocked)
		{
			if (_lastBuffer != NULL)
			{
				CFRelease(_lastBuffer);
				_lastBuffer = NULL;
			}
			
			CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &_lastBuffer);
		}
	});
}

#pragma mark Device Counts
- (NSUInteger) cameraCount
{
	return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger) micCount
{
	return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}


#pragma mark Camera Properties

- (void) focusAtPoint:(CGPoint)point
{
	AVCaptureDevice *device = [_videoInput device];
	AVCaptureFocusMode focus = AVCaptureFocusModeContinuousAutoFocus;
	//([device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
	
	if ([device isFocusPointOfInterestSupported])
	{
		NSError *error;
		if ([device lockForConfiguration:&error])
		{
			[device setFocusPointOfInterest:point];
			[device setFocusMode:focus];
			[device unlockForConfiguration];
		}
		else
		{
			nppLog(@"%@", error);
		}
	}
}

- (void) exposureAtPoint:(CGPoint)point
{
	AVCaptureDevice *device = [_videoInput device];
	AVCaptureExposureMode exposure = AVCaptureExposureModeContinuousAutoExposure;
	AVCaptureWhiteBalanceMode whiteBalance = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
	
	if ([device isExposurePointOfInterestSupported])
	{
		NSError *error;
		if ([device lockForConfiguration:&error])
		{
			[device setExposurePointOfInterest:point];
			[device setExposureMode:exposure];
			[device setWhiteBalanceMode:whiteBalance];
			[device unlockForConfiguration];
		}
		else
		{
			nppLog(@"%@", error);
		}
	}
}

#pragma mark -
#pragma mark AVCamCaptureManager (InternalUtilityMethods)

// Keep track of current device orientation so it can be applied to movie recordings and still image captures
- (void)deviceOrientationDidChange
{
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
	switch (deviceOrientation)
	{
		// AVCapture and UIDevice have opposite meanings for landscape left and right
		// (AVCapture orientation is the same as UIInterfaceOrientation)
		case UIDeviceOrientationLandscapeLeft:
			_orientation = AVCaptureVideoOrientationLandscapeRight;
			break;
		case UIDeviceOrientationLandscapeRight:
			_orientation = AVCaptureVideoOrientationLandscapeLeft;
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			_orientation = AVCaptureVideoOrientationPortraitUpsideDown;
			break;
		case UIDeviceOrientationPortrait:
		default:
			_orientation = AVCaptureVideoOrientationPortrait;
			break;
	}
	
//	AVCaptureConnection *connection = nppCameraConnection(AVMediaTypeVideo, [_stillImageOutput connections]);
//	if ([connection isVideoOrientationSupported])
//	{
//		[connection setVideoOrientation:_orientation];
//	}
	
	// Ignore device orientations for which there is no corresponding still image orientation (e.g. UIDeviceOrientationFaceUp)
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(NPPCameraSource)camera
{
	AVCaptureDevicePosition position;
	
	switch (camera)
	{
		case NPPCameraSourceFront:
			position = AVCaptureDevicePositionFront;
			break;
		default:
			position = AVCaptureDevicePositionBack;
			break;
	}
	
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			return device;
		}
	}
	return nil;
}

// Find and return an audio device, returning nil if one is not found
- (AVCaptureDevice *) audioDevice
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
	if ([devices count] > 0) {
		return [devices objectAtIndex:0];
	}
	return nil;
}

- (NSURL *) tempFileURL
{
	return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"]];
}

- (void) removeFile:(NSURL *)fileURL
{
	NSString *filePath = [fileURL path];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:filePath]) {
		NSError *error;
		if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
			nppLog(@"%@", error);
		}
	}
}

- (void) copyFileToDocuments:(NSURL *)fileURL
{
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
	NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/output_%@.mov", [dateFormatter stringFromDate:[NSDate date]]];
	nppRelease(dateFormatter);
	NSError	*error;
	if (![[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:destinationPath] error:&error]) {
		nppLog(@"%@", error);
	}
}

#pragma mark -
#pragma mark AVCamCaptureManager

-(void)recorderRecordingDidBegin:(AVCamRecorder *)recorder
{
	// Recording did begin.
}

-(void)recorder:(AVCamRecorder *)recorder recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error
{
	if ([_recorder recordsAudio] && ![_recorder recordsVideo]) {
		// If the file was created on a device that doesn't support video recording, it can't be saved to the assets
		// library. Instead, save it in the app's Documents directory, whence it can be copied from the device via
		// iTunes file sharing.
		[self copyFileToDocuments:outputFileURL];
		
		if ([[UIDevice currentDevice] isMultitaskingSupported]) {
			[[UIApplication sharedApplication] endBackgroundTask:_backgroundRecordingID];
		}
		
		// Recording did finish.
	}
//		 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//		 [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
//		 completionBlock:^(NSURL *assetURL, NSError *error) {
//		 if (error) {
//		 nppLog(@"%@", error);
//		 }
//		 
//		 if ([[UIDevice currentDevice] isMultitaskingSupported]) {
//		 [[UIApplication sharedApplication] endBackgroundTask:_backgroundRecordingID];
//		 }
//		 
//		 // Recording did finish.
//		 }];
//		 nppRelease(library);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) reset
{
	[self setupVideo];
}

- (void) startRecording
{
	if ([[UIDevice currentDevice] isMultitaskingSupported]) {
		// Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns
		// to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library
		// when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error:
		// after the recorded file has been saved.
		self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	}
	
	[self removeFile:[_recorder outputFileURL]];
	[_recorder startRecordingWithOrientation:_orientation];
}

- (void) stopRecording
{
	[_recorder stopRecording];
}

- (BOOL) isRecording
{
	return NO;
}

- (void) showPreviewInView:(UIView *)view
{
	// Create video preview layer and add it to the UI
	AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
	CALayer *viewLayer = [view layer];
	[viewLayer setMasksToBounds:YES];
	
	CGRect bounds = [view bounds];
	[layer setFrame:bounds];
	
	AVCaptureConnection *connection = [layer connection];
	if ([connection isVideoOrientationSupported])
	{
		[connection setVideoOrientation:_orientation];
	}
	
	[layer setName:@"NPPViewManagerLayer"];
	[layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	
	[viewLayer insertSublayer:layer below:[[viewLayer sublayers] objectAtIndex:0]];
	nppRelease(layer);
	
	[_session startRunning];
}

- (void) hidePreviewInView:(UIView *)view
{
	CALayer *viewLayer = nil;
	NSArray *sublayers = [[view layer] sublayers];
	
	for (viewLayer in sublayers)
	{
		if ([[viewLayer name] isEqualToString:@"NPPViewManagerLayer"])
		{
			[_session stopRunning];
			[viewLayer removeFromSuperlayer];
		}
	}
}

- (UIImage *) snapshot
{
	@synchronized(self)
	{
		_isBufferLocked = YES;
		UIImage *image = nppCameraImage(_lastBuffer, _orientation);
		_isBufferLocked = NO;
		
		return image;
	}
}
/*
- (void) snapshotWithCompletion:(void (^)(UIImage *image))block
{
	AVCaptureConnection *connection = nppCameraConnection(AVMediaTypeVideo, [_stillImageOutput connections]);
	if ([connection isVideoOrientationSupported])
	{
		[connection setVideoOrientation:_orientation];
	}
	
	void (^captureBlock)(CMSampleBufferRef, NSError *) = ^(CMSampleBufferRef sampleBuffer, NSError *error)
	{
		UIImage *image = nil;
		
		if (sampleBuffer != NULL)
		{
			NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
			image = [UIImage imageWithData:imageData];
		}
		
		block(image);
	};
	
	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:captureBlock];
}
//*/
#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self];
	
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	
	[_session stopRunning];
	nppRelease(_session);
	nppRelease(_videoInput);
	nppRelease(_audioInput);
	nppRelease(_stillImageOutput);
	nppRelease(_recorder);
	nppRelease(_dataOutput);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end