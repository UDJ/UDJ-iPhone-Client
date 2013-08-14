//
//  UDJPlayerManager.m
//  UDJ
//
//  Created by Matthew Graf on 7/28/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJPlayerManager.h"
#import "UDJStoredPlayer.h"
#import "UDJAppDelegate.h"
#import "UDJStoredLibraryEntry.h"
#import "JSONKit.h"
#import "UDJPlayer.h"
#import "UDJPlayerData.h"
#import "UDJPlaylist.h"
#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>
#import "UDJClient.h"

typedef unsigned long long UDJLibraryID;

@implementation UDJPlayerManager

@synthesize playerID;
@synthesize managedObjectContext, globalData, songSyncDictionary;
@synthesize isInPlayerMode, playerState, isInBackground;
@synthesize currentMediaItem, audioPlayer;
@synthesize songLength, songPosition;
@synthesize UIDelegate;
@synthesize playlistTimer, nextSongAdded;
@synthesize playlist;


#pragma mark - Singleton methods
static UDJPlayerManager* _sharedPlayerManager = nil;

+(UDJPlayerManager*)sharedPlayerManager{
    @synchronized([UDJPlayerManager class]){
        if (!_sharedPlayerManager)
            _sharedPlayerManager = [[self alloc] init];        
        return _sharedPlayerManager;
    }    
    return nil;
}

+(id)alloc{
    @synchronized([UDJPlayerManager class]){
        NSAssert(_sharedPlayerManager == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedPlayerManager = [super alloc];
        return _sharedPlayerManager;
    }
    return nil;
}

-(id)init{
    if(self = [super init]){
        self.playerID = nil;
        self.isInPlayerMode = NO;
        
        UDJAppDelegate* appDelegate = (UDJAppDelegate*)[[UIApplication sharedApplication] delegate];
        managedObjectContext = appDelegate.managedObjectContext;
        
        self.globalData = [UDJUserData sharedUDJData];

        self.audioPlayer = [[AVQueuePlayer alloc] init];
        [audioPlayer setActionAtItemEnd: AVPlayerActionAtItemEndAdvance];
        
        self.playlist = [UDJPlaylist sharedUDJPlaylist];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd) name:AVPlayerItemDidPlayToEndTimeNotification object: nil];
        
        
    }
    return self;
}


#pragma mark - Updating library

-(NSArray*)arrayWithAllLibraryEntries{
    NSError* error;
    //Set up a request to get the all library entries
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredLibraryEntry" inManagedObjectContext:managedObjectContext]];
    NSArray* libraryEntryArray = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSLog(@"Loaded %d library entries from store", [libraryEntryArray count]);
    
    if(error) {}
    return libraryEntryArray;
}

-(void)buildSyncDictionary{
    // build sync status dictionary
    NSArray* libraryEntryArray = [self arrayWithAllLibraryEntries];
    NSInteger dictionarySize = [libraryEntryArray count] == 0 ? 200 : [libraryEntryArray count];
    self.songSyncDictionary = [NSMutableDictionary dictionaryWithCapacity: dictionarySize];
    for(int i=0; i<[libraryEntryArray count]; i++){
        UDJStoredLibraryEntry* libEntry = [libraryEntryArray objectAtIndex: i];
        //NSLog(@"%llu", [libEntry.libraryID unsignedLongLongValue]);
        [self.songSyncDictionary setObject: libEntry.synced forKey: [NSNumber numberWithUnsignedLongLong: [libEntry.libraryID unsignedLongLongValue]]];
    }
}

