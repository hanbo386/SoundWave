//
//  HeyaldaGLDrawLayer.mm
//  cityslickerrally
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


#import "HeyaldaGLDrawNode.h"



#define kVertCreationBlockSize 100


@implementation HeyaldaGLDrawNode

@synthesize glDrawMode;

@synthesize dynamicVerts;
@synthesize dynamicVertColors;
@synthesize dynamicVertCount;

-(id) init {
    self = [super init];
    if (self) {

        
        
        dynamicVertCount = 0;
        dynamicVertIndex = 0;
        
        dynamicVerts = nil;

        // Must define what shader program OpenGL ES 2.0 should use.
        // The instance variable shaderProgram exists in the CCNode class in Cocos2d 2.0.
        
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
        
        glDrawMode = kDrawTriangleStrip; // Default draw mode for this class.
        
    }
    return self;
}



-(void) dealloc {
    

    [self clearDynamicDrawArray];
    
    [super dealloc];
}


-(void) setReadyToDrawDynamicVerts:(BOOL)shouldDraw
{
    shouldDrawDynamicVerts = shouldDraw; 
}

// Called to release the memory of the dynamic verts and reset this class to its default state.
-(void) clearDynamicDrawArray {
    shouldDrawDynamicVerts = NO;

    
    if (dynamicVerts != nil) {
        free(dynamicVerts);
        free(dynamicVertColors);
        dynamicVerts = nil;
        dynamicVertColors = nil;
        dynamicVertCount = 0;
        dynamicVertIndex = 0;
    }
    

}


// Adds a vertex point with the zVertex p.z set to zero and assignes its color.
-(void) addToDynamicVerts2D:(CGPoint)vert withColor:(ccColor4B)_color {

    HeyaldaPoint p;
    p.x = vert.x;
    p.y = vert.y;
    p.z = 0;
    [self addToDynamicVerts3D:p withColor:_color];
    
}


// Adds a 3D vertex point to the dynamicVerts array and the color of that vert to the dynaicVertColors array.
-(void) addToDynamicVerts3D:(HeyaldaPoint)vert withColor:(ccColor4B)vertexColor
{
    
    // Create vertex blocks in sizes of 100 so that memory allocation only needs to 
    // be done 1/kVertCreationBlockSize times as often as the verts are added.
    
    NSInteger remainder = dynamicVertCount % kVertCreationBlockSize;
    NSInteger vertBlockCount = dynamicVertCount / kVertCreationBlockSize + 1;
    if (remainder == 0)
    {
        dynamicVerts = (HeyaldaPoint*)realloc(dynamicVerts, sizeof(HeyaldaPoint) * kVertCreationBlockSize * vertBlockCount);
        dynamicVertColors = (ccColor4B*)realloc(dynamicVertColors, sizeof(ccColor4B) * kVertCreationBlockSize * vertBlockCount);
    }
    
    // Increment so that the index always points to what will be the next added vert/color pair.
    dynamicVertColors[dynamicVertIndex] = vertexColor;
    dynamicVerts[dynamicVertIndex++] = vert;
    
    //  NSLog(@"created vert:(%.2f,%.2f,%.2f) withColor:r:%d,g:%d,b:%d,a:%d", vert.x, vert.y, vert.z, 
    //  vertexColor.r, vertexColor.b, vertexColor.b, vertexColor.a);
    
    dynamicVertCount = dynamicVertIndex;
}




-(void) draw
{
    // Only draw if this class has the verticies and colors to be drawn setup and ready to be drawn.
    if (shouldDrawDynamicVerts == YES)
    {

        ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );

        // Tell OpenGL ES 2.0 to use the shader program assigned in the init of this node.
        [self.shaderProgram use];
        [self.shaderProgram setUniformForModelViewProjectionMatrix];
        
        // Pass the verticies to draw to OpenGL
        glEnableVertexAttribArray(kCCVertexAttribFlag_Position);
        glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, dynamicVerts);


        // Pass the colors of the vertices to draw to OpenGL
        glEnableVertexAttribArray(kCCVertexAttribFlag_Color);
        glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, dynamicVertColors);	
        
        // Choose which draw mode to use.
        switch (glDrawMode) {
            case kDrawTriangleStrip:
                glDrawArrays(GL_TRIANGLE_STRIP, 0, dynamicVertCount);	                
                break;
                
            case kDrawLines:
                glDrawArrays(GL_LINE_STRIP, 0, dynamicVertCount);	                
                break;
                
            case kDrawPoints:
                glDrawArrays(GL_POINTS, 0, dynamicVertCount);	                
                break;
                
            case kDrawTriangleFan:
                glDrawArrays(GL_TRIANGLE_FAN, 0, dynamicVertCount);	                
                break;
                
            default:
                glDrawArrays(GL_TRIANGLE_STRIP, 0, dynamicVertCount);	                
                break;
        }
        
     }


}

// Static method to generate a 3d vertex.
+(HeyaldaPoint) hp3x:(float)x y:(float)y z:(float)z
{
    HeyaldaPoint p;
    p.x = x;
    p.y = y;
    p.z = z;
    return p;
}


@end



