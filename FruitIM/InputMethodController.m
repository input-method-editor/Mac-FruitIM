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

@interface InputMethodController ()

- (void) _updateComposition:(id)client;

@end

@implementation InputMethodController
{
    ComposingBuffer *_buffer;
    IMKCandidates *_candidates;
    id _candidateClient;
}

- (id) initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)client
{
    Debug(@"initWithServer:%@ delegate:%@ client:%@", server, delegate, client);
    if (self = [super initWithServer:server delegate:delegate client:client])
    {
        DataTable *table = [DataTable getInstanceByName:@"bpmf"];
        _buffer = [[ComposingBuffer alloc] initWithDataTable:table];
        _candidates = [[IMKCandidates alloc] initWithServer:server
                                                  panelType:kIMKSingleRowSteppingCandidatePanel];

        Debug(@"Initialize success!");
    }

    return self;
}

- (void) dealloc
{
    Debug(@"Call dealloc");
    [_buffer release];
    [super dealloc];
}

- (void) candidateSelected:(NSAttributedString *)candidateString
{
    Debug(@"Call candidateSelected:%@", candidateString);
    [_buffer updateComposedStringWithString:candidateString.string];
    [self _updateComposition:_candidateClient];
    _candidateClient = nil;
}

#pragma mark IMKStateSetting Protocol

- (void) activateServer:(id)client
{
    Debug(@"Call activateServer:%@", client);
}

- (void) deactivateServer:(id)client
{
    Debug(@"Call deactivateServer:%@", client);
    [self commitComposition:client];
}

#pragma mark IMKServerInput Protocol

- (BOOL) inputText:(NSString *)text key:(NSInteger)keyCode modifiers:(NSUInteger)flags client:(id)client
{
    Debug(@"Call inputText:%@ key:%ld modifiers:%lx client:%@", text, keyCode, flags, client);
    if ([_buffer inputText:text])
        [self _updateComposition:client];

    return YES;
}

- (void) commitComposition:(id)client
{
    Debug(@"Call commitComposition:%@", client);
    [client insertText:_buffer.composedString
      replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [_buffer clear];

    [self _updateComposition:client];
}

- (NSArray *) candidates:(id)client
{
    Debug(@"Call candidates:%@", client);
    _candidateClient = client;
    return _buffer.candidates;
}

#pragma mark Private Methods

- (void) _updateComposition:(id)client
{
    NSString *composedString = _buffer.composedString;
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName,
                           [NSNumber numberWithInt:0], NSMarkedClauseSegmentAttributeName, nil];

    NSMutableAttributedString *attrString = [[[NSMutableAttributedString alloc]
                                              initWithString:composedString attributes:attrs] autorelease];

    [client setMarkedText:attrString
           selectionRange:NSMakeRange(_buffer.cursorPosition, 0)
         replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

@end
