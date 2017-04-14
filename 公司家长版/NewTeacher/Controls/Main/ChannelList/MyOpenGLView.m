//
//  MyOpenGLView.m
//  MyTest
//
//  Created by smy on 12/20/11.
//  Copyright (c) 2011 ZY.SYM. All rights reserved.
//

#import "MyOpenGLView.h"
#import "PlayerApi.h"

#define FSH @"varying lowp vec2 TexCoordOut;\
\
uniform sampler2D SamplerY;\
uniform sampler2D SamplerU;\
uniform sampler2D SamplerV;\
\
void main(void)\
{\
mediump vec3 yuv;\
lowp vec3 rgb;\
\
yuv.x = texture2D(SamplerY, TexCoordOut).r;\
yuv.y = texture2D(SamplerU, TexCoordOut).r - 0.5;\
yuv.z = texture2D(SamplerV, TexCoordOut).r - 0.5;\
\
rgb = mat3( 1,       1,         1,\
0,       -0.39465,  2.03211,\
1.13983, -0.58060,  0) * yuv;\
\
gl_FragColor = vec4(rgb, 1);\
}"

#define VSH @"attribute vec4 position;\
attribute vec2 TexCoordIn;\
varying vec2 TexCoordOut;\
\
void main(void)\
{\
gl_Position = position;\
TexCoordOut = TexCoordIn;\
}"

enum AttribEnum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXTURE,
    ATTRIB_COLOR,
};

enum TextureType
{
    TEXY = 0,
    TEXU,
    TEXV,
    TEXC
};

static GLfloat squareVertices[] = {
    -1.0f,  -1.0f,
    1.0f,  -1.0f,
    -1.0f,   1.0f,
    1.0f,   1.0f,
};
const GLfloat squareVertices2[] = {
    -1.0f,  1.0f,             // Top left
    -1.0f, -1.0f,             // Bottom left
    1.0f,  1.0f,             // Top right
    1.0f, -1.0f,             // Bottom right 1-576.0/704*2
};
static const GLfloat coordVertices[] = {
    0.0f,  1.0f,
    1.0f,  1.0f,
    0.0f,  0.0f,
    1.0f,  0.0f,
};

//#define PRINT_CALL 1

@interface MyOpenGLView()

/**
 初始化YUV纹理
 */ //- (void)setupYUVTexture;

/**
 创建缓冲区
 @return 成功返回TRUE 失败返回FALSE
 */ //- (BOOL)createFrameAndRenderBuffer;

/**
 销毁缓冲区
 */ //- (void)destoryFrameAndRenderBuffer;

//加载着色器
/**
 初始化YUV纹理
 */
- (void)loadShader;

/**
 编译着色代码
 @param shader        代码
 @param shaderType    类型
 @return 成功返回着色器 失败返回－1
 */
- (GLuint)compileShader:(NSString*)shaderCode withType:(GLenum)shaderType;

/**
 渲染
 */
- (void)render;

@end //end interface



@implementation MyOpenGLView

@synthesize _animationTimer;
@synthesize  _landscape;
//@synthesize  initialDistance;//,bGotPtzControl;
@synthesize  _bIsInit;
@synthesize  _animating;

//#pragma mark -设置openGL
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (GLuint)compileShader:(NSString*)shaderString withType:(GLenum)shaderType
{
   	//  1
    if (!shaderString) {
        NSLog(@"Error loading shader: error.localizedDescription");
        exit(1);
    }
    else {
        //        NSLog(@"shader code-->%@", shaderString);
    }
    
	//  2
    GLuint shaderHandle = glCreateShader(shaderType);
    
	//  3
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
	//  4
    glCompileShader(shaderHandle);
    
	//  5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE)
    {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

/**
 加载着色器
 */
- (void)loadShader
{
	/** 	 1	 */
    GLuint vertexShader = [self compileShader:VSH withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:FSH withType:GL_FRAGMENT_SHADER];
    
	/** 	 2	 */
    _programHandle = glCreateProgram();
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fragmentShader);
    
	/** 	 绑定需要在link之前	 */
    glBindAttribLocation(_programHandle, ATTRIB_VERTEX, "position");
    glBindAttribLocation(_programHandle, ATTRIB_TEXTURE, "TexCoordIn");
    
    glLinkProgram(_programHandle);
    
	/** 	 3	 */
    GLint linkSuccess;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE)
    {
        GLchar messages[256];
        glGetProgramInfoLog(_programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"<<<<着色器连接失败 %@>>>", messageString);
        goto exit;
    }
    
exit:
    if (vertexShader)
		glDeleteShader(vertexShader);
    if (fragmentShader)
		glDeleteShader(fragmentShader);
}

