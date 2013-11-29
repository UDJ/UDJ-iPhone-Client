//
//  UDJConfigurator.m
//  UDJ
//
//  Created by Matthew Graf on 5/30/12.
//  Copyright (c) 2012 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "UDJConfigurator.h"

@implementation UDJConfigurator


/* 
 App Description 
 ---------------
 These values are used by any service that shows 'shared from XYZ'
 */
- (NSString*)appName {
    return @"UDJ";
}

- (NSString*)appURL {
    return @"https://www.udjplayer.com/";
}

/*
 API Keys
 --------
 This is the longest step to getting set up, it involves filling in API keys for the supported services.
 It should be pretty painless though and should hopefully take no more than a few minutes.
 
 Each key below as a link to a page where you can generate an api key.  Fill in the key for each service below.
 
 A note on services you don't need:
 If, for example, your app only shares URLs then you probably won't need image services like Flickr.
 In these cases it is safe to leave an API key blank.
 
 However, it is STRONGLY recommended that you do your best to support all services for the types of sharing you support.
 The core principle behind ShareKit is to leave the service choices up to the user.  Thus, you should not remove any services,
 leaving that decision up to the user.
 */

// Facebook - https://developers.facebook.com/apps
// SHKFacebookAppID is the Application ID provided by Facebook
// SHKFacebookLocalAppID is used if you need to differentiate between several iOS apps running against a single Facebook app. Useful, if you have full and lite versions of the same app,
// and wish sharing from both will appear on facebook as sharing from one main app. You have to add different suffix to each version. Do not forget to fill both suffixes on facebook developer ("URL Scheme Suffix"). Leave it blank unless you are sure of what you are doing. 
// The CFBundleURLSchemes in your App-Info.plist should be "fb" + the concatenation of these two IDs.
// Example: 
//    SHKFacebookAppID = 555
//    SHKFacebookLocalAppID = lite
// 
//    Your CFBundleURLSchemes entry: fb555lite
- (NSString*)facebookAppId {
    return @"42"; // Dummy value
}

- (NSString*)facebookLocalAppId {
    return @"";
}

//Change if your app needs some special Facebook permissions only. In most cases you can leave it as it is.
- (NSArray*)facebookListOfPermissions {    
    return [NSArray arrayWithObjects:@"publish_stream", @"offline_access", nil];
}

// Twitter - http://dev.twitter.com/apps/new
/*
 Important Twitter settings to get right:
 
 Differences between OAuth and xAuth
 --
 There are two types of authentication provided for Twitter, OAuth and xAuth.  OAuth is the default and will
 present a web view to log the user in.  xAuth presents a native entry form but requires Twitter to add xAuth to your app (you have to request it from them).
 If your app has been approved for xAuth, set SHKTwitterUseXAuth to 1.
 
 Callback URL (important to get right for OAuth users)
 --
 1. Open your application settings at http://dev.twitter.com/apps/
 2. 'Application Type' should be set to BROWSER (not client)
 3. 'Callback URL' should match whatever you enter in SHKTwitterCallbackUrl.  The callback url doesn't have to be an actual existing url.  The user will never get to it because ShareKit intercepts it before the user is redirected.  It just needs to match.
 */

/*
 If you want to force use of old-style, pre-IOS5 twitter framework, for example to ensure
 twitter accounts don't end up in the devices account store, set this to true.
 */
- (NSNumber*)forcePreIOS5TwitterAccess {
    return [NSNumber numberWithBool:false];
}

- (NSString*)twitterConsumerKey {
    return @"42"; // Dummy value
}

- (NSString*)twitterSecret {
    return @"42"; // Dummy value
}
// You need to set this if using OAuth, see note above (xAuth users can skip it)
- (NSString*)twitterCallbackUrl {
    return @"https://www.udjplayer.com/";
}
// To use xAuth, set to 1
- (NSNumber*)twitterUseXAuth {
    return [NSNumber numberWithInt:0];
}
// Enter your app's twitter account if you'd like to ask the user to follow it when logging in. (Only for xAuth)
- (NSString*)twitterUsername {
    return @"";
}

- (NSArray*)defaultFavoriteTextSharers {
    return [NSArray arrayWithObjects:@"SHKTwitter", @"SHKFacebook", nil];
}

- (NSString*)sharersPlistName{
    return @"SHKSharersCustom.plist";
}

- (NSNumber*)showActionSheetMoreButton{
    return [NSNumber numberWithBool: NO];
}


@end
