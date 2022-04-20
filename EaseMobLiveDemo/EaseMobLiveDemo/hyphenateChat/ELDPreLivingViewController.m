//
//  ELDPreLivingViewController.m
//  EaseMobLiveDemo
//
//  Created by liu001 on 2022/3/31.
//  Copyright © 2022 zmw. All rights reserved.
//

#import "ELDPreLivingViewController.h"
#import <CoreServices/CoreServices.h>
#import "ELDLivingCountdownView.h"
#import "ELDPublishLiveViewController.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import <AVFoundation/AVFoundation.h>


@interface ELDPreLivingViewController ()<UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDelegate>


@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *headerBgView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *changeAvatarButton;
@property (nonatomic, strong) UITextField *liveNameTextField;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *flipButton;
@property (nonatomic, strong) UILabel *flipHintLabel;
@property (nonatomic, strong) UIButton *goLiveButton;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, strong) EaseLiveRoom *liveRoom;
@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, assign) CGFloat loadingAngle;

@property (nonatomic, strong) ELDLivingCountdownView *livingCountDownView;
@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) UIView *agoraLocalVideoView;


@property (nonatomic, strong)AVCaptureSession *session;
@property (nonatomic, strong)AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong)AVCaptureDevice *backDevice;
@property (nonatomic, strong)AVCaptureDevice *frontDevice;
@property (nonatomic, strong)AVCaptureDevice *imageDevice;


@end

@implementation ELDPreLivingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)];
    [self.view addGestureRecognizer:tap];
    
    [self placeAndLayoutSubviews];
}

- (void)endEdit {
    [self.liveNameTextField resignFirstResponder];
    [self.view endEditing:YES];
}

- (void)placeAndLayoutSubviews {

    [self startBgCamera];
    

    UIView *cameraView = [[UIView alloc] init];
    [cameraView.layer addSublayer:self.previewLayer];
    
    [self.view addSubview:cameraView];
    [self.view addSubview:self.contentView];

    [cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

}

#pragma mark private method
- (void)_setupAgoreKit
{
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:AppId delegate:self];
    [self.agoraKit setChannelProfile:AgoraChannelProfileLiveBroadcasting];
    [self.agoraKit setClientRole:AgoraClientRoleBroadcaster options:nil];
    [self.agoraKit enableVideo];
    [self.agoraKit enableAudio];
    [self _setupLocalVideo];
}

- (void)_setupLocalVideo {
    self.agoraLocalVideoView = [[UIView alloc]init];
    self.agoraLocalVideoView.frame = self.view.bounds;
    [self.view insertSubview:self.agoraLocalVideoView atIndex:0];
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = 0;
    videoCanvas.view = self.agoraLocalVideoView;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    // 设置本地视图。
    [self.agoraKit setupLocalVideo:videoCanvas];
}

- (void)startAnimation {
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(self.loadingAngle * (M_PI /180.0f));

    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.loadingImageView.transform = endAngle;
    } completion:^(BOOL finished) {
        self.loadingAngle += 15;
        [self startAnimation];
    }];
}

- (void)updateLoginStateWithStart:(BOOL)start{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (start) {
            [self.goLiveButton setTitle:@"" forState:UIControlStateNormal];
            self.loadingImageView.hidden = NO;
            [self startAnimation];
            
        }else {
            [self.goLiveButton setTitle:@"Go LIVE!" forState:UIControlStateNormal];
            self.loadingImageView.hidden = YES;
        }
    });
}