- (void)clearFrame
{
    if ([self window])
    {
        [EAGLContext setCurrentContext:_glContext];
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        //glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer); //REMOVE
        [_glContext presentRenderbuffer:GL_RENDERBUFFER];
    }
}

// Replace initWithFrame with this
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _currentSystemVersion = [[UIDevice currentDevice].systemVersion doubleValue];
        _animationFrameInterval = 1.0;
        _animating = FALSE;
        _displayLinkSupported = FALSE;
        _displayLink = nil;
        _animationTimer = nil;
        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            _displayLinkSupported = TRUE;
        
        //bTakePhoto = false;
        
        _eaglLayer = (CAEAGLLayer*) self.layer;
        _eaglLayer.opaque = YES;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
        
        _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!_glContext || ![EAGLContext setCurrentContext:_glContext])
        {
            NSLog(0, @"failed to setup EAGLContext");
            self = nil;
            return nil;
        }
        
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        _viewScale = [UIScreen mainScreen].scale;
        printf("CurrentSystemVersion = %0.1f, _viewScale = %0.2f\n",_currentSystemVersion, _viewScale);
        [self loadShader];
        
        textureUniformYUV[0] = glGetUniformLocation(_programHandle, "SamplerY");
        textureUniformYUV[1] = glGetUniformLocation(_programHandle, "SamplerU");
        textureUniformYUV[2] = glGetUniformLocation(_programHandle, "SamplerV");
        
        [self clearFrame];
    }
    return self;
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    //[self updateVertices];//2014/06/30 NEW
}

- (void)layoutSubviews
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized(self)
        {
            [EAGLContext setCurrentContext:_glContext];
            /*********************************/
            //    destoryFrameAndRenderBuffer
            /*********************************/
            if (_framebuffer){
                glDeleteFramebuffers(1, &_framebuffer);
            }
            if (_renderBuffer){
                glDeleteRenderbuffers(1, &_renderBuffer);
            }
            _framebuffer = 0;
            _renderBuffer = 0;
            /*********************************/
            
            
            /*********************************/
            //    createFrameAndRenderBuffer
            /*********************************/
            glGenFramebuffers(1, &_framebuffer);
            glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
            
            glGenRenderbuffers(1, &_renderBuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
            
            if (![_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer])
            {
                NSLog(@"attach渲染缓冲区失败");
            }
            CGRect screenBounds = [[UIScreen mainScreen] bounds];
            _backingWidth = screenBounds.size.width*_viewScale;
            _backingHeight = screenBounds.size.height*_viewScale;
            
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
            
            if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            {
                NSLog(@"创建缓冲区错误 0x%x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
            }
            //[self updateVertices]; //2014-06-30 NEW
            /*********************************/
        }
    });
}

- (void)setVideoSize:(GLuint)width height:(GLuint)height
{
    _videoW = width;
    _videoH = height;
    
    void *blackData = malloc(_videoW * _videoH * 1.5);
	if(blackData)
        memset(blackData, 0, _videoW * _videoH * 1.5);
    else
        return;
    [EAGLContext setCurrentContext:_glContext];
    
    glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXY]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, width, height, 0,
                 GL_RED_EXT, GL_UNSIGNED_BYTE, blackData);
    
    glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXU]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, width/2, height/2, 0,
                 GL_RED_EXT, GL_UNSIGNED_BYTE, blackData + _videoW * _videoH);
    
    glBindTexture(GL_TEXTURE_2D, _textureYUV[TEXV]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, width/2, height/2, 0,
                 GL_RED_EXT, GL_UNSIGNED_BYTE, blackData + _videoW * _videoH * 5/4);
    
    free(blackData);
}

