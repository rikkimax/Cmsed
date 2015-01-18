module test.turlroute;
import cmsed.base.routing.defs;

void myurlroute(IOTransport transport) {
    transport.response.writeBody("Imma be a url route!");
}