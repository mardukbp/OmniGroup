// Copyright 1997-2005 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.
//
// $Id$

#import <OmniFoundation/OFStringScanner.h>

@class OWDataStreamCharacterCursor;

@interface OWDataStreamScanner : OFCharacterScanner
{
    OWDataStreamCharacterCursor *streamCursor;
    
    unichar *buffer;
    unsigned int bufferLength, bufferSize;	/* buffer length and size, in unichars */
    unsigned int bufferOffset;			/* buffer start offset, in characters */
    unsigned int minimumReadBufferLength;       /* how many characters to read at a time */
}

- initWithCursor:(OWDataStreamCharacterCursor *)aStreamCursor bufferLength:(unsigned int)aBufferLength;
- initWithCursor:(OWDataStreamCharacterCursor *)aStreamCursor;

- (OWDataStreamCharacterCursor *)dataStreamCursor;
- (void)discardReadahead;  // Discards buffered characters

@end