-(NSMutableDictionary*)dictionaryForMediaItem:(MPMediaItem*)item{
    NSMutableDictionary* songDict = [NSMutableDictionary dictionaryWithCapacity: 7];
    NSString *title, *artist, *album, *genre;
    NSNumber *track, *duration;
    
    [songDict setObject: [item valueForProperty: MPMediaItemPropertyPersistentID] forKey:@"id"];
    
    if([item valueForProperty: MPMediaItemPropertyTitle]) title = [item valueForProperty: MPMediaItemPropertyTitle];
    else title = @"Untitled";
    [songDict setObject: title forKey:@"title"];
    
    if([item valueForProperty: MPMediaItemPropertyArtist]) artist = [item valueForProperty: MPMediaItemPropertyArtist];
    else artist = @"Unknown Artist";
    [songDict setObject: artist forKey:@"artist"];
    
    if([item valueForProperty: MPMediaItemPropertyAlbumTitle]) album = [item valueForProperty: MPMediaItemPropertyAlbumTitle];
    else album = @"Unknown Album";
    [songDict setObject: album forKey:@"album"];
    
    if([item valueForProperty: MPMediaItemPropertyGenre]) genre = [item valueForProperty: MPMediaItemPropertyGenre];
    else genre = @"Unknown Genre";
    [songDict setObject: genre forKey:@"genre"];
    
    if([item valueForProperty: MPMediaItemPropertyAlbumTrackNumber]) track = [item valueForProperty: MPMediaItemPropertyAlbumTrackNumber];
    else track = [NSNumber numberWithInt: 0];
    [songDict setObject: track forKey:@"track"];
    
    if([item valueForProperty: MPMediaItemPropertyPlaybackDuration]) duration = [item valueForProperty: MPMediaItemPropertyPlaybackDuration];
    else duration = [NSNumber numberWithInt: 0];
    [songDict setObject: duration forKey:@"duration"];
    
    return songDict;
}

-(void)deletePreviousLibraryEntries{
    // Fetch and delete all previous entries
    NSError* error;
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"UDJStoredLibraryEntry" inManagedObjectContext:managedObjectContext]];
    NSArray* storedEntryArray = [managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"Deleting %d stored library entires", [storedEntryArray count]);
    for(int i=0; i <[storedEntryArray count]; i++){
        UDJStoredLibraryEntry* entry = [storedEntryArray objectAtIndex: i];
        [managedObjectContext deleteObject: entry];
    }
    [managedObjectContext save: &error];
    if(error) NSLog(@"error");
}

-(void)saveLibraryEntries{  
    [self deletePreviousLibraryEntries];
    
    NSLog(@"about to save %d library entries (from songSyncDictionary)", [songSyncDictionary count]);
    NSArray* keyArray = [self.songSyncDictionary allKeys];
    for(int i=0; i<[keyArray count]; i++){
        NSNumber* entryID = [keyArray objectAtIndex: i];
        UDJStoredLibraryEntry* entry = (UDJStoredLibraryEntry*)[NSEntityDescription insertNewObjectForEntityForName:@"UDJStoredLibraryEntry" inManagedObjectContext:managedObjectContext];  
        NSNumber* number = [[NSNumber alloc] initWithUnsignedLongLong: [entryID unsignedLongLongValue]];
        [entry setSynced: [self.songSyncDictionary objectForKey: number]];
        [entry setLibraryID: number];
    }
    
    NSError* error;
    [managedObjectContext save: &error];
}

-(void)updatePlayerMusic{
    [self buildSyncDictionary];
    
    // get all songs from library
    MPMediaQuery* songQuery = [MPMediaQuery songsQuery];
    NSArray* songArray = [songQuery items];
    
    // song accumulator, used to send sets of 200 songs to server
    NSMutableArray* songAddArray = [NSMutableArray arrayWithCapacity: 201];
    
    // check each song in the library
    for(int i=0; i<[songArray count]; i++){
        MPMediaItem* mediaItem = [songArray objectAtIndex: i];
        
        // get this song's sync status
        NSNumber* libraryID = [mediaItem valueForProperty: MPMediaItemPropertyPersistentID];
        NSNumber* number = [NSNumber numberWithUnsignedLongLong: [libraryID unsignedLongLongValue]];
        NSNumber* syncStatus = [songSyncDictionary objectForKey: number]; //objectForKey: libraryID
        
        // if this song hasn't been synced, add it to a set of songs to be added
        if(syncStatus == nil || [syncStatus boolValue] == NO){
            NSDictionary* songAddDict = [self dictionaryForMediaItem: mediaItem];
            [songAddArray addObject: songAddDict];
            
            // mark the song as synced initially
            [songSyncDictionary setObject: [NSNumber numberWithBool: YES] forKey:number];
        }
        
        
        // if we have 200 songs, send them off to the server
        if([songAddArray count] == 200 || (i == [songArray count]-1 && [songAddArray count] > 0)){
            NSLog(@"Sending %d songs to server", [songAddArray count]);
            [self addSongsToServer: [songAddArray JSONString]];
            [songAddArray removeAllObjects];
        }
    }
    
    // TODO: figure out which songs have been deleted
    [self deleteRemovedItems];
    [self saveLibraryEntries]; 
    NSLog(@"done updating library");
}

