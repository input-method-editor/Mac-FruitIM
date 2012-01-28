//
//  CINParser.m
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

#import "CINParser.h"

static NSString *_EXPRESSION_SEPARATOR = @"\n";
static NSString *_TOKEN_SEPARATOR = @" ";

static unichar _FORMAT_START = '%';
static unichar _FORMAT_COMMENT = '#';
static NSString *_FORMAT_HEAD = @"%gen_inp";
static NSString *_FORMAT_BEGIN = @"begin";
static NSString *_FORMAT_END = @"end";

@interface CINParser ()

- (BOOL) _parseHead:(NSEnumerator *)enumerator storeIn:(NSMutableDictionary *)dict;
- (BOOL) _parseBody:(NSEnumerator *)enumerator storeIn:(NSMutableDictionary *)dict;
- (BOOL) _parseList:(NSEnumerator *)enumerator name:(NSString *)name
           storeIn:(NSMutableDictionary *)dict;
- (NSString *) _nextLine:(NSEnumerator *)enumerator;
- (NSString *) _nextNonCommentLine:(NSEnumerator *)enumerator;

@end

@implementation CINParser

- (NSDictionary *) parseContent:(NSString *)content
{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];

    NSArray *lines = [content componentsSeparatedByString:_EXPRESSION_SEPARATOR];
    NSEnumerator *enumerator = lines.objectEnumerator;
    if (![self _parseHead:enumerator storeIn:dict] ||
        ![self _parseBody:enumerator storeIn:dict])
        return nil;

    return dict;
}

- (NSDictionary *) parseContentOfFile:(NSString *)path encoding:(NSStringEncoding)encoding error:(NSError **)error
{
    NSString *content = [NSString stringWithContentsOfFile:path encoding:encoding error:error];
    return [self parseContent:content];
}

#pragma mark Private Methods

- (BOOL) _parseHead:(NSEnumerator *)enumerator storeIn:(NSMutableDictionary *)dict
{
    NSString *line = [self _nextNonCommentLine:enumerator];
    return [line isEqualToString:_FORMAT_HEAD];
}

- (BOOL) _parseBody:(NSEnumerator *)enumerator storeIn:(NSMutableDictionary *)dict
{
    NSString *line;
    while ((line = [self _nextNonCommentLine:enumerator]))
    {
        if ([line characterAtIndex:0] != _FORMAT_START)
            return NO;

        NSUInteger index = [line rangeOfString:_TOKEN_SEPARATOR].location;
        if (index == NSNotFound)
            return NO;

        NSString *key = [line substringWithRange:NSMakeRange(1, index - 1)];
        NSString *value = [line substringFromIndex:index + 2];
        if (![value isEqualToString:_FORMAT_BEGIN])
            [dict setValue:value forKey:key];
        else if (![self _parseList:enumerator name:key storeIn:dict])
            return NO;
    }

    return YES;
}

- (BOOL) _parseList:(NSEnumerator *)enumerator name:(NSString *)name
            storeIn:(NSMutableDictionary *)dict
{
    NSMutableDictionary *valueDict = [[[NSMutableDictionary alloc] init] autorelease];

    NSString *line;
    while ([(line = [self _nextLine:enumerator]) characterAtIndex:0] != _FORMAT_START)
    {
        NSUInteger index = [line rangeOfString:_TOKEN_SEPARATOR].location;
        if (index == NSNotFound)
            return NO;

        NSString *key = [line substringToIndex:index];
        NSString *value = [[line substringFromIndex:index + 1] stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];

        NSMutableArray *valueList = [valueDict valueForKey:key];
        if (!valueList)
        {
            valueList = [[[NSMutableArray alloc] init] autorelease];
            [valueDict setValue:valueList forKey:key];
        }

        [valueList addObject:value];
    }

    [dict setValue:valueDict forKey:name];

    NSUInteger index = [line rangeOfString:_TOKEN_SEPARATOR].location;
    if (index == NSNotFound)
        return NO;

    NSString *key = [line substringWithRange:NSMakeRange(1, index - 1)];
    NSString *value = [line substringFromIndex:index + 2];
    return [key isEqualToString:name] && [value isEqualToString:_FORMAT_END];
}

- (NSString *) _nextLine:(NSEnumerator *)enumerator
{
    NSString *line;
    do
    {
        line = enumerator.nextObject;
    } while (line != nil && line.length == 0);

    return line;
}

- (NSString *) _nextNonCommentLine:(NSEnumerator *)enumerator;
{
    NSString *line;
    do
    {
        line = [self _nextLine:enumerator];
    } while (line != nil && [line characterAtIndex:0] == _FORMAT_COMMENT);

    return line;
}

@end
