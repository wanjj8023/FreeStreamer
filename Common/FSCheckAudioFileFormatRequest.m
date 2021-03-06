/*
 * This file is part of the FreeStreamer project,
 * (C)Copyright 2011-2013 Matias Muhonen <mmu@iki.fi>
 * See the file ''LICENSE'' for using the code.
 */

#import "FSCheckAudioFileFormatRequest.h"

@implementation FSCheckAudioFileFormatRequest

@synthesize url=_url;
@synthesize onCompletion;
@synthesize onFailure;

- (id)init
{
    self = [super init];
    if (self) {
        _format = kFSAudioFileFormatUnknown;
        _playlist = NO;
    }
    return self;
}

- (void)start
{
    if (_connection) {
        return;
    }
    
    _format = kFSAudioFileFormatUnknown;
    _playlist = NO;
    _contentType = @"";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:@"HEAD"];
    
    @synchronized (self) {
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    if (!_connection) {
        onFailure();
        return;
    }
}

- (void)cancel
{
    if (!_connection) {
        return;
    }
    @synchronized (self) {
        [_connection cancel];
        _connection = nil;
    }
}

/*
 * =======================================
 * Properties
 * =======================================
 */

- (FSAudioFileFormat)format
{
    return _format;
}

- (NSString *)contentType
{
    return _contentType;
}

- (BOOL)playlist
{
    return _playlist;
}

/*
 * =======================================
 * NSURLConnectionDelegate
 * =======================================
 */

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _contentType = response.MIMEType;
    
    _format = kFSAudioFileFormatUnknown;
    _playlist = NO;
    
    if ([_contentType isEqualToString:@"audio/mpeg"]) {
        _format = kFSAudioFileFormatMP3;
    } else if ([_contentType isEqualToString:@"audio/x-wav"]) {
        _format = kFSAudioFileFormatWAVE;
    } else if ([_contentType isEqualToString:@"audio/x-aifc"]) {
        _format = kFSAudioFileFormatAIFC;
    } else if ([_contentType isEqualToString:@"audio/x-aiff"]) {
        _format = kFSAudioFileFormatAIFF;
    } else if ([_contentType isEqualToString:@"audio/x-m4a"]) {
        _format = kFSAudioFileFormatM4A;
    } else if ([_contentType isEqualToString:@"audio/mp4"]) {
        _format = kFSAudioFileFormatMPEG4;
    } else if ([_contentType isEqualToString:@"audio/x-caf"]) {
        _format = kFSAudioFileFormatCAF;
    } else if ([_contentType isEqualToString:@"audio/aac"] ||
               [_contentType isEqualToString:@"audio/aacp"]) {
        _format = kFSAudioFileFormatAAC_ADTS;
    } else if ([_contentType isEqualToString:@"audio/x-mpegurl"]) {
        _format = kFSAudioFileFormatM3UPlaylist;
        _playlist = YES;
    } else if ([_contentType isEqualToString:@"audio/x-scpls"]) {
        _format = kFSAudioFileFormatPLSPlaylist;
        _playlist = YES;
    } else if ([_contentType isEqualToString:@"text/plain"]) {
        /* The server did not provide meaningful content type;
           last resort: check the file suffix, if there is one */
        
        NSString *absoluteUrl = [response.URL absoluteString];
        
        if ([absoluteUrl hasSuffix:@".mp3"]) {
            _format = kFSAudioFileFormatMP3;
        } else if ([absoluteUrl hasSuffix:@".mp4"]) {
            _format = kFSAudioFileFormatMPEG4;
        } else if ([absoluteUrl hasSuffix:@".m3u"]) {
            _format = kFSAudioFileFormatM3UPlaylist;
            _playlist = YES;
        } else if ([absoluteUrl hasSuffix:@".pls"]) {
            _format = kFSAudioFileFormatPLSPlaylist;
            _playlist = YES;
        }
    }
    
    [_connection cancel];
    _connection = nil;
    
    onCompletion();
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Do nothing
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    @synchronized (self) {
        _connection = nil;
        _format = kFSAudioFileFormatUnknown;
        _playlist = NO;
    }
    
    onFailure();
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Do nothing
}

@end
