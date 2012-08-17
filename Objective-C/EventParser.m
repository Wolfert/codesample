//
//  EventParser.m
//  iStager
//
//  Created by Wolfert de Kraker on 21-02-12.


#import "EventParser.h"


@implementation EventParser

- (id) initWithMappings:(NSDictionary*)mappings {
	if ((self = [super init])) {
		_mappings = mappings;
		_df = [[NSDateFormatter alloc]init];
		[_df setDateFormat:dateFormat];
	}
	return self;
}

- (Event*) parseEvent:(CXMLElement*)element {	
	_event = [[Event alloc] init];
	_element = element;
	
	
	
	// title
	NSArray * nodes = [_element nodesForXPath:@"atom:title" namespaceMappings:_mappings error:nil];
	_event.title = [[nodes objectAtIndex:0] stringValue];
	
	// subtitle
	nodes = [_element nodesForXPath:@"pro:subtitle" namespaceMappings:_mappings error:nil];
	_event.subtitle =  [[nodes objectAtIndex:0] stringValue];
	
	// primary location
	nodes = [_element nodesForXPath:@"gd:where/gd:entryLink/atom:entry/gd:structuredPostalAddress[@primary='true']" namespaceMappings:_mappings error:nil];
	[_event setLocation:[self parseLocation:[nodes objectAtIndex:0]]];
	
	
	// attached images
	nodes = [_element nodesForXPath:@"atom:link[@rel='image']" namespaceMappings:_mappings error:nil];
	for (CXMLNode * node in nodes){
		[_event.links addObject:[[[((CXMLElement*)node) attributes] objectAtIndex:1] stringValue]];
	}
	
	// content
	nodes = [_element nodesForXPath:@"atom:content" namespaceMappings:_mappings error:nil];
	Content * c = [[Content alloc] init];
	c.type = [[((CXMLElement*)[nodes objectAtIndex:0]) attributes] objectAtIndex:0];
	c.content = [[nodes objectAtIndex:0] stringValue];
	_event.content = c;
	
	
	nodes = nil;
	return _event;
}

- (Location*) parseLocation:(CXMLDocument*) addres {
	Location * l = [[[Location alloc] init] autorelease];
	l.city		=	[[[addres nodesForXPath:@"gd:city" namespaceMappings:_mappings error:nil] objectAtIndex:0] stringValue];
	l.street	=	[[[addres nodesForXPath:@"gd:street" namespaceMappings:_mappings error:nil] objectAtIndex:0] stringValue];
	l.postcode	=	[[[addres nodesForXPath:@"gd:postcode" namespaceMappings:_mappings error:nil] objectAtIndex:0] stringValue];
	l.formattedAddress = [[[addres nodesForXPath:@"gd:formattedAddress" namespaceMappings:_mappings error:nil] objectAtIndex:0] stringValue];
	
	return l;
}

- (void) dealloc {
	[super dealloc];
	[_df release];
}

@end
