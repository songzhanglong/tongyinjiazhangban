//
//  MyAudioPlayer.m
//  com.topvs.client
//
//  Created by LinZh107 on 14-8-13.
//
//

#import "MyAudioPlayer.h"

@implementation MyAudioPlayer

@synthesize iNodeIndex, iViindex;

// 回调（Callback）函数的实现
static void HandleOutputBuffer( void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer )
{
    MyAudioPlayer* player = (__bridge MyAudioPlayer*)inUserData;

    int ret = -1;
    if(player->mIsRunning)
        ret = API_GetAudioFrame(player->pRecvData, NUM_PER_BUFFER, player->iViindex);
                    //frameCnt * frameLen = MIN_SIZE_PER_FRAME = 1600 short = 3200 char
    if(ret == 0)
    {
        //将缓冲的容量设置为与读取的音频数据一样大小（确保内存空间）
        inBuffer->mAudioDataByteSize = SIZE_PER_BUFFER;
        memcpy(inBuffer->mAudioData, player->pRecvData, SIZE_PER_BUFFER);
        // 完成给队列配置缓存的处理
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil);
    }
}


//初始化方法（为NSObject中定义的初始化方法）
- (id) init
{
    ///设置音频参数
    mDataFormat.mSampleRate = 8000;//采样率
    mDataFormat.mFormatID = kAudioFormatLinearPCM;
    mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    mDataFormat.mChannelsPerFrame = 1;///单声道
    mDataFormat.mFramesPerPacket = 1;//每一个packet一侦数据
    mDataFormat.mBitsPerChannel = 16;//每个采样点16bit量化
    mDataFormat.mBytesPerFrame = (mDataFormat.mBitsPerChannel/8) * mDataFormat.mChannelsPerFrame;
    mDataFormat.mBytesPerPacket = mDataFormat.mBytesPerFrame ;
    pRecvData = malloc(SIZE_PER_BUFFER);
    return self;
}

#pragma mark -接口

//out API
- (void) startAudioThread
{
    mThread = [[NSThread alloc] initWithTarget:self
                                      selector:@selector(startPlayAudio)
                                        object:nil];
    [mThread setName:@"PlayAudioThread"];
    [mThread start];
}

//音频播放方法的实现
- (void) startPlayAudio
{
    mIsRunning = true;
    ///创建一个新的从audioqueue到硬件层的通道
    // 播放用的音频队列
    AudioQueueNewOutput(&mDataFormat, HandleOutputBuffer, (__bridge void *)(self), nil, nil, 0, &mPlayQueue);
    
    // 创建并分配缓存空间
    int i = 0;
    while(i < kNumberBuffers && mIsRunning)
    {
        AudioQueueAllocateBuffer(mPlayQueue, SIZE_PER_BUFFER, &mBuffers[i]);
        //读取包数据
        if ([self readPacketsIntoBuffer:mBuffers[i]] == 0)
            i++;
        else
            [NSThread sleepForTimeInterval:0.05];
    }
    
    //队列处理开始，此后系统会自动调用回调（Callback）函数
    AudioQueueStart(mPlayQueue, nil);
}

- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer
{
    // 从文件中接受包数据并保存到缓存(buffer)中
    int ret = API_GetAudioFrame(pRecvData, NUM_PER_BUFFER, iViindex);
    if(ret == 0)
    {
        //将缓冲的容量设置为与读取的音频数据一样大小（确保内存空间）
        buffer->mAudioDataByteSize = SIZE_PER_BUFFER;
        memcpy(buffer->mAudioData, pRecvData, SIZE_PER_BUFFER);
        AudioQueueEnqueueBuffer(mPlayQueue, buffer, 0, nil);
        return 0;
    }
    else
    {
        return -1;
    }
}

//out API
- (void) stopAudioThread
{
    mIsRunning = false;
    AudioQueueStop(mPlayQueue, false);
    AudioQueueDispose (mPlayQueue, false);
    
//    AudioFileClose (aqData.mAudioFile);     // 4
//    free (mPacketDescs);                    // 5
}

- (void) cancelThread
{
    [mThread cancel];
}

@end