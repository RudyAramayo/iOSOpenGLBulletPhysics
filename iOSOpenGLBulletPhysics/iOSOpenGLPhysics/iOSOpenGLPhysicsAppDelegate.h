//
//  iOSOpenGLPhysicsAppDelegate.h
//  iOSOpenGLPhysics
//
//  Created by 9r0ximi7y on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "btBulletDynamicsCommon.h"

@class iOSOpenGLPhysicsViewController;

@interface iOSOpenGLPhysicsAppDelegate : NSObject <UIApplicationDelegate>
{
    btDiscreteDynamicsWorld *dynamicsWorld;
	btRigidBody *fallRigidBody;
	btRigidBody *fallRigidBody2;
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet iOSOpenGLPhysicsViewController *viewController;

@end
