//
//  iOSOpenGLPhysicsViewController.m
//  iOSOpenGLPhysics
//
//  Created by 9r0ximi7y on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "iOSOpenGLPhysicsViewController.h"
#import "EAGLView.h"
#import "AccelerometerFilter.h"


// Uniform index.
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

@interface iOSOpenGLPhysicsViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end



@implementation iOSOpenGLPhysicsViewController

@synthesize animating;
@synthesize context;
@synthesize displayLink;

- (void)awakeFromNib
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!aContext) {
        aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    if ([context API] == kEAGLRenderingAPIOpenGLES2)
        [self loadShaders];
    
    animating = FALSE;
    animationFrameInterval = 1;
    self.displayLink = nil;
    
    
    
    
    float updateFrequency = 20.0f;
    m_filter = [[LowpassFilter alloc] initWithSampleRate:updateFrequency
                                         cutoffFrequency:20.0];
    m_filter.adaptive = YES;
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / updateFrequency];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    
    
    
    btBroadphaseInterface* broadphase = new btDbvtBroadphase();
	btDefaultCollisionConfiguration* collisionConfiguration = new btDefaultCollisionConfiguration();
	btCollisionDispatcher* dispatcher = new btCollisionDispatcher(collisionConfiguration);
	btSequentialImpulseConstraintSolver* solver = new btSequentialImpulseConstraintSolver();
	dynamicsWorld = new btDiscreteDynamicsWorld(dispatcher,broadphase,solver,collisionConfiguration);
	dynamicsWorld->setGravity(btVector3(0,-9.8,0));

    
    
    btCollisionShape *groundShape = new btBoxShape(btVector3(15,0.1,15));
	btDefaultMotionState *groundMotionState = new btDefaultMotionState(btTransform(btQuaternion(0,0,0,1),btVector3(0,-5,0)));

    
	btRigidBody::btRigidBodyConstructionInfo groundRigidBodyCI(0,groundMotionState,groundShape,btVector3(0,0,0));
	groundRigidBodyCI.m_restitution = 0.0;
	btRigidBody* groundRigidBody = new btRigidBody(groundRigidBodyCI);
	dynamicsWorld->addRigidBody(groundRigidBody);
	
    btCollisionShape *cielingShape = new btBoxShape(btVector3(15,0.1,15));
	btDefaultMotionState *cielingMotionState = new btDefaultMotionState(btTransform(btQuaternion(0,0,0,1),btVector3(0,5,0)));
	btRigidBody::btRigidBodyConstructionInfo cielingRigidBodyCI(0,cielingMotionState,cielingShape,btVector3(0,0,0));
	cielingRigidBodyCI.m_restitution = 0.3;
	btRigidBody* cielingRigidBody = new btRigidBody(cielingRigidBodyCI);
	dynamicsWorld->addRigidBody(cielingRigidBody);
	
    btCollisionShape *leftWallShape = new btBoxShape(btVector3(0.1,15,15));
	btDefaultMotionState *leftWallMotionState = new btDefaultMotionState(btTransform(btQuaternion(0,0,0,1),btVector3(-5,0,0)));
	btRigidBody::btRigidBodyConstructionInfo leftWallRigidBodyCI(0,leftWallMotionState,leftWallShape,btVector3(0,0,0));
	leftWallRigidBodyCI.m_restitution = 0.8;
	btRigidBody* leftWallRigidBody = new btRigidBody(leftWallRigidBodyCI);
	dynamicsWorld->addRigidBody(leftWallRigidBody);
	
    btCollisionShape *rightWallShape = new btBoxShape(btVector3(0.1,15,15));
	btDefaultMotionState *rightWallMotionState = new btDefaultMotionState(btTransform(btQuaternion(0,0,0,1),btVector3(5,0,0)));
	btRigidBody::btRigidBodyConstructionInfo rightWallRigidBodyCI(0,rightWallMotionState,rightWallShape,btVector3(0,0,0));
	rightWallRigidBodyCI.m_restitution = 0.8;
	btRigidBody* rightWallRigidBody = new btRigidBody(rightWallRigidBodyCI);
	dynamicsWorld->addRigidBody(rightWallRigidBody);
	
    btTransform gTrans;
	groundRigidBody->getMotionState()->getWorldTransform(gTrans);
    
	
    //groundMesh.location = cc3v(gTrans.getOrigin().getX(),gTrans.getOrigin().getY() - 0.05,gTrans.getOrigin().getZ());
    
    
	// ---------------    
    // Shape 1
    btCollisionShape *fallShape = new btBoxShape(btVector3(0.5,0.5,0.5));//btSphereShape(1);
	btDefaultMotionState *fallMotionState = new btDefaultMotionState(btTransform(btQuaternion(0,0,0,1), btVector3(-2.5,0,0)));
	btScalar mass = 1;
	btVector3 fallInertia(0,0,0);
	fallShape->calculateLocalInertia(mass, fallInertia);
    btRigidBody::btRigidBodyConstructionInfo fallRigidBodyCI(mass,fallMotionState,fallShape,fallInertia);
	fallRigidBodyCI.m_restitution = 0.3;
	fallRigidBody = new btRigidBody(fallRigidBodyCI);
	fallRigidBody->setDamping(0.3,0.8);
    fallRigidBody->setLinearFactor(btVector3(1,1,0));
    fallRigidBody->setAngularFactor(btVector3(0,0,1));
	dynamicsWorld->addRigidBody(fallRigidBody);
	// ---------------
    // Shape 2
    btCollisionShape *fallShape2 = new btBoxShape(btVector3(0.5,0.5,0.5));//btSphereShape(1);
	btDefaultMotionState *fall2MotionState = new btDefaultMotionState(btTransform(btQuaternion(0,0,0,1), btVector3(2.5,0,0)));
	fallShape2->calculateLocalInertia(mass, fallInertia);
    btRigidBody::btRigidBodyConstructionInfo fallRigidBodyCI2(mass,fall2MotionState,fallShape2,fallInertia);
	fallRigidBodyCI2.m_restitution = 0.3;
	fallRigidBody2 = new btRigidBody(fallRigidBodyCI2);
	fallRigidBody2->setDamping(0.3,0.8);
    fallRigidBody2->setLinearFactor(btVector3(1,1,0));
    fallRigidBody2->setAngularFactor(btVector3(0,0,1));
	dynamicsWorld->addRigidBody(fallRigidBody2);
	// ---------------	
    
}


