//
//  pingDNS.m
//  network_app
//
//  Created by Luke Hyatt on 7/12/25.
//


//DNS PING NEVER IMPLEMENTED, WE'LL SAVE THAT FOR V2
#import <Foundation/Foundation.h>
#include <resolv.h>
#include <arpa/inet.h>

static NSArray<NSString *> *currentDNSServers(void) {
    if (res_9_init() != 0) return @[];

    NSMutableArray *addrs = [NSMutableArray array];
    for (int i = 0; i < _res.nscount; i++) {
        char buf[INET6_ADDRSTRLEN];
        const struct sockaddr_in *sa = &_res.nsaddr_list[i];
        if (inet_ntop(AF_INET, &sa->sin_addr, buf, sizeof(buf)))
            [addrs addObject:[NSString stringWithUTF8String:buf]];
    }
    res_9_ndestroy(&_res);
    return addrs;
}
