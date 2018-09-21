
/*
 ---------------------------------------------------------------------------
 Assimp to Scene Kit Library (AssimpKit)
 ---------------------------------------------------------------------------
 Copyright (c) 2016, Deepak Surti, Ison Apps, AssimpKit team
 All rights reserved.
 Redistribution and use of this software in source and binary forms,
 with or without modification, are permitted provided that the following
 conditions are met:
 * Redistributions of source code must retain the above
 copyright notice, this list of conditions and the
 following disclaimer.
 * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the
 following disclaimer in the documentation and/or other
 materials provided with the distribution.
 * Neither the name of the AssimpKit team, nor the names of its
 contributors may be used to endorse or promote products
 derived from this software without specific prior
 written permission of the AssimpKit team.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ---------------------------------------------------------------------------
 */

#import "SCNAssimpAnimSettings.h"

/**
 SCNAssimpAnimSettings provides support for CAMediaTiming protocol, animation
 attributes and animating scenekit content.
 */
@implementation SCNAssimpAnimSettings


/**
 Makes an animation settings object with the default values.

 @return A settings object with the default values.
 */
-(id)init
{
    self = [super init];
    if (self) {
        self.beginTime = 0;
        self.timeOffset = 0;
        self.repeatCount = 0;
        self.repeatDuration = 0;
        self.duration = 0;
        self.speed = 1.0;
        self.autoreverses = NO;
        self.fillMode = kCAFillModeRemoved;
        
        self.removedOnCompletion = YES;
        self.timingFunction = nil;
        
        self.usesSceneTimeBase = NO;
        
        self.fadeInDuration = 0;
        self.fadeOutDuration = 0;
    }
    return self;
}

@end