#pragma mark action
- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)changeAvatarAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change Cover" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Take Photo" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self camerAction];
    }];
    [cameraAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"Upload Photo" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self photoAction];
    }];
    [albumAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [cancelAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    [alertController addAction:cameraAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)photoAction {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    self.imagePicker.editing = YES;
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

- (void)camerAction {
#if TARGET_OS_IPHONE
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        self.imagePicker.editing = YES;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
#endif
}


- (void)editAction {
    [self.liveNameTextField becomeFirstResponder];
}

- (void)flipAction {
    if (self.imageDevice == self.backDevice) {
        self.imageDevice = self.frontDevice;
    }
    
    if (self.imageDevice == self.frontDevice) {
        self.imageDevice = self.backDevice;
    }
}

- (void)goLiveAction {
    if (_liveNameTextField.text.length == 0) {
        [self showHint:@"填入房间名"];
        return;
    }
    
    [self createLiveRoom:self.liveRoom];
}

- (void)createLiveRoom:(EaseLiveRoom *)liveRoom {
    [self updateLoginStateWithStart:YES];

    ELD_WS
    [self createLiveRoom:liveRoom completion:^(EaseLiveRoom *liveRoom, BOOL success) {
        if (success) {
            weakSelf.liveRoom = liveRoom;
            [self modifyLiveRoomStatus:weakSelf.liveRoom completion:^(EaseLiveRoom *liveRoom, BOOL success) {
                [self updateLoginStateWithStart:NO];
                if (success) {
                    weakSelf.liveRoom = liveRoom;
                    [weakSelf showStartCountDownView];
                }else  {
                    [weakSelf showHint:@"开始直播失败"];
                }
            }];
        }else{
            [weakSelf showHint:@"开始直播失败"];
        }
    }];
    
}

- (void)showStartCountDownView {
    self.contentView.hidden = YES;
    
    [self.view addSubview:self.livingCountDownView];
    [self.livingCountDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.livingCountDownView startCountDown];
}


#pragma mark - CreateRoom
-(void)uploadCoverImageView:(void(^)(BOOL success))completion{
    ELD_WS
    [EaseHttpManager.sharedInstance uploadFileWithData:_fileData completion:^(NSString *url, BOOL success) {
        if (success) {
            weakSelf.liveRoom.coverPictureUrl = url;
        }
        completion(success);
    }];
}



- (void)createLiveRoom:(EaseLiveRoom *)liveRoom completion:(void(^)(EaseLiveRoom *liveRoom,BOOL success))completion{

    [EaseHttpManager.sharedInstance createLiveRoomWithRoom:liveRoom completion:^(EaseLiveRoom *room, BOOL success) {
        
        if (success) {
            _liveRoom = room;
        }
        
        completion(room,success);
    }];
}

- (void)modifyLiveRoomStatus:(EaseLiveRoom *)liveRoom completion:(void(^)(EaseLiveRoom *liveRoom,BOOL success))completion {
    
    [EaseHttpManager.sharedInstance modifyLiveroomStatusWithOngoing:liveRoom completion:^(EaseLiveRoom *room, BOOL success) {
        completion(room,success);
    }];
    
}

#pragma mark - UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editImage = info[UIImagePickerControllerEditedImage];
    _fileData = UIImageJPEGRepresentation(editImage, 1.0);
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];

    if (editImage) {
        [self uploadCoverImageView:^(BOOL success) {
            [self hideHud];
            
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.changeAvatarButton setImage:editImage forState:UIControlStateNormal];
                });
            }else{
                [self showHint:@"设置封面图失败"];
            }
        }];
    }
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TexfiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_liveNameTextField resignFirstResponder];
    return true;
}

#pragma mark gette and setter
- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _contentView.backgroundColor = ViewControllerBgBlackColor;
        _contentView.backgroundColor = UIColor.clearColor;
        
        [_contentView addSubview:self.closeButton];
        [_contentView addSubview:self.headerBgView];
        [_contentView addSubview:self.flipButton];
        [_contentView addSubview:self.flipHintLabel];
        [_contentView addSubview:self.goLiveButton];

        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentView).offset(kEaseLiveDemoPadding * 2.6);
            make.right.equalTo(_contentView).offset(-kEaseLiveDemoPadding * 1.6);
            make.size.equalTo(@30.0);
        }];

        [self.headerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.closeButton).offset(kEaseLiveDemoPadding * 2.6);
            make.left.equalTo(_contentView).offset(kEaseLiveDemoPadding * 1.6);
            make.right.equalTo(_contentView).offset(-kEaseLiveDemoPadding * 1.6);
        }];
            
        
        [self.flipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentView);
            make.bottom.equalTo(self.flipHintLabel.mas_top).offset(-14.0);
        }];
        
        [self.flipHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentView);
            make.height.equalTo(@12.0);
            make.bottom.equalTo(self.goLiveButton.mas_top).offset(-26.0);
        }];

        [self.goLiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@48.0);
            make.left.equalTo(_contentView).offset(kEaseLiveDemoPadding * 4.8);
            make.right.equalTo(_contentView).offset(-kEaseLiveDemoPadding * 4.8);
            make.bottom.equalTo(_contentView).offset(-62.0);
        }];
    }
    return _contentView;
}

