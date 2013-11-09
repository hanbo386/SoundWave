//
//  HeyaldaGLDrawNode.h
//  
//
//  Created by Jim Range on 2/13/12.
//  Copyright 2012 Heyalda Corporation. All rights reserved.
//
/*
 
 Copyright 2012 Heyalda Corporation. All rights reserved.
 
 You may use this source code in personal or commercial projects without attribution to the copyright 
 owner of this source code as long as no significant portion of this source code is distributed with
 the work product. 
 
 All digital image media included in this sample project that were created by Heyalda Corporation 
 must not be redistributed in any way; no license to do so is granted.
 
 For example, this source code can be used to create a compiled application that can be sold in the 
 Apple App Store under the condition that none of the digital images created by Heyalda Corporation 
 are included in the application and the application must not include the source code text.
 
 If you publish, distribute, or otherwise make available a significant portion of this source code, 
 you must first receive permission from Heyalda Corporation to do so.
 
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
 NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
 NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

/*
 

 About HeyaldaGLDrawNode
 ----------------------- 
 HeyaldaGLDrawNode is a subclass of CCNode that can be added into a Cocos2d game just like any other node.
 
 To use this class:
 
 1) Create an instance of the class.
 
 2) Define the custom geometry and color for each vertex point using the addToDynamicVerts2D:withColor: and  
    addToDynamicVerts3D:(HeyaldaPoint)vert withColor: selectors.
 
 3) Set the glDrawMode depending on how you defined your geometry.
 
 4) Add the instance of HeyaldaGLDrawNode to your Cococs2d scene graph so it will be drawn.
 
 5) Call the setReadyToDrawDynamicVerts: selector and pass it yes to enable the custom drawing in this class.

 
 Because each instance of this class adds a draw call to the game, it is best to attempt to add multiple custom
 drawings into a single class. There are several techniques to do batch geometry into one draw call. For example, 
 if you wanted to draw to separate objects on the screen, this can be done by using techniques such as drawing the 
 same point twice at the end of one one triangle strip object and at the start of the next triangle strip object 
 to make the jump invisible. 
 
 For performance reasons, this class should be updated to use frame buffer objects, frame buffer arrays, vertex buffer objects,
 and vertex buffer arrays in a way that the CPU can pass more of the drawing work to the GPU.
 
 It is also possible to improve performance of this class by creating a C structure like the tVertPlusColor4B shown below so that
 the data being passed to OpenGL ES 2.0 is in the format that OpenGL needs it to be in. At the time of this writeup I need 
 to do further research to figure out what the correct C strucure components should be to match what OpenGL needs. Also need to 
 research how to enable using buffer arrays and buffer objects.
 
 
*/

#import "cocos2d.h"

typedef struct {
	GLfloat x;
	GLfloat y;
	GLfloat z;
} HeyaldaPoint;

typedef enum tDrawMode {
    kDrawTriangleStrip,
    kDrawTriangleFan,
    kDrawPoints,
    kDrawLines,
    
}tDrawMode;

@interface HeyaldaGLDrawNode : CCNode {

    BOOL                 shouldDrawDynamicVerts;
    
    // Dynamic Verts 
    HeyaldaPoint*        dynamicVerts;

    // Color of each vert
    ccColor4B*           dynamicVertColors;
    
    NSInteger           dynamicVertCount;
    NSInteger           dynamicVertIndex;
        
    tDrawMode               glDrawMode;
       
}

@property (nonatomic, assign)     tDrawMode               glDrawMode;
@property (nonatomic, assign)     HeyaldaPoint*           dynamicVerts;
@property (nonatomic, assign)     ccColor4B*              dynamicVertColors;
@property (nonatomic, assign)     NSInteger               dynamicVertCount;

+(HeyaldaPoint) hp3x:(float)x y:(float)y z:(float)z;

-(void) addToDynamicVerts2D:(CGPoint)vert withColor:(ccColor4B)color;

-(void) addToDynamicVerts3D:(HeyaldaPoint)vert withColor:(ccColor4B)color;

-(void) setReadyToDrawDynamicVerts:(BOOL)isReadyToDraw;

-(void) clearDynamicDrawArray;


@end
