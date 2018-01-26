/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.server.plugins.core;

import haxe.Json;
import StringTools;
import saturn.app.SaturnServer;
import js.Node;

/**
* ProxyPlugin
*
* Configuration:
* {
*   "clazz": "saturn.server.plugins.core.ProxyPlugin",
*   "routes": {
*     "/GlycanBuilder.*" :{
*       "target": "http://localhost:8080/",
*       "GET": true,
*       "POST": true
*     }
*   }
* }
**/

class ProxyPlugin extends BaseServerPlugin{
    var proxy : Dynamic;

    public function new(server : SaturnServer, config : Dynamic){
        super(server, config);

        configure();
    }

    public function configure(){
        // Load HTTP Proxy module
        var httpProxy = Node.require('http-proxy');

        // Load agent module to implement Keep Alive to improve proxy performance
        var Agent = Node.require('agentkeepalive');
        var agent =  untyped __js__('new Agent({
            maxSockets: 100,
            keepAlive: true,
            maxFreeSockets: 20,
            keepAliveMsecs:100000,
            timeout: 600000,
            keepAliveTimeout: 300000 // free socket keepalive for 30 seconds
        })');

        // Create Proxy server
        proxy = httpProxy.createProxyServer({agent:agent}); //{agent: agent}

        // Get SaturnServer instance
        var server = getSaturnServer().getServer();

        var restify : Dynamic = Node.require('restify');

        server.use(wrapMiddleware(restify.plugins.bodyParser({mapParams: true})));

        // Iterate routes to proxy from configuration
        for(route in Reflect.fields(config.routes)){
            var routeConfig = Reflect.field(config.routes, route);
            debug('Routing ' + route + ' to ' + routeConfig.target);

            if(routeConfig.GET){
                debug('Adding GET proxy');
                server.get(route, function(req, res) {
                    debug('Request: ' + req.getPath());
                    proxyRequest(req, res, routeConfig.target);
                });
            }

            if(routeConfig.POST){
                debug('Adding POST proxy');
                server.post(route, function(req, res) {
                    proxyRequest(req, res, routeConfig.target);
                });
            }
        }

        proxy.on('error', function(error, req, res){
            var json;
            debug('proxy error', error);

            if (!res.headersSent) {
                res.writeHead(500, { 'content-type': 'application/json' });
            }

            json = { error: 'proxy_error', reason: error.message };
            res.end(Json.stringify(json));
        });
    }

    /**
    * proxyRequest proxies a request to target
    *
    * req: Request object
    * res: Response object
    * target: Target address
    **/
    private function proxyRequest(req, res, target){
        proxy.web(req, res, { target: target });
    }

    //Proxy gist - https://gist.github.com/jeffwhelpley/5417758
    private function wrapMiddleware(middleware : Dynamic) {
        return function(req, res, next) {
            //var regex : EReg = ~/^\/GlycanBuilder.*$/;

            // Hard coded for now as regex on each request is too slow for a proxy
            if(StringTools.startsWith(req.path(),'/GlycanBuilder')){
                next();
            }else {

                if(Std.is(middleware, Array)){
                    middleware[0](req, res, function() {
                        middleware[1](req, res, next);
                    });
                }else{
                    middleware(req, res, next);
                }
            }
        };
    }
}