- (void) accelerometer: (UIAccelerometer*) accelerometer
         didAccelerate: (UIAcceleration*) acceleration
{
    [m_filter addAcceleration:acceleration];
    
    NSLog(@"accelerometer = (%f, %f)", m_filter.x, m_filter.y);
    
    static float gravity = 9.8;
    
    dynamicsWorld->setGravity(btVector3(m_filter.x * gravity, m_filter.y * gravity, 0.0));
}


- (void)dealloc
{
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating) {
        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(drawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}


- (void)updatePhysics
{
    dynamicsWorld->stepSimulation(1/60.f,10);
    btTransform trans;
    fallRigidBody->getMotionState()->getWorldTransform(trans);
    btVector3 fallRBPos = trans.getOrigin();
    if (fallRigidBody->getLinearVelocity().length() > -0.3 && fallRigidBody->getLinearVelocity().length() < 0.3 && !reset) {
        if(left) {
            fallRigidBody->applyImpulse(btVector3(-3,2,0), btVector3(fallRBPos.getX()-0.5, fallRBPos.getY()-0.5, fallRBPos.getZ()));
            left = false;
            reset = true;
        } else {
            fallRigidBody->applyImpulse(btVector3(3,2,0), btVector3(fallRBPos.getX()-0.5, fallRBPos.getY()-0.5, fallRBPos.getZ()));
            left = true;
            reset = true;
        }
        
        
    }
    
    objectAPosition = btVector3(trans.getOrigin().getX(), trans.getOrigin().getY(), trans.getOrigin().getZ());
    btQuaternion qRotation1 = trans.getRotation();
    objectAAngle = qRotation1.getAngle();
        
    
    
    btTransform trans2;
    fallRigidBody2->getMotionState()->getWorldTransform(trans2);
    fallRBPos = trans2.getOrigin();
    
    if (fallRigidBody2->getLinearVelocity().length() > -0.3 && fallRigidBody2->getLinearVelocity().length() < 0.3 && !reset) {
        if(left) {
            fallRigidBody2->applyImpulse(btVector3(-3,2,0), btVector3(fallRBPos.getX()-0.5, fallRBPos.getY()-0.5, fallRBPos.getZ()));
            fallRigidBody2->applyTorqueImpulse(btVector3(0.0,0.0,10.0));
            left = false;
            reset = true;
        } else {
            fallRigidBody2->applyImpulse(btVector3(3,2,0), btVector3(fallRBPos.getX()-0.5, fallRBPos.getY()-0.5, fallRBPos.getZ()));
            fallRigidBody2->applyTorqueImpulse(btVector3(0.0,0.0,-10.0));
            left = true;
            reset = true;
        }
        
        
    } else {
        if (steps >= 10) {
            reset = false;
            steps = 0;
        } else {
            steps += 1;
        }
        
    }
    
    objectBPosition = btVector3(trans2.getOrigin().getX(), trans2.getOrigin().getY(), trans2.getOrigin().getZ());
    btQuaternion qRotation2 = trans2.getRotation();
    objectBAngle = qRotation2.getAngle();

    //NSLog(@"ObjectA = (%f, %f)    rotation = %f", objectAPosition.getX(), objectAPosition.getY(), objectAAngle);
    //NSLog(@"ObjectB = (%f, %f)    rotation = %f", objectBPosition.getX(), objectBPosition.getY(), objectBAngle);    
}


- (void)drawFrame
{
    [(EAGLView *)self.view setFramebuffer];
    
    // Replace the implementation of this method to do your own custom drawing.
    static const GLfloat squareVertices[] = {
        -0.5f, -0.5f,
        0.5f, -0.5f,
        -0.5f,  0.5f,
        0.5f,  0.5f,
    };
    
    static const GLubyte squareColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
    
    [self updatePhysics];
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
  
    static float transY = 0.0;
    
    if ([context API] == kEAGLRenderingAPIOpenGLES2) {
        // Use shader program.
        glUseProgram(program);
        
        // Update uniform value.
        glUniform1f(uniforms[UNIFORM_TRANSLATE], (GLfloat)transY);
        
        // Update attribute values.
        glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
        glEnableVertexAttribArray(ATTRIB_VERTEX);
        glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, 1, 0, squareColors);
        glEnableVertexAttribArray(ATTRIB_COLOR);
        
        // Validate program before drawing. This is a good check, but only really necessary in a debug build.
        // DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
        if (![self validateProgram:program]) {
            NSLog(@"Failed to validate program: %d", program);
            return;
        }
#endif
    } else {
    }
     

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glScalef(0.2, 0.2, 1.0);
    

    glPushMatrix();
    
    glTranslatef(objectAPosition.getX(), objectAPosition.getY(), 0.0f);
    glRotatef(objectAAngle*180.0/3.14159, 0.0, 0.0, 1.0);
    
    
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    glEnableClientState(GL_COLOR_ARRAY);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    
    glPopMatrix();
    
    
    glTranslatef(objectBPosition.getX(), objectBPosition.getY(), 0.0f);
    glRotatef(objectBAngle*180.0/3.14159, 0.0, 0.0, 1.0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    
    [(EAGLView *)self.view presentFramebuffer];
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return FALSE;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return FALSE;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_COLOR, "color");
    
    // Link program.
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return FALSE;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_TRANSLATE] = glGetUniformLocation(program, "translate");
    
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return TRUE;
}

@end
