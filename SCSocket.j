@import <Foundation/CPObject.j>
@import "Socket.IO/socket.io.js"

@implementation SCSocket : CPObject
{
    JSObject socket;
    id delegate;
}

- (id)initWithURL:(CPURL)aURL delegate:aDelegate
{
    self = [super init];
    if (self)
    {
        socket = new io.Socket([aURL host], {port:[aURL port], transports:['websocket', 'htmlfile', 'xhr-multipart', 'xhr-polling']});
        delegate = aDelegate;
        if ([delegate respondsToSelector:@selector(socketDidConnect:)])
            socket.on('connect', function() {[delegate socketDidConnect:self]; [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];});
        if ([delegate respondsToSelector:@selector(socketDidClose:)])
            socket.on('close', function() {[delegate socketDidClose:self]; [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];});
        if ([delegate respondsToSelector:@selector(socketDidDisconnect:)])
            socket.on('disconnect', function() {[delegate socketDidDisconnect:self];[[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];});
        if ([delegate respondsToSelector:@selector(socket:didReceiveMessage:)])
            socket.on('message', function(message) {[delegate socket:self didReceiveMessage:[message objectFromJSON]]; [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];});
    }
    return self;
}

- (void)connect
{
    socket.connect();
}

- (BOOL)isConnecting
{
    return socket.connecting;
}

- (void)close
{
    if (socket) 
    {
        socket._events = {};
        socket.disconnect();
    }
}

- (void)sendMessage:(JSObject)jsonData
{
    socket.send([CPString JSONFromObject:jsonData]);
}
@end