- (void)render
{
    [EAGLContext setCurrentContext:_glContext];
    //竖屏
    if (!_landscape) {
        CGFloat hei = _backingWidth * _videoH/_videoW;
        glViewport(0, (_backingHeight-hei)/2 + 64,//修复不同屏幕(retina)的适配
                   _backingWidth, hei );
    }
    //横屏
    else if(_backingWidth > _backingHeight){
        glViewport(0, (_backingWidth-_backingHeight), _backingWidth, _backingHeight);
    }
    else{  //iphone6-8.1 ok
        glViewport(0, (_backingHeight-_backingWidth), _backingHeight, _backingWidth);
    }
    
    glClearColor(0.0, 0.0, 0.0, 0.0); // NEW
    glClear(GL_COLOR_BUFFER_BIT); //NEW
    glUseProgram(_programHandle);
    
    // Update attribute values
    //  glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices2);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    
    glVertexAttribPointer(ATTRIB_TEXTURE, 2, GL_FLOAT, 0, 0, coordVertices);
    glEnableVertexAttribArray(ATTRIB_TEXTURE);
    
    // Draw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark -接口
- (void)displayYUV420pData:(void *)data width:(NSInteger)w height:(NSInteger)h
{
    //_pYuvData = data;
    if (//_offScreen ||
        !self.window)
    {
        return;
    }
    @synchronized(self)
    {
        [EAGLContext setCurrentContext:_glContext];
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        if (0 == _textureYUV[0])
            glGenTextures(3, _textureYUV);
        
        if (w != _videoW || h != _videoH)
            [self setVideoSize:w height:h];
        
        [EAGLContext setCurrentContext:_glContext];
        for(int i=0; i<3; i++)
        {
            const NSUInteger widths[3]  = { _videoW, _videoW/2, _videoW/2 };
            const NSUInteger heights[3] = { _videoH, _videoH/2, _videoH/2 };
            const UInt8 *pixels[3] = { data, data+_videoW*_videoH, data+_videoW*_videoH*5/4};
            
            glBindTexture(GL_TEXTURE_2D, _textureYUV[i]);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, widths[i], heights[i], 0,
                         GL_RED_EXT, GL_UNSIGNED_BYTE, pixels[i]);
            
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
        }
        if (_textureYUV[0] != 0)
        {
            for (int i = 0; i < 3; ++i)
            {
                glActiveTexture(GL_TEXTURE0+i);
                glBindTexture(GL_TEXTURE_2D, _textureYUV[i]);
                glUniform1i(textureUniformYUV[i], i);
                
                [self render];
            }
        }
        
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
        //glFlush();
        [_glContext presentRenderbuffer:GL_RENDERBUFFER];
        
    }
    
#ifdef DEBUG
    GLenum err = glGetError();
    if (err != GL_NO_ERROR)
    {
        printf("GL_ERROR=======>%d\n", err);
    }
    struct timeval nowtime;
    gettimeofday(&nowtime, NULL);
    if (nowtime.tv_sec != _time.tv_sec)
    {
        printf("视频 %d 帧率:   %d\n", self.tag, _frameRate);
        memcpy(&_time, &nowtime, sizeof(struct timeval));
        _frameRate = 1;
    }
    else
    {
        _frameRate++;
    }
#endif
}

//add LinZh107 2014-06-24
- (void)drawView
{
    static int nConsume_Time = 0;
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent(); //获取毫秒级要乘于1000
    int frame_rate = API_GetVideoFrame(_origData, _vParams, i_camIndex);
    //int frame_rate = 0;
    if(frame_rate > 0)
    {
        //~~~~~~~~~~~ got the yuv data ~~~~~~~~~~
        //if(bTakePhoto && frame_rate > 0)
    	//	[self takePhoto];
        [self displayYUV420pData:_origData width:_vParams[0] height:_vParams[1]];
        
        //add LinZh107 fix that play speed is too fast sometime  and allway will blond
        //获取毫秒级要乘于1000
        nConsume_Time = (int)(1000.0/frame_rate - ( CFAbsoluteTimeGetCurrent()-startTime)*1000) - 5;
        //printf("openGLView nConsume_Time=%d\n",nConsume_Time);
        if(nConsume_Time > 0)
        {
            usleep(nConsume_Time*1000);
            nConsume_Time = 0;
        }
	}
    else
    {
        //printf("MyOpenGLView drawView Thread Sleep 10\n");
        usleep(10000);
    }
    
    return;
}

- (void)startAnimation
{
    //	printf("%s(%d)\n",__FILE__,__LINE__);
	memset(_textureData, 0, sizeof(_textureData));
    i_camIndex = 0;
    _vParams[0] = 352;
    _vParams[1] = 288;
    if (!_animating)
    {
        [self setVideoSize:_vParams[0] height:_vParams[1]];
        if (_displayLinkSupported)
        {
            _displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView)];
            [_displayLink setFrameInterval:_animationFrameInterval];
            [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
        {
            _animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 25.0) * _animationFrameInterval) target:self selector:@selector(drawView) userInfo:nil repeats:TRUE];
        }
        _animating = TRUE;
    }
    
}


- (void)stopAnimation {
    
	int ret = API_StopPlay(i_camIndex);
	if (ret < 0) {
        NSLog(@"错误-关闭摄像头失败！");
//        UIAlertView *alertv = [[UIAlertView alloc]initWithTitle:@"错误"
//                                                        message:@"关闭摄像头失败！"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil, nil];
//		[alertv show];
		return;
	}
    
    if (_animating) {
        if (_displayLinkSupported) {
            [_displayLink invalidate];
            _displayLink = nil;
        }
        else {
            [_animationTimer invalidate];
            _animationTimer = nil;
        }
        
        _animating = FALSE;
    }
    
}

@end