-(void)addSongsToServer:(NSString*)songCollectionString{
    
    UDJClient* client = [UDJClient sharedClient];
    
    //create url users/user_id/players/player_id/library/songs
    NSString* urlString = client.baseURLString;
    urlString = [urlString stringByAppendingFormat: @"/players/%@/library/songs", self.playerID, nil];
    
    //set up request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self.globalData;
    request.method = UDJRequestMethodPUT;
    request.userData = @"songSetAdd";
    
    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: [UDJUserData sharedUDJData].headers];
    [requestHeaders setValue:@"playerMethodsDelegate" forKey:@"delegate"];
    [requestHeaders setValue:@"text/json" forKey:@"content-type"];
    request.additionalHTTPHeaders = requestHeaders;
    
    // set body to the JSON song array
    [request setHTTPBodyString:songCollectionString];
    
    [request send];
}

-(void)removeSongsFromServer:(NSArray*)songs{
    UDJClient* client = [UDJClient sharedClient];
    
    NSString* urlString = client.baseURLString;
    urlString = [urlString stringByAppendingFormat: @"/players/%@/library", self.playerID, nil];
    
    //set up request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self.globalData;
    request.method = UDJRequestMethodPOST;
    request.userData = @"songDelete";
    
    // add the songs to delete;
    NSLog(@"Empty Array %@", [[NSArray new] JSONString]);
    request.params = [NSDictionary dictionaryWithObjectsAndKeys:[songs JSONString], @"to_delete", [[NSArray new] JSONString], @"to_add", nil];
    
    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: [UDJUserData sharedUDJData].headers];
    [requestHeaders setValue:@"playerMethodsDelegate" forKey:@"delegate"];
    [requestHeaders setValue:@"text/json" forKey:@"content-type"];
    request.additionalHTTPHeaders = requestHeaders;
    
    [request send];
}

// Songs is an array of NSNumbers
-(void)removeSongsFromSyncDictionary:(NSArray*)songs{
    for(int i=0; i<[songs count]; i++){
        NSNumber* libraryID = [songs objectAtIndex: i];
        if([songSyncDictionary objectForKey: libraryID] != nil){
            [songSyncDictionary removeObjectForKey: libraryID];
        }
    }
}

-(void)deleteRemovedItems{
    // get all items actually in the iPod library
    MPMediaQuery* songQuery = [MPMediaQuery songsQuery];
    NSArray* songArray = [songQuery items];
    NSMutableDictionary* libraryDictionary = [NSMutableDictionary dictionaryWithCapacity: [songArray count]];
    for(MPMediaItem* item in songArray){
        NSNumber* libraryID = [item valueForProperty: MPMediaItemPropertyPersistentID];
        NSNumber* keyAsNumber = [NSNumber numberWithUnsignedLongLong: [libraryID unsignedLongLongValue]];
        [libraryDictionary setObject: [NSNumber numberWithBool:YES] forKey: keyAsNumber];
    }
    
    // check each song in our song sync dictionary, and if its
    // not in the iPod library anymore, add it to the accumulating array
    NSMutableArray* deleteItemsArray = [NSMutableArray arrayWithCapacity: 50];
    NSArray* songSyncKeys = [songSyncDictionary allKeys];
    for(int i=0; i<[songSyncKeys count]; i++){
        NSNumber* libraryID = [songSyncKeys objectAtIndex: i];
        if([libraryDictionary objectForKey: libraryID] == nil){
            [deleteItemsArray addObject: libraryID];
        }
    }
    
    // if there were songs to delete, let the server know
    if([deleteItemsArray count] > 0){
        NSLog(@"About to delete %d songs", [deleteItemsArray count]);
        [self removeSongsFromServer: deleteItemsArray];
        // TODO: move this do didLoadResponse
        /*if([response statusCode] == 200){
            NSLog(@"Successfully removed songs");
            [self removeSongsFromSyncDictionary: deleteItemsArray];
        }
        else NSLog(@"There was a problem removing songs");*/
    }
}

