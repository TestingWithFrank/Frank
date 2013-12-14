//
//  Operation.m
//  Frank
//
//  Created by phodgson on 6/27/10.
//  Copyright 2010 ThoughtWorks. See NOTICE file for details.
//

#import "Operation.h"


@implementation Operation

- (id) initFromJsonRepresentation:(NSDictionary *)operationDict {
	self = [super init];
	if (self != nil) {
		_selector =  NSSelectorFromString( [operationDict objectForKey:@"method_name"] );
		_arguments = [[operationDict objectForKey:@"arguments"] retain];
	}
	return self;
}

- (void) dealloc
{
	[_arguments release];
	[super dealloc];
}

- (NSString *) description {
	return NSStringFromSelector(_selector);
}

- (BOOL) appliesToObject:(id)target {
	return [target respondsToSelector:_selector];
}

- (void)castNumber:(NSNumber *)number toType:(const char*)objCType intoBuffer:(void *)buffer{
	// specific cases should be added here as needed
    
    if( !strcmp(objCType, @encode(char)) ) {
        *((char *)buffer) = [number charValue];
    }else if( !strcmp(objCType, @encode(unsigned char)) ) {
        *((unsigned char *)buffer) = [number unsignedCharValue];
    }else if( !strcmp(objCType, @encode(short)) ){
		*((short *)buffer) = [number shortValue];
	}else if( !strcmp(objCType, @encode(unsigned short)) ){
		*((unsigned short *)buffer) = [number unsignedShortValue];
	}else if( !strcmp(objCType, @encode(int)) ){
		*((int *)buffer) = [number intValue];
	}else if( !strcmp(objCType, @encode(unsigned int)) ){
		*((unsigned int *)buffer) = [number unsignedIntValue];
	}else if( !strcmp(objCType, @encode(long)) ){
		*((long *)buffer) = [number longValue];
	}else if( !strcmp(objCType, @encode(unsigned long)) ){
		*((unsigned long *)buffer) = [number unsignedLongValue];
	}else if( !strcmp(objCType, @encode(long long)) ){
		*((long long *)buffer) = [number longLongValue];
	}else if( !strcmp(objCType, @encode(unsigned long long)) ){
		*((unsigned long long *)buffer) = [number unsignedLongLongValue];
	}else if( !strcmp(objCType, @encode(double)) ){
		*((double *)buffer) = [number doubleValue];
	} else if ( !strcmp(objCType, @encode(float)) ){
		*((float *)buffer) = [number floatValue];
	} else {
		NSLog(@"Didn't know how to convert NSNumber to type %s", objCType); 
	}	
}

- (id) applyToObject:(id)target {
	NSMethodSignature *signature = [target methodSignatureForSelector:_selector];
	NSUInteger requiredNumberOfArguments = signature.numberOfArguments - 2; // Indices 0 and 1 indicate the hidden arguments self and _cmd, respectively
	if( requiredNumberOfArguments != [_arguments count] )
#if TARGET_OS_IPHONE
		[NSException raise:@"wrong number of arguments"
					format:@"%@ takes %i arguments, but %i were supplied", NSStringFromSelector(_selector), requiredNumberOfArguments, [_arguments count] ];
#else
        [NSException raise:@"wrong number of arguments"
                    format:@"%@ takes %lu arguments, but %lu were supplied", NSStringFromSelector(_selector), requiredNumberOfArguments, [_arguments count] ];
#endif
	
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setSelector:_selector];
	
	NSInteger index = 2; // Indices 0 and 1 indicate the hidden arguments self and _cmd, respectively
	for( id arg in _arguments ) {
		if( [arg isKindOfClass:[NSNumber class]] ){
            const char* argumentType = [signature getArgumentTypeAtIndex:index];
            
            if ( !strcmp(argumentType, @encode(id)) ) {
                [invocation setArgument:&arg atIndex:index];
            } else {
                char buffer[10];
                [self castNumber:arg toType:argumentType intoBuffer:buffer];
                [invocation setArgument:buffer atIndex:index];
            }
		} else {
			[invocation setArgument:&arg atIndex:index];
		}
		index++;
	}
		 
	[invocation invokeWithTarget:target];
	
	const char *returnType = signature.methodReturnType;
	
	id returnValue;
	if( !strcmp(returnType, @encode(void)) ) {
		returnValue = nil;
    }
	else if( !strcmp(returnType, @encode(id)) ) { // retval is an objective c object
		[invocation getReturnValue:&returnValue];
	} else {
		// handle primitive c types by wrapping them in an NSValue
		
		NSUInteger length = [signature methodReturnLength];
		void *buffer = (void *)malloc(length);
		[invocation getReturnValue:buffer];
		
		// for some reason using [NSValue valueWithBytes:returnType] is creating instances of NSConcreteValue rather than NSValue, so 
		//I'm fudging it here with case-by-case logic
		if( !strcmp(returnType, @encode(char)) ) {
			returnValue = [NSNumber numberWithChar:*((char*)buffer)];
		}else if( !strcmp(returnType, @encode(unsigned char)) ) {
			returnValue = [NSNumber numberWithUnsignedChar:*((unsigned char*)buffer)];
		}else if( !strcmp(returnType, @encode(short)) ) {
			returnValue = [NSNumber numberWithShort:*((short*)buffer)];
		}else if( !strcmp(returnType, @encode(unsigned short)) ) {
			returnValue = [NSNumber numberWithUnsignedShort:*((unsigned short*)buffer)];
		}else if( !strcmp(returnType, @encode(int)) ) {
			returnValue = [NSNumber numberWithInt:*((int*)buffer)];
		}else if( !strcmp(returnType, @encode(unsigned int)) ) {
			returnValue = [NSNumber numberWithUnsignedInt:*((unsigned int*)buffer)];
		}else if( !strcmp(returnType, @encode(long)) ) {
			returnValue = [NSNumber numberWithLong:*((long*)buffer)];
		}else if( !strcmp(returnType, @encode(unsigned long)) ) {
			returnValue = [NSNumber numberWithUnsignedLong:*((unsigned long*)buffer)];
		}else if( !strcmp(returnType, @encode(long long)) ) {
			returnValue = [NSNumber numberWithLongLong:*((long long*)buffer)];
		}else if( !strcmp(returnType, @encode(unsigned long long)) ) {
			returnValue = [NSNumber numberWithUnsignedLongLong:*((unsigned long long*)buffer)];
		}else if( !strcmp(returnType, @encode(float)) ) {
			returnValue = [NSNumber numberWithFloat:*((float*)buffer)];
		}else if( !strcmp(returnType, @encode(double)) ) {
			returnValue = [NSNumber numberWithDouble:*((double*)buffer)];
		} else {
			returnValue = [NSValue valueWithBytes:buffer objCType:returnType];
		}
        
        free(buffer);
	}
    
	return returnValue;	
}

@end