- (UIView *)headerBgView {
    if (_headerBgView == nil) {

        _headerBgView = [[UIView alloc] init];
        _headerBgView.backgroundColor = UIColor.blackColor;
        _headerBgView.alpha = 0.5;
        _headerBgView.layer.cornerRadius = 8.0;
        
        [_headerBgView addSubview:self.changeAvatarButton];
        [_headerBgView addSubview:self.editButton];
        [_headerBgView addSubview:self.liveNameTextField];

        
        [self.changeAvatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerBgView).offset(8.0);
            make.left.equalTo(_headerBgView).offset(8.0);
            make.bottom.equalTo(_headerBgView).offset(-8.0);
            make.size.equalTo(@84.0);
        }];
        
        [self.liveNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.changeAvatarButton);
            make.left.equalTo(self.changeAvatarButton.mas_right).offset(12.0);
            make.right.equalTo(_headerBgView).offset(-12.0f);
            make.bottom.equalTo(self.editButton.mas_top);
        }];


        [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_headerBgView).offset(-kEaseLiveDemoPadding * 1.6);
            make.right.equalTo(_headerBgView).offset(-kEaseLiveDemoPadding * 1.6);
            make.size.equalTo(@16.0);
        }];
    
    }
    return _headerBgView;
}

- (UIButton *)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"live_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.layer.cornerRadius = 35;
    }
    return _closeButton;
}

- (UIButton *)changeAvatarButton
{
    if (_changeAvatarButton == nil) {
        _changeAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeAvatarButton addTarget:self action:@selector(changeAvatarAction) forControlEvents:UIControlEventTouchUpInside];
        _changeAvatarButton.backgroundColor = UIColor.yellowColor;
        _changeAvatarButton.layer.cornerRadius = 4.0f;
    }
    return _changeAvatarButton;
}

- (UIButton *)editButton
{
    if (_editButton == nil) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editButton setImage:[UIImage imageNamed:@"Live_edit_name"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (UIButton *)flipButton
{
    if (_flipButton == nil) {
        _flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flipButton setImage:[UIImage imageNamed:@"camera_flip"] forState:UIControlStateNormal];
        [_flipButton addTarget:self action:@selector(flipAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flipButton;
}

- (UIButton *)goLiveButton
{
    if (_goLiveButton == nil) {
        _goLiveButton = [[UIButton alloc] init];
        [_goLiveButton addTarget:self action:@selector(goLiveAction) forControlEvents:UIControlEventTouchUpInside];
        _goLiveButton.titleLabel.font = NFont(16.0f);
        [_goLiveButton setTitle:@"Go LIVE!" forState:UIControlStateNormal];
        [_goLiveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];

        [_goLiveButton setBackgroundImage:ImageWithName(@"go_live_btn_bg") forState:UIControlStateNormal];
        
        [_goLiveButton addSubview:self.loadingImageView];
        
        [self.loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_goLiveButton);
        }];

        
    }
    return _goLiveButton;
}

- (UITextField *)liveNameTextField {
    if (_liveNameTextField == nil) {
        _liveNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0,0,100,20)];
        _liveNameTextField.delegate = self;
        _liveNameTextField.placeholder = NSLocalizedString(@"login.textfield.username", @"Username");
        _liveNameTextField.backgroundColor = [UIColor clearColor];
        _liveNameTextField.returnKeyType = UIReturnKeyNext;
        _liveNameTextField.font = NFont(16.0f);
        _liveNameTextField.textColor = TextLabelWhiteColor;
        _liveNameTextField.tintColor = TextLabelWhiteColor;
        _liveNameTextField.text = @"welcome to my channel!";
    }
    return _liveNameTextField;
}

