//
//  MyAudioplayer.h
//  com.topvs.client
//
//  Created by LinZh107 on 14-8-13.
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "PlayerApi.h"

#define kNumberBuffers 3
#define NUM_PER_BUFFER 10 //每次从音频链表读取的音频侦数
#define SIZE_PER_BUFFER 3200 // 10*160*sizeof(short) -- 每侦长度为160个字节，但是压缩率为2 char－>short
@interface MyAudioPlayer : NSObject
{
    NSThread* mThread;
    
    int iNodeIndex; //当前登陆的节点
    int iViindex;   //当前节点对应的存储区下标
    
    //音频流描述对象
    AudioStreamBasicDescription mDataFormat;
    //音频队列
    AudioQueueRef mPlayQueue;
    AudioQueueBufferRef mBuffers[kNumberBuffers];
    //播放音频文件ID
    AudioFileID mAudioFile;
    char* pRecvData;
    
    UInt32 mNumPacketsToRead;
    SInt64 mCurrentPacket;
    UInt32 bufferByteSize;
//    AudioStreamPacketDescription *mPacketDescs;
    BOOL mIsRunning;
}

//播放方法定义
//- (void) setAudioParam;
- (void) startAudioThread;
- (void) startPlayAudio;
- (void) stopAudioThread;
- (void) cancelThread;

//定义包数据的读取方法
- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer;

@property (nonatomic)     int iNodeIndex; //当前登陆的节点
@property (nonatomic)     int iViindex;   //当前节点对应的存储区下标

@end