#pragma mark - Player state methods

-(void)changePlayerState:(PlayerState)newState{
    [self setPlayerState: newState];
    [self sendPlayerStateRequest: newState];
}

-(void)sendPlayerStateRequest:(PlayerState)newState{
    UDJClient* client = [UDJClient sharedClient];
    
    NSString* urlString = client.baseURLString;
    urlString = [urlString stringByAppendingFormat:@"/players/%@", self.playerID, nil];
    
    // create request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self.globalData;
    request.method = UDJRequestMethodPOST;
    request.userData = @"changeState";
    
    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: globalData.headers];
    [requestHeaders setValue:@"text/json" forKey:@"content-type"];
    [requestHeaders setValue:@"playerMethodsDelegate" forKey:@"delegate"];
    request.additionalHTTPHeaders = requestHeaders;
    
    // include state parameter
    NSArray* stateArray = [NSArray arrayWithObjects:@"inactive", @"play", @"pause", nil];
    request.HTTPBodyString = [[NSDictionary dictionaryWithObjectsAndKeys: [stateArray objectAtIndex: newState], @"state", nil] JSONString];
    
    //send request
    [request send];
    NSLog(@"Requested state change to %@", [stateArray objectAtIndex: newState]);
}


#pragma mark - Keeping playlist up to date

-(void)playlistTimerFired{
    [[UDJPlaylist sharedUDJPlaylist] sendPlaylistRequest];
    if(isInBackground && [self canQueueNextSong]){
        [self queueUpNextSong];
    }
}

-(void)beginPlaylistUpdates{
    self.playlistTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(playlistTimerFired) userInfo:nil repeats:YES];
}

-(void)endPlaylistUpdates{
    if(self.playlistTimer){
        [self.playlistTimer invalidate];
        self.playlistTimer = nil;
    }
}

#pragma mark - Transition to next song

-(void)playerItemDidReachEnd{
    if(!isInBackground){
        NSLog(@"Playing next song");
        [self playNextSong];
    }
    else{
        
        // if there are songs on the queue but no current song, update the current song to item at the top
        if([[UDJPlaylist sharedUDJPlaylist] count] > 0){
            // update the current song on the server side
            [UDJPlaylist sharedUDJPlaylist].currentSong = [[UDJPlaylist sharedUDJPlaylist] songAtIndex:0];
            [self sendCurrentSongRequest: [UDJPlaylist sharedUDJPlaylist].currentSong.songID];
            NSLog(@"new song %@", [UDJPlaylist sharedUDJPlaylist].currentSong.title);
        }
        
        // find the mediaItem for the current song
        NSString* stringID = [UDJPlaylist sharedUDJPlaylist].currentSong.songID;
        UDJLibraryID mediaItemID = strtoull([stringID UTF8String], NULL, 0);
        MPMediaPropertyPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue: [NSNumber numberWithUnsignedLongLong:mediaItemID]forProperty:MPMediaItemPropertyPersistentID];
        MPMediaQuery* query = [[MPMediaQuery alloc] initWithFilterPredicates: [NSSet setWithObject: predicate]];
        [self updateCurrentMediaItem: [[query items] objectAtIndex: 0]];
    }
}

