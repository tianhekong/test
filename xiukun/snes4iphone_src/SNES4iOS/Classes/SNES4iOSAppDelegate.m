//
//  SNES4iPadAppDelegate.m
//  SNES4iPad
//
//  Created by Yusef Napora on 5/10/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "SNES4iOSAppDelegate.h"

#import "EmulationViewController.h"
#import "RomSelectionViewController.h"
#import "RomDetailViewController.h"
#import "SettingsViewController.h"
#import "ControlPadConnectViewController.h"
#import "ControlPadManager.h"
#import "WebBrowserViewController.h"

SNES4iOSAppDelegate *AppDelegate()
{
	return (SNES4iOSAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@implementation SNES4iOSAppDelegate

@synthesize window, splitViewController, romSelectionViewController, romDetailViewController, settingsViewController;
@synthesize controlPadConnectViewController, controlPadManager;
@synthesize romDirectoryPath, saveDirectoryPath, snapshotDirectoryPath;
@synthesize emulationViewController, webViewController, webNavController;
@synthesize tabBarController;
@synthesize snesControllerAppDelegate, snesControllerViewController;
@synthesize sramDirectoryPath;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDictionary *new = [NSDictionary dictionaryWithObject:@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16" forKey:@"UserAgent"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:new];
    }

    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
	settingsViewController = [[SettingsViewController alloc] init];
	// access the view property to force it to load
	settingsViewController.view = settingsViewController.view;
	
	controlPadConnectViewController = [[ControlPadConnectViewController alloc] init];
	controlPadManager = [[ControlPadManager alloc] init];
	
    
	NSString *documentsPath = [SNES4iOSAppDelegate applicationDocumentsDirectory];
    //	romDirectoryPath = [[documentsPath stringByAppendingPathComponent:@"ROMs/SNES/"] retain];
	self.romDirectoryPath = [documentsPath copy];
	self.saveDirectoryPath = [romDirectoryPath stringByAppendingPathComponent:@"saves"];
	self.snapshotDirectoryPath = [saveDirectoryPath stringByAppendingPathComponent:@"snapshots"];
    self.sramDirectoryPath = [self.romDirectoryPath stringByAppendingPathComponent:@"sram"];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager createDirectoryAtPath:saveDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:snapshotDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:self.sramDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    //Apple says its better to attempt to create the directories and accept an error than to manually check if they exist.
    
	// Make the main emulator view controller
	emulationViewController = [[EmulationViewController alloc] init];
	emulationViewController.view.hidden = YES;
	
	// Make the web browser view controller
	webViewController = [[WebBrowserViewController alloc] initWithNibName:@"WebBrowserViewController" bundle:nil];
	
	// And put it in a navigation controller with back/forward buttons
	webNavController = [[UINavigationController alloc] initWithRootViewController:webViewController];
	webNavController.navigationBar.barStyle = UIBarStyleBlack;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.romSelectionViewController = [[RomSelectionViewController alloc] initWithNibName:@"RomSelectionViewController" bundle:[NSBundle mainBundle]];
        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:self.romSelectionViewController];
        
        self.snesControllerAppDelegate = [[SNESControllerAppDelegate alloc] init];
        
        masterNavigationController.toolbarHidden = NO;
        
        self.romSelectionViewController.title = @"ROMs";
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        UIBarButtonItem *controllerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Controller"] style:UIBarButtonItemStyleBordered target:self.romSelectionViewController action:@selector(loadSNESController)];
        self.romSelectionViewController.toolbarItems = [NSArray arrayWithObjects:flexibleSpace, controllerButton, nil];
        
        self.window.rootViewController = masterNavigationController;
    } else {
        self.window.rootViewController = self.splitViewController;
    }
    [self.window makeKeyAndVisible];
	
    
	// Add the split view controller's view to the window and display.
    //[window addSubview:splitViewController.view];
	
	// Add the emulation view in its hidden state.
    
    emulationViewController.view.hidden = NO;
	
    [window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}

- (void) showEmulator:(BOOL)showOrHide
{
	if (showOrHide) {
        self.splitViewController.view.hidden = YES;
        self.emulationViewController.view.hidden = NO;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self.window addSubview:self.emulationViewController.view];
        }
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	} else {
        UIViewController *presentedViewController = AppDelegate().snesControllerViewController;
        if (ControllerAppDelegate().controllerType == SNESControllerTypeWireless) {
            presentedViewController = AppDelegate().emulationViewController;
        }
        UIViewController *parentViewController = [presentedViewController parentViewController];
        if ([presentedViewController respondsToSelector:@selector(presentingViewController)]) {
            parentViewController = [presentedViewController presentingViewController];//Fixes iOS 5 bug
        }
        [parentViewController dismissModalViewControllerAnimated:YES];
        
        self.emulationViewController.view.hidden = YES;
        if (self.emulationViewController.view.superview != nil) {
            [self.emulationViewController.view removeFromSuperview];
        }
        self.splitViewController.view.hidden = NO;
        
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	}
}

+ (NSString *) applicationDocumentsDirectory 
{    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

#pragma mark -
#pragma mark Memory management



@end

