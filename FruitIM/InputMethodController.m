//
//  InputMethodController.m
//
//  Copyright (c) 2012, Chi-En Wu All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  * Neither the name of the organization nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "InputMethodController.h"

#if DEBUG
    #define Debug NSLog
#else
    #define Debug(...)
#endif

@implementation InputMethodController

- (id) initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)client
{
    Debug(@"initWithServer:%@ delegate:%@ client:%@", server, delegate, client);
    if (self = [super initWithServer:server delegate:delegate client:client])
    {
        Debug(@"Initialize success!");
    }

    return self;
}

#pragma mark IMKStateSetting Protocol

- (void) activateServer:(id)client
{
    Debug(@"Call activateServer:%@", client);
}

- (void) deactivateServer:(id)client
{
    Debug(@"Call deactivateServer:%@", client);
}

#pragma mark IMKServerInput Protocol

- (BOOL) inputText:(NSString *)text key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)client
{
    Debug(@"Call inputText:%@ key:%ld modifiers:%lx client:%@", text, keyCode, flags, client);
    return NO;
}

- (void) commitComposition:(id)client
{
    Debug(@"Call commitComposition:%@", client);
}

@end