- (UILabel *)flipHintLabel {
    if (_flipHintLabel == nil) {
        _flipHintLabel = UILabel.new;
        _flipHintLabel.textColor = COLOR_HEX(0xFFFFFF);
        _flipHintLabel.font = NFont(10.0);
        _flipHintLabel.textAlignment = NSTextAlignmentCenter;
        _flipHintLabel.text = @"flip";
    }
    return _flipHintLabel;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.allowsEditing = YES;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}


- (UIImageView *)loadingImageView {
    if (_loadingImageView == nil) {
        _loadingImageView = [[UIImageView alloc] init];
        _loadingImageView.contentMode = UIViewContentModeScaleAspectFill;
        _loadingImageView.image = ImageWithName(@"loading");
        _loadingImageView.hidden = YES;
    }
    return _loadingImageView;
}


- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]){
            _session.sessionPreset = AVCaptureSessionPresetHigh;
        } else if ([_session canSetSessionPreset:AVCaptureSessionPresetiFrame1280x720]) {
            _session.sessionPreset = AVCaptureSessionPresetiFrame1280x720;
        }
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//AVLayerVideoGravityResize;
        _previewLayer.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    }
    return _previewLayer;
}

- (AVCaptureDevice *)backDevice {
    if (!_backDevice) {
        _backDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    }
    return _backDevice;
}

- (AVCaptureDevice *)frontDevice {
    if (!_frontDevice) {
        _frontDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    }
    return _frontDevice;
}

- (void)setImageDevice:(AVCaptureDevice *)imageDevice {
    _imageDevice = imageDevice;
    
    [self.session beginConfiguration];
    for (AVCaptureDeviceInput *input in self.session.inputs) {
        if (input.device.deviceType == AVCaptureDeviceTypeBuiltInWideAngleCamera) {
            [self.session removeInput:input];
        }
    }
    NSError *error;
    AVCaptureDeviceInput *imageInput = [AVCaptureDeviceInput deviceInputWithDevice:_imageDevice error:&error];
    if (error) {
        NSLog(@"photoInput init error: %@", error);
    } else {//设置输入
        if ([self.session canAddInput:imageInput]) {
            [self.session addInput:imageInput];
        }
    }
    [self.session commitConfiguration];
}

- (void)startBgCamera {
      self.imageDevice = self.backDevice;
    
      AVCapturePhotoOutput *photoOutput = [[AVCapturePhotoOutput alloc] init];
      if ([self.session canAddOutput:photoOutput]) {
          [self.session addOutput:photoOutput];
      }
    
    [self.session startRunning];

}


- (ELDLivingCountdownView *)livingCountDownView {
    if (_livingCountDownView == nil) {
        _livingCountDownView = [[ELDLivingCountdownView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 100)];
        _livingCountDownView.backgroundColor = UIColor.clearColor;
        
        ELD_WS
        _livingCountDownView.CountDownFinishBlock = ^{
            [weakSelf.livingCountDownView removeFromSuperview];
            [weakSelf.session stopRunning];

                        
            ELDPublishLiveViewController *livingVC = [[ELDPublishLiveViewController alloc] initWithLiveRoom:weakSelf.liveRoom];
            livingVC.modalPresentationStyle =  UIModalPresentationFullScreen;
            [weakSelf presentViewController:livingVC
                                   animated:YES
                                 completion:^{
            [livingVC setFinishBroadcastCompletion:^(BOOL isFinish) {
                    if (isFinish)
                        [weakSelf dismissViewControllerAnimated:false completion:nil];
            }];
            }];
        };
    }
    return _livingCountDownView;
}

- (NSData *)fileData {
    if (_fileData == nil) {
        _fileData = [NSData data];
    }
    return _fileData;
}


- (EaseLiveRoom *)liveRoom {
    if (_liveRoom == nil) {
        _liveRoom = [[EaseLiveRoom alloc] init];
        _liveRoom.title =_liveNameTextField.text;
        _liveRoom.anchor = [AgoraChatClient sharedClient].currentUsername;
        _liveRoom.liveroomType = kLiveBroadCastingTypeLIVE;
    }
    return _liveRoom;
}

@end