-(void)playNextSong{
    
    // THIS ASSUMES THE PLAYER IS RELATIVELY UP TO DATE
    // (and it will be since the timer updates the playlist every 5 seconds)
    UDJSong* nextSong = [[UDJPlaylist sharedUDJPlaylist] songAtIndex: 0];
    
    if(nextSong){
        NSLog(@"sending request to change song");
        // go ahead and change the UDJPlaylist next song so we can start playing it
        [UDJPlaylist sharedUDJPlaylist].currentSong = nextSong;
        [self playPlaylistCurrentSong];
        //[audioPlayer advanceToNextItem];
        [self sendCurrentSongRequest: nextSong.songID];
    }
    else{
        NSLog(@"setting state to paused");
        [self setPlayerState:PlayerStatePaused];
        [self sendPlayerStateRequest: PlayerStatePaused];
    }
}

#pragma mark - Playback

-(void)updateSongPosition:(NSInteger)seconds{
    [audioPlayer seekToTime: CMTimeMakeWithSeconds(seconds, 1)];
}

-(float)currentPlaybackTime{
    if(![audioPlayer currentItem]) return 0;
    float time = (float)CMTimeGetSeconds([audioPlayer currentTime]);
    return time;
}

-(void)sendCurrentSongRequest:(NSString*)libraryID{
    UDJClient* client = [UDJClient sharedClient];
    
    NSString* urlString = client.baseURLString;
    urlString = [urlString stringByAppendingFormat:@"/players/%@/current_song", self.playerID, nil];

    // create request
    UDJRequest* request = [UDJRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.delegate = self.globalData;
    request.method = UDJRequestMethodPOST;
    request.userData = @"changeCurrentSong";

    // set up the headers, including which type of request this is
    NSMutableDictionary* requestHeaders = [NSMutableDictionary dictionaryWithDictionary: globalData.headers];
    [requestHeaders setValue:@"playerMethodsDelegate" forKey:@"delegate"];
    request.additionalHTTPHeaders = requestHeaders;

    request.params = [NSDictionary dictionaryWithObject: libraryID forKey: @"lib_id"];
    request.timeoutInterval = 3;

    //send request
    if(!isInBackground) [request send];
    else [request sendSynchronously];
}

-(void)playPlaylistCurrentSong{

    // find the mediaItem for the current song
    NSString* stringID = [UDJPlaylist sharedUDJPlaylist].currentSong.songID;
    UDJLibraryID mediaItemID = strtoull([stringID UTF8String], NULL, 0);
    MPMediaPropertyPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue: [NSNumber numberWithUnsignedLongLong:mediaItemID]forProperty:MPMediaItemPropertyPersistentID];
    MPMediaQuery* query = [[MPMediaQuery alloc] initWithFilterPredicates: [NSSet setWithObject: predicate]];
    [self updateCurrentMediaItem: [[query items] objectAtIndex: 0]];
    
    // update the current item on the audioplayer
    if([[audioPlayer items] count] > 0){
        AVPlayerItem* itemToRemove = [[audioPlayer items] objectAtIndex: 0];
        [audioPlayer removeItem: itemToRemove];
    }
    NSURL* url = [currentMediaItem valueForProperty: MPMediaItemPropertyAssetURL];
    AVPlayerItem* playerItem = [[AVPlayerItem alloc] initWithURL:url];
    [audioPlayer insertItem:playerItem afterItem: nil];
    
    // start up the audioplayer
    if([audioPlayer rate] == 0){
        [audioPlayer play];
    }
    [self setPlayerState: PlayerStatePlaying];
    
    NSLog(@"%d songs on queue", [[audioPlayer items] count]);
}

-(BOOL)play{
    
    // if there is already a media item playing, resume it
    if(currentMediaItem){
        [self setPlayerState:PlayerStatePlaying];
        [audioPlayer play];
        return YES;
    }
    
    // if there are songs on the queue but no current song, update the current song to item at the top
    if(![UDJPlaylist sharedUDJPlaylist].currentSong && [[UDJPlaylist sharedUDJPlaylist] count] > 0){
        NSLog(@"trying to change song");
        [UDJPlaylist sharedUDJPlaylist].currentSong = [[UDJPlaylist sharedUDJPlaylist] songAtIndex:0];
        NSLog(@"changed current song");
        [self sendCurrentSongRequest: [UDJPlaylist sharedUDJPlaylist].currentSong.songID]; // update the current song on the server side
    }
        
    // if there is now a current song, update the current media item and begin playing
    // return YES to let caller know there was a song to play
    if([UDJPlaylist sharedUDJPlaylist].currentSong){
        [self playPlaylistCurrentSong];
        return YES;
    }
    
    // if there are no songs to play, return NO
    return NO;
}

