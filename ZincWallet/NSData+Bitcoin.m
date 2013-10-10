//
//  NSData+Bitcoin.m
//  ZincWallet
//
//  Created by Aaron Voisine on 10/9/13.
//  Copyright (c) 2013 Aaron Voisine. All rights reserved.
//

#import "NSData+Bitcoin.h"

#define VAR_INT16_HEADER 0xfd
#define VAR_INT32_HEADER 0xfe
#define VAR_INT64_HEADER 0xff

@implementation NSData (Bitcoin)

- (uint8_t)UInt8AtOffset:(NSUInteger)offset
{
    return *((uint8_t *)self.bytes + offset);
}

- (uint16_t)UInt16AtOffset:(NSUInteger)offset
{
    return CFSwapInt16LittleToHost(*(uint16_t *)((uint8_t *)self.bytes + offset));
}

- (uint32_t)UInt32AtOffset:(NSUInteger)offset
{
    return CFSwapInt32LittleToHost(*(uint32_t *)((uint8_t *)self.bytes + offset));
}

- (uint64_t)UInt64AtOffset:(NSUInteger)offset
{
    return CFSwapInt64LittleToHost(*(uint64_t *)((uint8_t *)self.bytes + offset));
}

- (uint64_t)varIntAtOffset:(NSUInteger)offset length:(NSUInteger *)length
{
    uint8_t h = [self UInt8AtOffset:offset];

    switch (h) {
        case VAR_INT16_HEADER:
            if (length) *length = sizeof(h) + sizeof(uint16_t);
            return [self UInt16AtOffset:offset + 1];
            
        case VAR_INT32_HEADER:
            if (length) *length = sizeof(h) + sizeof(uint32_t);
            return [self UInt32AtOffset:offset + 1];
            
        case VAR_INT64_HEADER:
            if (length) *length = sizeof(h) + sizeof(uint64_t);
            return [self UInt64AtOffset:offset + 1];
            
        default:
            if (length) *length = sizeof(h);
            return h;
    }
}

- (NSString *)stringAtOffset:(NSUInteger)offset length:(NSUInteger *)length
{
    NSUInteger ll, l = [self varIntAtOffset:offset length:&ll];
    
    if (length) *length = ll + l;
    return [[NSString alloc] initWithBytes:(char *)self.bytes + offset + ll length:l encoding:NSUTF8StringEncoding];
}

@end
