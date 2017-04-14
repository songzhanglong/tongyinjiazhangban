//
//  MyOpenGLView20.h
//  MyTest
//
//  Created by smy  on 12/20/11.
//  Copyright (c) 2011 ZY.SYM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#include <sys/time.h>


@interface MyOpenGLView : UIView
{
    double                     _currentSystemVersion;
    
    CAEAGLLayer             *_eaglLayer;
    
	//	 OpenGL绘图上下文
    EAGLContext             *_glContext;
	
	//	 帧缓冲区
    GLuint                  _framebuffer; 
	
	//	 渲染缓冲区
    GLuint                  _renderBuffer; 
	
	//	 着色器句柄
    GLuint                  _programHandle;
	
	//	 YUV纹理数组
    GLuint                  _textureYUV[3]; 
	
	//	 视频宽度
    GLuint                  _videoW;  
	
	//	 视频高度
    GLuint                  _videoH;
    
    //	 View宽度
    GLuint                  _backingWidth;
	
	//	 View高度
    GLuint                  _backingHeight;
    
    GLfloat                 _viewScale;
    
    GLuint                  _positionSlot;
    
    GLuint                  _colorSlot;
	   
    //void                    *_pYuvData;
    
///////////////////////// under is adding by LinZh /////////////////
    GLuint              textureUniformYUV[3];
    
    NSTimer             *_animationTimer;
    
    NSInteger           _animationFrameInterval;
    
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
    // isn't available.
    
    BOOL    _animating;
    
    id      _displayLink;
    
    BOOL    _displayLinkSupported;
        
    //pFrameRGB data
	char    _textureData[1280*720*3];
    
    //pFrameYUV data
	char    _origData[1280*720*3];
    
    //OrigVideo  Length and width
    int     _vParams[2];

    //UIview landscape
    BOOL    _landscape;
    
    int     _OrigWidth;
    
    int     _OrigHeight;
    
    BOOL    _bGotTexture;
    //	BOOL bTakePhoto;//是否要拍照
    
    NSInteger i_camIndex;
    
#ifdef DEBUG
    
    struct timeval      _time;
    
    NSInteger           _frameRate;
    
#endif
}

@property (nonatomic) NSTimer *_animationTimer;
@property (readonly, nonatomic, getter=isAnimating) BOOL _animating;
//@property (nonatomic) NSInteger animationFrameInterval;
@property  (nonatomic) BOOL _landscape;
//@property  (nonatomic) BOOL bGotPtzControl;
@property  (nonatomic,assign) BOOL _bIsInit;
//@property  CGFloat initialDistance;


#pragma mark -
- (void)displayYUV420pData:(void *)data width:(NSInteger)w height:(NSInteger)h;
- (void)setVideoSize:(GLuint)width height:(GLuint)height;
- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;

/** 
 清除画面
 */
- (void)clearFrame;

@end