-(void)pause{
    [self setPlayerState: PlayerStatePaused];
    [audioPlayer pause];
    [self sendPlayerStateRequest: PlayerStatePaused];
}

-(void)updateCurrentMediaItem:(MPMediaItem*)item{
    self.currentMediaItem = item;
    self.songLength = [[currentMediaItem valueForProperty: MPMediaItemPropertyPlaybackDuration] floatValue];
    self.songPosition = 0;
    
    PlayerViewController* playerViewController = (PlayerViewController*)self.UIDelegate;
    [playerViewController updateDisplayWithItem: item];
}

#pragma mark - Background playback

-(void)printItemDurations{
    for(int i=0; i<[[audioPlayer items] count]; i++){
        AVPlayerItem* item = [[audioPlayer items] objectAtIndex: i];
        float time = (float)[item duration].value/(float)[item duration].timescale;
        NSLog(@"Item %d, time = %f", i, time);
    }
}

// checks if its early enough in the song to modify queue without disrupting playback
-(BOOL)canQueueNextSong{
    NSNumber* songTime = [currentMediaItem valueForProperty: MPMediaItemPropertyPlaybackDuration];
    NSInteger timeAsInt = [songTime intValue];
    if([self currentPlaybackTime] > timeAsInt-15) return NO;
    return YES;
}

-(void)queueUpNextSong{
    // find the mediaItem for the top song on the playlist
    UDJSong* nextSong = [[UDJPlaylist sharedUDJPlaylist] songAtIndex: 0];
    if (nextSong) {
        NSLog(@"Next song: %@", nextSong.title);
        NSString* stringID = [[[UDJPlaylist sharedUDJPlaylist] songAtIndex:0] songID];
        UDJLibraryID mediaItemID = strtoull([stringID UTF8String], NULL, 0);
        MPMediaPropertyPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue: [NSNumber numberWithUnsignedLongLong:mediaItemID]forProperty:MPMediaItemPropertyPersistentID];
        MPMediaQuery* query = [[MPMediaQuery alloc] initWithFilterPredicates: [NSSet setWithObject: predicate]];
        MPMediaItem* nextMediaItem = [[query items] objectAtIndex: 0];
        
        // add next item to queue, just after the item playing
        NSURL* url = [nextMediaItem valueForProperty: MPMediaItemPropertyAssetURL];
        AVPlayerItem* nextItem = [[AVPlayerItem alloc] initWithURL:url];
        [audioPlayer insertItem:nextItem afterItem: [[audioPlayer items] objectAtIndex:0]];
        
        // remove last item
        if([[audioPlayer items] count] > 2){
            AVPlayerItem* itemToRemove = [[audioPlayer items] objectAtIndex: 2];
            [audioPlayer removeItem: itemToRemove];
        }
        
        [self printItemDurations];
    }
}

#pragma mark - Preparing for background

-(void)resetAudioPlayer{
    [audioPlayer removeAllItems];
    self.currentMediaItem = nil;
}

-(void)enterBackgroundMode{
    [self setIsInBackground: YES];
}

-(void)exitBackgroundMode{
    [self setIsInBackground: NO];
    if([[audioPlayer items] count] > 1){
        AVPlayerItem* itemToRemove = [[audioPlayer items] objectAtIndex: 1];
        [audioPlayer removeItem: itemToRemove];
    }
}


#pragma mark - Response handling

- (void)request:(UDJRequest*)request didLoadResponse:(UDJResponse*)response{
    NSString* requestType = [request userData];
    NSLog(@"Player Manager response code: %d, request type %@, URL %@", [response statusCode], requestType, [request.URL absoluteString]);
}


@end
