/**
 * Copyright 2011 Matthew M. Graf
 *
 * This file is part of UDJ.
 *
 * UDJ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * UDJ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with UDJ.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "MainTabBarController.h"
#import "PlaylistViewController.h"
#import "RandomViewController.h"
#import "ArtistsViewController.h"
#import "PlayerInfoViewController.h"
#import "PlayerViewController.h"
#import "ParticipantsViewController.h"
#import "UDJPlayerManager.h"

@implementation MainTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)initForPlayerMode:(BOOL)isPlayer{
    
    [UDJPlayerManager sharedPlayerManager].isInPlayerMode = isPlayer;
    
    // Do any additional setup after loading the view from its nib. 
    PlaylistViewController* playlistViewController = [[PlaylistViewController alloc] initWithNibName:@"NewPlaylistViewController" bundle:[NSBundle mainBundle]];
    playlistViewController.title = NSLocalizedString(@"Playlist", @"Playlist");
    playlistViewController.leaveButton.hidden = YES;
    
    // the artists page should be the root view of a new navigation controller
    ArtistsViewController* artistsViewController = [[ArtistsViewController alloc] initWithNibName:@"ArtistsViewController" bundle:[NSBundle mainBundle]];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:artistsViewController];
    navigationController.title = NSLocalizedString(@"Library", @"Library");
    navigationController.navigationBarHidden = YES;
    
    RandomViewController* randomViewController = [[RandomViewController alloc] initWithNibName:@"RandomViewController" bundle:[NSBundle mainBundle]];
    randomViewController.title = NSLocalizedString(@"Random", @"Random");
    
    PlayerViewController* playerViewController = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:[NSBundle mainBundle]];
    playerViewController.title = NSLocalizedString(@"Player", @"Player");
    
    ParticipantsViewController* participantsViewController = [[ParticipantsViewController alloc] initWithNibName:@"ParticipantsViewController" bundle:[NSBundle mainBundle]];
    participantsViewController.title = NSLocalizedString(@"Participants", @"Participants");
    
    // if this isn't being used as a player, just push the regular views
    if(!isPlayer){
        self.viewControllers = [NSArray arrayWithObjects:playlistViewController, navigationController, randomViewController, nil];        
    }
    // if this is a player, add the player info view
    else {
        self.viewControllers = [NSArray arrayWithObjects:playerViewController, playlistViewController, navigationController, randomViewController, nil];
        // set the player icon
        UITabBarItem* playerItem = [self.tabBar.items objectAtIndex: 0];
        [playerItem setImage: [UIImage imageNamed: @"playericon.png"]];
    }
    
    self.tabBar.tintColor = [UIColor colorWithRed:(35.0/255.0) green:(59.0/255.0) blue:(79.0/255.0) alpha:1];
    
    
    // set tab bar images
    NSInteger indexModify = isPlayer ? 1 : 0;
    UITabBarItem* playlistItem = [self.tabBar.items objectAtIndex: 0 + indexModify];
    [playlistItem setImage: [UIImage imageNamed: @"playlisticon.png"]];
    
    UITabBarItem* libraryItem = [self.tabBar.items objectAtIndex: 1 + indexModify];
    [libraryItem setImage: [UIImage imageNamed: @"libraryicon.png"]];
    
    UITabBarItem* randomItem = [self.tabBar.items objectAtIndex: 2 + indexModify];
    [randomItem setImage: [UIImage imageNamed: @"randomicon.png"]];   
    
    //UITabBarItem* participantsItem = [self.tabBar.items objectAtIndex: 3 + indexModify];
    //[participantsItem setImage: [UIImage imageNamed: @"participanticon.png"]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
