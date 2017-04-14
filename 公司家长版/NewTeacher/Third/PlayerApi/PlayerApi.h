//
//  PlayerApi.h
//  nvsplayer
//
//  Created by 张 仁松 on 10-10-25.
//  Copyright 2010 Santachi. All rights reserved.
//

#define MAX_NODE_NUM 2048
#define CHILD_NODE_NUM 200
#define MAX_INPUT_IO_NUM 16
#define MAX_OUTPUT_IO_NUM 16

#  ifdef __cplusplus
extern "C" {
#  endif /* __cplusplus */
    
    
    extern int API_InitLibInstance();
    /* 接口函数说明： 初始化解码器和网络库
     * 参数：无
     *
     * 返回值：成功返回：Instance handler， 失败返回 -1。
     * */
    
    
    extern int  API_RequestLogin(const char* addr,int port,const char *name,const char* password);
    /* 接口函数说明： 请求登录
     * 参数：
     * const char*          addr        //平台ip地址
     * int                  port        //平台网络端口(默认:9100)
     * const char*          name        //登录用户名
     * const char*          password    //登录密码
     *
     * 返回值：成功返回：0， 失败返回值及原因如下。
     * 				case -1 :
     str = "已经被登录";
     break;
					case -2 :
					case -3 :
					case -4 :
     str = "网络连接超时";
     break;
					case -5:
					case -6:
					case -7:
     str = "服务端没有回应";
     break;
					case -8:
					case -9:
     str = "网络不够通畅，解析服务信息失败";
     break;
					case -10:
     str = "密码错误..";
     break;
					case -11:
     str = "SMU服务器无连接..";
     break;
					case -12:
     str = "该用户已在其他地方登陆..";
     break;
					case -13:
     str = "登陆请求被拒绝, 用户名未激活";
     break;
					case -14:
     str = "登陆请求被拒绝, 用户名已超过使用期限";
     break;
					case -15:
     str = "共享用户数超出限定值";
     break;
					default :
     str = "登录设备失败，错误码" + ret;
     break;
     * */
    
    
    extern int API_GetDeviceList(int DevNumArray[], int CamStatusArray[], int SWiStatusArray[], int SWoStatusArray[], char** CamStrArray);
    /* 接口函数说明： 获取设备列表，仅返回目录和音视频节点，不同于iOS平台
     * 参数：
     * int		DevNumArray[3]  	//[out] 存储各种设备节点数
                    DevNumArray[0]	存储该平台的总摄像头数(默认MAX_NODE_NUM最大支持到1000个）
                    DevNumArray[1]	存储该平台的网络开关输入数
                    DevNumArray[1]	存储该平台的网络开关输出数
     
     * int 		CamStatusArray[]	//[out] 存储摄像头在线与否状态，对应于DevNumArray[0]
     * int		SWiStatusArray[]	//[out] 存储网络开关输入状态， 对应于DevNumArray[1]
     * int		SWoStatusArray[]	//[out] 存储网络开关输出状态， 对应于DevNumArray[2]
     * String	ArrayGUName[]       //[out]	存储设备的名字。
     *
     * 成功返回 0,
     *
     */
    
    
    extern int  API_StartPlay(int iNodeIndex, int viindex);
    /* 接口函数说明： 开启监控
     * 参数：
     * int      iNodeIndex      //[in] 节点标识，范围为:0 ~ intArray[0]-1;
     * int      viindex         //[in] 增加分屏后用来标志哪个实例的相机
     * 返回值：成功返回：0， 失败返回 -1。
     * */
    
    
    extern int  API_getFrameNum(int viindex);
    /* 接口函数说明： 获取本地缓冲的视频帧数
     * 参数：
     * int      viindex         //[in] 增加分屏后用来标志哪个实例的相机
     *
     * 返回值： 返回缓冲链表中的视频帧数 num。
     * */
    
    
    extern int  API_GetVideoFrame(char* pOutBuffer, int *vParams, int viindex);
    //2014-07-5  	LinZh107
    /* 接口函数说明： 获取1帧视频帧(已经解码成YUV420P格式纯数据)。
     * 参数：
     * char*    pOutBuffer      //[out] pFrameYUV data, 推荐大小为[1280*720*3]，即720p的画幅;
     * int*     vParams         //[out] 存放视频分辨率 width:vParams[0] height:vParams[1]
     * int      viindex         //[in] 增加分屏后用来标志哪个实例的相机
     *
     * 返回值： 成功返回：帧速率frame_rate， 失败返回 <0 值。
     * */
    
    
    extern int  API_GetAudioFrame(char* pAudioData, int frame_cnt, int viindex);
    //2014-09-16  	LinZh107
    /* 接口函数说明： 获取n帧音频帧(已经解码成PCM格式纯数据)。
     * 参数：
     * char*        pAudioData     //[out] 单次取出的音频帧存放处 PCM databuffer，sizeof(pAudioData) 应等于 frame_cnt*320
     * int*         frame_cnt      //[in] 单次取出的音频帧数
     *
                                 ///设置音频参数
                                 mDataFormat.mSampleRate = 8000;//采样率
                                 mDataFormat.mFormatID = kAudioFormatLinearPCM;
                                 mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
                                 mDataFormat.mChannelsPerFrame = 1;///单声道
                                 mDataFormat.mFramesPerPacket = 1;//每一个packet一侦数据
                                 mDataFormat.mBitsPerChannel = 16;//每个采样点16bit量化
                                 mDataFormat.mBytesPerFrame = (mDataFormat.mBitsPerChannel/8) * mDataFormat.mChannelsPerFrame;
                                 mDataFormat.mBytesPerPacket = mDataFormat.mBytesPerFrame ;
                                 pAudioData = malloc(SIZE_PER_BUFFER);
     * int      viindex         //[in] 增加分屏后用来标志哪个实例的相机
     *
     * 返回值： 成功返回：0， 失败返回 <0 的值。
     * */
    
    
    extern int API_DomeControl(int iNodeIndex, int state, int iSpeed, char* cmd);
    /* 接口函数说明： 云台转向及镜头焦距控制。
     * 参数：
     * int      iNodeIndex      //[in] 节点标识，范围为:0 ~ intArray[0]-1;
     * int      state           //[in] 1为开始动作，0为停止动作
     * int      iSpeed          //[in] 云台动作的速率，范围为0--10,推荐为5
     * char*    cmd             //[in] 云台动作命令标识，可取值如下：
                                        "PL" ---> 左旋转
                                        "PR" ---> 右旋转
                                        "TU" ---> 上扬
                                        "TD" ---> 下摆
                                        "ZOUT" ---> 焦距拉远，缩小
                                        "ZIN" ---> 焦距拉近，放大                                
     *
     * 返回值： 成功返回：0， 失败返回 <0 的值。
     * */
    
    
    extern int  API_StopPlay(int viindex);
    /* 接口函数说明： 停止监控
     * 参数：
     * int      viindex         //[in] 增加分屏后用来标志哪个实例的相机
     *
     * 返回值：成功返回：0。
     * */
    
    
    extern int  API_RequestLogout();
    /* 接口函数说明： 登出平台
     * 参数：无
     *
     * 返回值：成功返回：0。
     * */
    
    extern int  API_DeleteLibInstance();
    /* 接口函数说明： 释放解码器并释放内存
     * 参数：无
     *
     * 返回值：成功返回：0。 异常放回 -1
     * */
    
    
    extern int API_StartChart(int iNodeIndex, int viindex);
    //2015-06-16  	LinZh107
    /* 接口函数说明：创建对讲线程, 主要处理的是将接收的音频放入列表(接收后还是要用以上GetAudioParam()来解码，不处理发送)
     * 参数：
     * int      iNodeIndex      //[in] 节点标识，范围为:0 ~ intArray[0]-1;
     * int      viindex         //[in] 增加分屏后用来标志哪个实例的相机
     *
     * 返回值：成功返回：0， 失败返回-1。
     * */
    
    extern int API_SendVoiceData(const short* sArray, int dataLen);
    //2015-06-16  	LinZh107
    /* 接口函数说明：发送音频到前端
     * 参数：
     * const short* sArray      //[in] 原始的音频数据(即PCM数据,不包含任何头)
     * int dataLen              //[in] sizeof VoiceArray[] (PCM长度)
     *
     * 返回值：成功返回：发送长度(bufLen)， 失败返回  < 0。
     * */
    
    extern int API_StopChart(void);
    //2015-06-16  	LinZh107
    /* 接口函数说明：退出对讲线程
     * 参数：无
     *
     * 返回值：成功返回：0， 失败返回-1。
     * */
    
    
    extern int API_IoControl(int iNodeIndex, int bStatus, int bReturn);
    //2015-07-02  	LinZh107
    /* 接口函数说明：NetWork Switch/IO control
     * 参数：
     * int          iNodeIndex  //[in] io index of devlistNode
     * int          bStatus     //[in] 1为开始动作，0为停止动作
     * int          bReturn     //[in] return immediately, equal to set or get flags
     *
     * 返回值： 成功返回：0， 失败返回 <0 的值。
     * */
    
    /*******************************************************************
     以下为保留接口
     *******************************************************************/
    extern int  API_GetPuImageDisplayPara(int curindex,int intArray[] );
	
    extern int  API_SetPuImageDisplayPara( int curindex,int intArray[] );

    extern int  API_GetPuImageEncodePara( int curindex,int intArray[]);

    extern int  API_SetPuImageEncodePara( int curindex,int intArray[]);
    //******************************************************************/
    
#  ifdef __cplusplus
}
#  endif /* __cplusplus */