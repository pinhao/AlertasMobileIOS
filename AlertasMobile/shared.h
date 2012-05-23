//
//  shared.h
//  AlertasMobile
//
//  Created by Pedro on 26/10/11.
//  Copyright (c) 2011 System Tech LDA. All rights reserved.
//

#ifndef AlertasMobile_shared_h
#define AlertasMobile_shared_h

#ifdef DEBUG
#define DLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog( s, ... ) 
#endif

#endif
