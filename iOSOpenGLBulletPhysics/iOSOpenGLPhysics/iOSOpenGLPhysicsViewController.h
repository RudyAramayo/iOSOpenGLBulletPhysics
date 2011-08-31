//
//  iOSOpenGLPhysicsViewController.h
//  iOSOpenGLPhysics
//
//  Created by 9r0ximi7y on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#include "btBulletDynamicsCommon.h"

@class AccelerometerFilter;


@interface iOSOpenGLPhysicsViewController : UIViewController <UIAccelerometerDelegate>{
    EAGLContext *context;
    GLuint program;
    
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;

    btDiscreteDynamicsWorld *dynamicsWorld;
	btRigidBody *fallRigidBody;
	btRigidBody *fallRigidBody2;

    btVector3 objectAPosition;
    btVector3 objectBPosition;

    btScalar objectAAngle;
    btScalar objectBAngle;
    
    bool reset;
	bool left;
	int steps;
    
    AccelerometerFilter* m_filter;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)updatePhysics;

@end
