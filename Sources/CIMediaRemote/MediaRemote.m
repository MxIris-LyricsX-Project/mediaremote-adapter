#include <dlfcn.h>
#import <Foundation/Foundation.h>

#include "MediaRemote.h"

#define MR_FRAMEWORK_PATH                                                      \
    "/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote"

// Function pointers
static Boolean (*_MRMediaRemoteSendCommand)(MRCommand command, id userInfo);
static void (*_MRMediaRemoteSetElapsedTime)(double elapsedTime);
static void (*_MRMediaRemoteRegisterForNowPlayingNotifications)(
    dispatch_queue_t queue);
static void (*_MRMediaRemoteUnregisterForNowPlayingNotifications)();
static void (*_MRMediaRemoteGetNowPlayingInfo)(
    dispatch_queue_t queue, MRMediaRemoteGetNowPlayingInfoCompletion completion);
static void (*_MRMediaRemoteGetNowPlayingApplicationPID)(
    dispatch_queue_t queue,
    MRMediaRemoteGetNowPlayingApplicationPIDCompletion completion);
static void (*_MRMediaRemoteGetNowPlayingApplicationIsPlaying)(
    dispatch_queue_t queue,
    MRMediaRemoteGetNowPlayingApplicationIsPlayingCompletion completion);
static void (*_MRMediaRemoteGetNowPlayingClient)(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingClientCompletion);


// Symbol names
static const char *const MRMediaRemoteSendCommandName = "MRMediaRemoteSendCommand";
static const char *const MRMediaRemoteSetElapsedName =
    "MRMediaRemoteSetElapsedTime";
static const char *const MRMediaRemoteRegisterForNowPlayingNotificationsName =
    "MRMediaRemoteRegisterForNowPlayingNotifications";
static const char *const MRMediaRemoteUnregisterForNowPlayingNotificationsName =
    "MRMediaRemoteUnregisterForNowPlayingNotifications";
static const char *const MRMediaRemoteGetNowPlayingInfoName =
    "MRMediaRemoteGetNowPlayingInfo";
static const char *const MRMediaRemoteGetNowPlayingApplicationPIDName =
    "MRMediaRemoteGetNowPlayingApplicationPID";
static const char *const MRMediaRemoteGetNowPlayingApplicationIsPlayingName =
    "MRMediaRemoteGetNowPlayingApplicationIsPlaying";
static const char *const MRMediaRemoteGetNowPlayingClientName = "MRMediaRemoteGetNowPlayingClient";

// Keys
NSString *kMRMediaRemoteNowPlayingInfoDidChangeNotification = @"kMRMediaRemoteNowPlayingInfoDidChangeNotification";
NSString *kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification = @"kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification";
NSString *kMRMediaRemoteNowPlayingApplicationPIDUserInfoKey = @"kMRMediaRemoteNowPlayingApplicationPIDUserInfoKey";
NSString *kMRMediaRemoteNowPlayingApplicationIsPlayingUserInfoKey = @"kMRMediaRemoteNowPlayingApplicationIsPlayingUserInfoKey";
NSString *kMRMediaRemoteNowPlayingInfoAlbum = @"kMRMediaRemoteNowPlayingInfoAlbum";
NSString *kMRMediaRemoteNowPlayingInfoArtist = @"kMRMediaRemoteNowPlayingInfoArtist";
NSString *kMRMediaRemoteNowPlayingInfoArtworkData = @"kMRMediaRemoteNowPlayingInfoArtworkData";
NSString *kMRMediaRemoteNowPlayingInfoArtworkMIMEType = @"kMRMediaRemoteNowPlayingInfoArtworkMIMEType";
NSString *kMRMediaRemoteNowPlayingInfoDuration = @"kMRMediaRemoteNowPlayingInfoDuration";
NSString *kMRMediaRemoteNowPlayingInfoElapsedTime = @"kMRMediaRemoteNowPlayingInfoElapsedTime";
NSString *kMRMediaRemoteNowPlayingInfoTimestamp = @"kMRMediaRemoteNowPlayingInfoTimestamp";
NSString *kMRMediaRemoteNowPlayingInfoTitle = @"kMRMediaRemoteNowPlayingInfoTitle";
NSString *kMRMediaRemoteNowPlayingApplicationPlaybackStateDidChangeNotification = @"kMRMediaRemoteNowPlayingApplicationPlaybackStateDidChangeNotification";
NSString *kMRMediaRemoteNowPlayingInfoUniqueIdentifier = @"kMRMediaRemoteNowPlayingInfoUniqueIdentifier";


