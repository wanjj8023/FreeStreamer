/*
 * This file is part of the FreeStreamer project,
 * (C)Copyright 2011-2013 Matias Muhonen <mmu@iki.fi>
 * See the file ''LICENSE'' for using the code.
 */

#import <Foundation/Foundation.h>

@class FSAudioStream;
@class FSCheckAudioFileFormatRequest;
@class FSParsePlaylistRequest;

/*
 * FSAudioController is a convenience wrapper for using FSAudioStream:
 * it resolves playlists automatically so you can directly feed it
 * with a playlist URL.
 */
@interface FSAudioController : NSObject {
    NSString *_url;
    FSAudioStream *_audioStream;
    
    BOOL _readyToPlay;
    
    FSCheckAudioFileFormatRequest *_checkAudioFileFormatRequest;
    FSParsePlaylistRequest *_parsePlaylistRequest;
}

- (void)play;
- (void)playFromURL:(NSString*)url;
- (void)stop;
- (void)pause;

@property (nonatomic,assign) NSString *url;
@property (readonly) FSAudioStream *stream;

@end
