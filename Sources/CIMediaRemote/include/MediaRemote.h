/*
 * Media remote framework header.
 *
 * Copyright (c) 2013-2014 Cykey (David Murray)
 * All rights reserved.
 */

#ifndef MEDIAREMOTE_H_
#define MEDIAREMOTE_H_

#include <CoreFoundation/CoreFoundation.h>
#include <dispatch/dispatch.h>
#include <objc/objc.h>
#include "_MRNowPlayingClientProtobuf.h"

#if __cplusplus
extern "C" {
#endif
    
#pragma mark - Notifications
    extern NSString *kMRMediaRemoteNowPlayingInfoDidChangeNotification;
    extern NSString *kMRMediaRemoteNowPlayingPlaybackQueueDidChangeNotification;
    extern NSString *kMRMediaRemotePickableRoutesDidChangeNotification;
    extern NSString *kMRMediaRemoteNowPlayingApplicationDidChangeNotification;
    extern NSString *kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification;
    extern NSString *kMRMediaRemoteRouteStatusDidChangeNotification;
    extern NSString *kMRMediaRemoteNowPlayingApplicationPlaybackStateDidChangeNotification;
    
#pragma mark - Keys
    extern NSString *kMRMediaRemoteNowPlayingApplicationPIDUserInfoKey;
    extern NSString *kMRMediaRemoteNowPlayingApplicationIsPlayingUserInfoKey;
    extern NSString *kMRMediaRemoteNowPlayingInfoAlbum;
    extern NSString *kMRMediaRemoteNowPlayingInfoArtist;
    extern NSString *kMRMediaRemoteNowPlayingInfoArtworkData;
    extern NSString *kMRMediaRemoteNowPlayingInfoArtworkMIMEType;
    extern NSString *kMRMediaRemoteNowPlayingInfoChapterNumber;
    extern NSString *kMRMediaRemoteNowPlayingInfoComposer;
    extern NSString *kMRMediaRemoteNowPlayingInfoDuration;
    extern NSString *kMRMediaRemoteNowPlayingInfoElapsedTime;
    extern NSString *kMRMediaRemoteNowPlayingInfoGenre;
    extern NSString *kMRMediaRemoteNowPlayingInfoIsAdvertisement;
    extern NSString *kMRMediaRemoteNowPlayingInfoIsBanned;
    extern NSString *kMRMediaRemoteNowPlayingInfoIsInWishList;
    extern NSString *kMRMediaRemoteNowPlayingInfoIsLiked;
    extern NSString *kMRMediaRemoteNowPlayingInfoIsMusicApp;
    extern NSString *kMRMediaRemoteNowPlayingInfoMediaType;
    extern NSString *kMRMediaRemoteNowPlayingInfoPlaybackRate;
    extern NSString *kMRMediaRemoteNowPlayingInfoProhibitsSkip;
    extern NSString *kMRMediaRemoteNowPlayingInfoQueueIndex;
    extern NSString *kMRMediaRemoteNowPlayingInfoRadioStationIdentifier;
    extern NSString *kMRMediaRemoteNowPlayingInfoRepeatMode;
    extern NSString *kMRMediaRemoteNowPlayingInfoShuffleMode;
    extern NSString *kMRMediaRemoteNowPlayingInfoStartTime;
    extern NSString *kMRMediaRemoteNowPlayingInfoSupportsFastForward15Seconds;
    extern NSString *kMRMediaRemoteNowPlayingInfoSupportsIsBanned;
    extern NSString *kMRMediaRemoteNowPlayingInfoSupportsIsLiked;
    extern NSString *kMRMediaRemoteNowPlayingInfoSupportsRewind15Seconds;
    extern NSString *kMRMediaRemoteNowPlayingInfoTimestamp;
    extern NSString *kMRMediaRemoteNowPlayingInfoTitle;
    extern NSString *kMRMediaRemoteNowPlayingInfoTotalChapterCount;
    extern NSString *kMRMediaRemoteNowPlayingInfoTotalDiscCount;
    extern NSString *kMRMediaRemoteNowPlayingInfoTotalQueueCount;
    extern NSString *kMRMediaRemoteNowPlayingInfoTotalTrackCount;
    extern NSString *kMRMediaRemoteNowPlayingInfoTrackNumber;
    extern NSString *kMRMediaRemoteNowPlayingInfoUniqueIdentifier;
    extern NSString *kMRMediaRemoteNowPlayingInfoRadioStationHash;
    extern NSString *kMRMediaRemoteOptionMediaType;
    extern NSString *kMRMediaRemoteOptionSourceID;
    extern NSString *kMRMediaRemoteOptionTrackID;
    extern NSString *kMRMediaRemoteOptionStationID;
    extern NSString *kMRMediaRemoteOptionStationHash;
    extern NSString *kMRMediaRemoteRouteDescriptionUserInfoKey;
    extern NSString *kMRMediaRemoteRouteStatusUserInfoKey;
    
#pragma mark - API
    typedef enum {
        kMRPlay = 0,
        kMRPause = 1,
        kMRTogglePlayPause = 2,
        kMRStop = 3,
        kMRNextTrack = 4,
        kMRPreviousTrack = 5,
        kMRToggleShuffle = 6,
        kMRToggleRepeat = 7,
        kMRStartForwardSeek = 8,
        kMREndForwardSeek = 9,
        kMRStartBackwardSeek = 10,
        kMREndBackwardSeek = 11,
        kMRGoBackFifteenSeconds = 12,
        kMRSkipFifteenSeconds = 13,
        kMRLikeTrack = 0x6A,
        kMRBanTrack = 0x6B,
        kMRAddTrackToWishList = 0x6C,
        kMRRemoveTrackFromWishList = 0x6D
    } MRCommand;
    
    Boolean MRMediaRemoteSendCommand(MRCommand command, id userInfo);
    void MRMediaRemoteSetElapsedTime(double elapsedTime);
    void MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_queue_t queue);
    void MRMediaRemoteUnregisterForNowPlayingNotifications();
    
    typedef void (^MRMediaRemoteGetNowPlayingInfoCompletion)(CFDictionaryRef information);
    typedef void (^MRMediaRemoteGetNowPlayingApplicationPIDCompletion)(int PID);
    typedef void (^MRMediaRemoteGetNowPlayingApplicationIsPlayingCompletion)(Boolean isPlaying);
    typedef void (^MRMediaRemoteGetNowPlayingClientCompletion)(_MRNowPlayingClientProtobuf * _Nullable client);
    
    void MRMediaRemoteGetNowPlayingApplicationPID(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingApplicationPIDCompletion completion);
    void MRMediaRemoteGetNowPlayingInfo(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingInfoCompletion completion);
    void MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingApplicationIsPlayingCompletion completion);
    void MRMediaRemoteGetNowPlayingClient(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingClientCompletion completion);
#if __cplusplus
}
#endif

#endif /* MEDIAREMOTE_H_ */
