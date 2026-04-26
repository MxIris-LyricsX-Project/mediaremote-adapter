#include <dlfcn.h>
#import <Foundation/Foundation.h>
#import <OpenSoftLinking/OpenSoftLinking.h>

#include "MediaRemote.h"

OPEN_SOFT_LINK_PRIVATE_FRAMEWORK_OPTIONAL(MediaRemote)

// Local helpers: declare a private API + its graceful public wrapper in one line.
// Two variants because C does not allow `return expr;` in a void function.
#define MR_SOFT_FN(name, rt, decls, names, fallback)                       \
    OPEN_SOFT_LINK_MAY_FAIL(MediaRemote, name, rt, decls, names)           \
    rt name decls {                                                        \
        if (!canLoad_MediaRemote_##name()) return (fallback);              \
        return name##_soft names;                                          \
    }

#define MR_SOFT_VOID_FN(name, decls, names)                                \
    OPEN_SOFT_LINK_MAY_FAIL(MediaRemote, name, void, decls, names)         \
    void name decls {                                                      \
        if (!canLoad_MediaRemote_##name()) return;                         \
        name##_soft names;                                                 \
    }

MR_SOFT_FN(MRMediaRemoteSendCommand, Boolean,
    (MRCommand command, id userInfo), (command, userInfo), false)
MR_SOFT_VOID_FN(MRMediaRemoteSetElapsedTime,
    (double elapsedTime), (elapsedTime))
MR_SOFT_VOID_FN(MRMediaRemoteRegisterForNowPlayingNotifications,
    (dispatch_queue_t queue), (queue))
MR_SOFT_VOID_FN(MRMediaRemoteUnregisterForNowPlayingNotifications, (void), ())
MR_SOFT_VOID_FN(MRMediaRemoteGetNowPlayingInfo,
    (dispatch_queue_t queue, MRMediaRemoteGetNowPlayingInfoCompletion completion),
    (queue, completion))
MR_SOFT_VOID_FN(MRMediaRemoteGetNowPlayingApplicationPID,
    (dispatch_queue_t queue, MRMediaRemoteGetNowPlayingApplicationPIDCompletion completion),
    (queue, completion))
MR_SOFT_VOID_FN(MRMediaRemoteGetNowPlayingApplicationIsPlaying,
    (dispatch_queue_t queue, MRMediaRemoteGetNowPlayingApplicationIsPlayingCompletion completion),
    (queue, completion))
MR_SOFT_VOID_FN(MRMediaRemoteGetNowPlayingClient,
    (dispatch_queue_t queue, MRMediaRemoteGetNowPlayingClientCompletion completion),
    (queue, completion))

// NSString constants: fallback string literals identical to the framework's
// actual exported values. The constructor below overwrites each one with the
// framework's real pointer when available; on failure the fallback is kept.
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
NSString *kMRMediaRemoteNowPlayingInfoUniqueIdentifier = @"kMRMediaRemoteNowPlayingInfoUniqueIdentifier";
NSString *kMRMediaRemoteNowPlayingApplicationPlaybackStateDidChangeNotification = @"kMRMediaRemoteNowPlayingApplicationPlaybackStateDidChangeNotification";

__attribute__((constructor))
static void resolveMediaRemoteConstants(void) {
    void *handle = MediaRemoteLibrary();
    if (!handle) return;

    #define OSL_RESOLVE_NSSTRING(name) do {                                          \
        NSString * __unsafe_unretained *sym =                                        \
            (NSString * __unsafe_unretained *)dlsym(handle, #name);                  \
        if (sym != NULL && *sym != nil) name = *sym;                                 \
    } while (0)

    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingInfoDidChangeNotification);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingApplicationPIDUserInfoKey);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingApplicationIsPlayingUserInfoKey);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingInfoAlbum);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingInfoArtist);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingInfoArtworkData);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingInfoArtworkMIMEType);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingInfoDuration);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingInfoElapsedTime);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingInfoTimestamp);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingInfoTitle);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingInfoUniqueIdentifier);
    OSL_RESOLVE_NSSTRING(kMRMediaRemoteNowPlayingApplicationPlaybackStateDidChangeNotification);

    #undef OSL_RESOLVE_NSSTRING
}