__attribute__((constructor)) static void initialize_mediaremote() {
    void *mr_framework_handle = dlopen(MR_FRAMEWORK_PATH, RTLD_LAZY);
    if (!mr_framework_handle) {
        return;
    }

    _MRMediaRemoteSendCommand =
        dlsym(mr_framework_handle, MRMediaRemoteSendCommandName);

    _MRMediaRemoteSetElapsedTime =
        dlsym(mr_framework_handle, MRMediaRemoteSetElapsedName);
    
    _MRMediaRemoteRegisterForNowPlayingNotifications = dlsym(
        mr_framework_handle, MRMediaRemoteRegisterForNowPlayingNotificationsName);

    _MRMediaRemoteUnregisterForNowPlayingNotifications =
        dlsym(mr_framework_handle,
              MRMediaRemoteUnregisterForNowPlayingNotificationsName);

    _MRMediaRemoteGetNowPlayingInfo =
        dlsym(mr_framework_handle, MRMediaRemoteGetNowPlayingInfoName);

    _MRMediaRemoteGetNowPlayingApplicationPID =
        dlsym(mr_framework_handle, MRMediaRemoteGetNowPlayingApplicationPIDName);

    _MRMediaRemoteGetNowPlayingApplicationIsPlaying = dlsym(
        mr_framework_handle, MRMediaRemoteGetNowPlayingApplicationIsPlayingName);
    
    _MRMediaRemoteGetNowPlayingClient = dlsym(mr_framework_handle, MRMediaRemoteGetNowPlayingClientName);
}

// Public API implementations
Boolean MRMediaRemoteSendCommand(MRCommand command, id userInfo) {
    if (_MRMediaRemoteSendCommand) {
        return _MRMediaRemoteSendCommand(command, userInfo);
    }
    return false;
}

void MRMediaRemoteSetElapsedTime(double elapsedTime) {
    if (_MRMediaRemoteSetElapsedTime) {
        _MRMediaRemoteSetElapsedTime(elapsedTime);
    }
}

void MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_queue_t queue) {
    if (_MRMediaRemoteRegisterForNowPlayingNotifications) {
        _MRMediaRemoteRegisterForNowPlayingNotifications(queue);
    }
}

void MRMediaRemoteUnregisterForNowPlayingNotifications() {
    if (_MRMediaRemoteUnregisterForNowPlayingNotifications) {
        _MRMediaRemoteUnregisterForNowPlayingNotifications();
    }
}

void MRMediaRemoteGetNowPlayingInfo(
    dispatch_queue_t queue, MRMediaRemoteGetNowPlayingInfoCompletion completion) {
    if (_MRMediaRemoteGetNowPlayingInfo) {
        _MRMediaRemoteGetNowPlayingInfo(queue, completion);
    }
}

void MRMediaRemoteGetNowPlayingApplicationPID(
    dispatch_queue_t queue,
    MRMediaRemoteGetNowPlayingApplicationPIDCompletion completion) {
    if (_MRMediaRemoteGetNowPlayingApplicationPID) {
        _MRMediaRemoteGetNowPlayingApplicationPID(queue, completion);
    }
}

void MRMediaRemoteGetNowPlayingApplicationIsPlaying(
    dispatch_queue_t queue,
    MRMediaRemoteGetNowPlayingApplicationIsPlayingCompletion completion) {
    if (_MRMediaRemoteGetNowPlayingApplicationIsPlaying) {
        _MRMediaRemoteGetNowPlayingApplicationIsPlaying(queue, completion);
    }
}

void MRMediaRemoteGetNowPlayingClient(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingClientCompletion completion) {
    if (_MRMediaRemoteGetNowPlayingClient) {
        _MRMediaRemoteGetNowPlayingClient(queue, completion);
    }
}
