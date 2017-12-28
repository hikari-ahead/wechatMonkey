//
//  WechatPrivateClass.h
//  wechatMonkeyDylib
//
//  Created by kuangjeon on 28/12/2017.
//  Copyright © 2017 kuangjeon. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface BraceletRankStepsView:UIView
- (void)setStepDatas:(id)datas;
@end

@interface MMTabBarController:UITabBarController
@end

@interface WCDeviceStepObject
- (unsigned int)m7StepCount;
@end

@interface SKBuiltinBuffer_t
@property(retain, nonatomic) NSData *buffer; // @dynamic buffer
@end

@interface SystemMessageCellView:UIView
- (id)initWithViewModel:(id)model;
@end

@interface CBaseContact : NSObject
@property(retain, nonatomic) NSString *m_nsUsrName; // @synthesize m_nsUsrName;
@property(retain, nonatomic) NSString *m_nsHeadImgUrl; // @synthesize m_nsHeadImgUrl;
- (id)getContactDisplayName;
@end

@interface CContactMgr : NSObject
- (id)getSelfContact;
@end

@interface MMServiceCenter : NSObject
+ (id)defaultCenter;
- (id)getService:(Class)class;
@end

@interface WCRedEnvelopesLogicMgr
@property(nonatomic) int cgiCmdid; // @dynamic cgiCmdid;
@property(retain, nonatomic) NSString *errorMsg; // @dynamic errorMsg;
@property(nonatomic) int errorType; // @dynamic errorType;
@property(retain, nonatomic) NSString *platMsg; // @dynamic platMsg;
@property(nonatomic) int platRet; // @dynamic platRet;
@property(retain, nonatomic) SKBuiltinBuffer_t *retText; // @dynamic retText;
- (void)OnWCToHongbaoCommonResponse:(id) response Request:(id)response;
- (void)OpenRedEnvelopesRequest:(id)request;
- (void)ReceiverQueryRedEnvelopesRequest:(id)request;
@end

@interface CMessageWrap
@property(nonatomic, strong) NSString* m_nsContent;        //发送消息的内容
@property(nonatomic, strong) NSString* m_nsToUsr;          //发送人
@property(nonatomic, strong) NSString* m_nsFromUsr;        //接收人
@property(nonatomic, assign) unsigned long m_uiStatus;
@property(nonatomic, assign) unsigned long m_uiCreateTime;
@property(nonatomic, assign) unsigned long m_uiMessageType;
- (CMessageWrap*)initWithMsgType:(int)type;
@end

@interface CMessageMgr:NSObject
- (void)onRevokeMsg:(id)msg;
- (void)AddLocalMsg:(NSString *)from MsgWrap:(CMessageWrap *)msgWrap;
- (void)AsyncOnAddMsg:(id)msg MsgWrap:(CMessageWrap *)wrap;
@end
