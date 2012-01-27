//
//  ComposingBuffer.m
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

#import "ComposingBuffer.h"

@implementation ComposingBuffer
{
    DataTable *_dataTable;
    BopomofoReadingBuffer *_readingBuffer;
    NSMutableArray *_composingBuffer;
    NSMutableString *_composedString;
    NSUInteger _cursorPosition;
}

- (id) initWithDataTable:(DataTable *)table
{
    if (self = [super init])
    {
        _dataTable = [table retain];

        _composingBuffer = [[NSMutableArray alloc] init];
        _readingBuffer = [[BopomofoReadingBuffer alloc] init];
        _composedString = [[NSMutableString alloc] init];
    }

    return self;
}

- (void) dealloc
{
    [_composedString release];
    [_readingBuffer release];
    [_composingBuffer release];
    [_dataTable release];
}

- (BOOL) inputText:(NSString *)text
{
    BOOL isWhitespace = [text isEqualTo:@" "];
    if (!isWhitespace)
        [_readingBuffer insertSymbol:text];

    NSString *syllable = _readingBuffer.string;
    if (isWhitespace || [_dataTable endKeyContainsText:text])
    {
        NSArray *candidates = [_dataTable candidatesForText:syllable];
        if (!candidates)
            return NO;

        [_composingBuffer insertObject:syllable atIndex:_cursorPosition];
        [_composedString insertString:[candidates objectAtIndex:0] atIndex:_cursorPosition++];
        [_readingBuffer clear];
    }

    return YES;
}

- (BOOL) moveCursorBackward
{
    if (!_readingBuffer.isEmpty || _cursorPosition == 0)
        return NO;

    _cursorPosition--;
    return YES;
}

- (BOOL) moveCursorForward
{
    if (!_readingBuffer.isEmpty || _cursorPosition == _composingBuffer.count)
        return NO;

    _cursorPosition++;
    return YES;
}

- (BOOL) deleteBackward
{
    if ([_readingBuffer erease])
        return YES;

    if (_cursorPosition == 0)
        return NO;

    [_composingBuffer removeObjectAtIndex:--_cursorPosition];
    [_composedString deleteCharactersInRange:NSMakeRange(_cursorPosition, 1)];
    return YES;
}

- (BOOL) deleteForward
{
    if (!_readingBuffer.isEmpty || _cursorPosition == _composingBuffer.count)
        return NO;

    [_composingBuffer removeObjectAtIndex:_cursorPosition];
    [_composedString deleteCharactersInRange:NSMakeRange(_cursorPosition, 1)];
    return YES;
}

- (void) clear
{
    [_readingBuffer clear];
    [_composingBuffer removeAllObjects];
    [_composedString setString:@""];
    _cursorPosition = 0;
}

- (BOOL) isEmpty
{
    return _readingBuffer.isEmpty && _composingBuffer.count == 0;
}

- (NSArray *) candidates
{
    NSUInteger index = _cursorPosition > 0 ? _cursorPosition - 1 : 0;
    return [_dataTable candidatesForText:[_composingBuffer objectAtIndex:index]];
}

- (void) updateComposedStringWithString:(NSString *)string
{
    NSUInteger length = string.length;
    if (length > 1 && length > _cursorPosition)
        return;

    if (_cursorPosition == 0)
        _cursorPosition++;

    [_composedString replaceCharactersInRange:NSMakeRange(_cursorPosition - length, length)
                                   withString:string];
}

- (NSString *) originalString
{
    return [_composingBuffer componentsJoinedByString:@""];
}

- (NSString *) composedString
{
    NSString *composedStringBeforeCursor = [_composedString substringToIndex:_cursorPosition];
    NSString *composedStringAfterCursor = [_composedString substringFromIndex:_cursorPosition];
    NSMutableString *readingString = [[[NSMutableString alloc] init] autorelease];

    NSString *syllable = _readingBuffer.string;
    NSUInteger length = syllable.length;
    for (NSUInteger index = 0; index < length; index++)
    {
        NSString *key = [syllable substringWithRange:NSMakeRange(index, 1)];
        NSString *character = [_dataTable characterForText:key];
        [readingString appendString:character];
    }

    return [NSString stringWithFormat:@"%@%@%@",
            composedStringBeforeCursor, readingString, composedStringAfterCursor];

}

- (NSUInteger) cursorPosition
{
    return _cursorPosition + _readingBuffer.length;
}

@end
