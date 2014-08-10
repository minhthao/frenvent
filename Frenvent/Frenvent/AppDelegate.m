//
//  AppDelegate.m
//  Frenvent
//
//  Created by minh thao nguyen on 6/23/14.
//  Copyright (c) 2014 Frenvent. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Constants.h"
#import "FriendEventsRequest.h"
#import "UpdateManager.h"
#import "Reachability.h"
#import <Bolts/Bolts.h>
#import "EventDetailViewController.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize updateManager = _updateManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FBLoginView class];
    [FBSettings enablePlatformCompatibility:true];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:300.0]; //call update every 5 mins, change this before release
    
    [[UITabBar appearance] setTintColor:[UIColor blueColor]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
    [shadow setShadowOffset: CGSizeMake(0.0f, 1.0f)];
    [[UINavigationBar appearance] setTitleTextAttributes:
            @{ NSForegroundColorAttributeName:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0],
               NSShadowAttributeName:shadow}];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:LOGIN_DATA_INITIALIZED]) {
        UILocalNotification *localNotif =
        [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localNotif) {
            //launch from the notification, so go to notification view
            UIStoryboard *storyboard = self.window.rootViewController.storyboard;
            UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"notificationViewController"];
            self.window.rootViewController = rootViewController;
            [self.window makeKeyAndVisible];
        } else {
            //launch from click the icon
            UIStoryboard *storyboard = self.window.rootViewController.storyboard;
            UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainView"];
            self.window.rootViewController = rootViewController;
            [self.window makeKeyAndVisible];
        }
    }
    
    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    //will never get call in the background. only call when your app is running in the foreground
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:LOGIN_DATA_INITIALIZED]) {
        Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
        if ([internetReachable isReachable]) {
            [[self updateManager] doUpdateWithCompletionHandler:completionHandler];
        } else completionHandler(UIBackgroundFetchResultFailed);
    } else completionHandler(UIBackgroundFetchResultNoData); //user did not login
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - update manager
- (UpdateManager *)updateManager {
    if (_updateManager == nil) _updateManager = [[UpdateManager alloc] init];
    return _updateManager;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Frenvent" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Frenvent.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



// you need to override application:openURL:sourceApplication:annotation:
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
         // Parse the incoming URL
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:LOGIN_DATA_INITIALIZED]) {
             BFURL *parsedUrl = [BFURL URLWithURL:url];
             if ([parsedUrl targetURL]) {
                 NSString *targetURLString = [[parsedUrl targetURL] absoluteString];
                 NSString *url = [[targetURLString componentsSeparatedByString:@"&"] objectAtIndex:0];
                 NSString *eid = [[url componentsSeparatedByString:@"="] objectAtIndex:1];
                 
                 Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
                 if ([internetReachable isReachable]) {
                     UIStoryboard *storyboard = self.window.rootViewController.storyboard;
                     EventDetailViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"eventDetailViewController"];
                     rootViewController.eid = eid;
                     rootViewController.isModal = true;
                     UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
                     
                     [self.window.rootViewController presentViewController:navigationController animated:true completion:NULL];
                 } else {
                     UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Connections"
                                                                       message:@"Connect to internet and try again."
                                                                      delegate:nil
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                     [message show];
                 }
             }
        }
     }];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

@end
