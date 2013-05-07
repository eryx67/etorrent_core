%% @author Edward Wang <yujiangw@gmail.com>
%% @doc Implements a HTTP server for UPnP services to callback into.
%% @end
%%
%% @todo: Use supervisor_bridge instead?
%%        And rename to etorrent_upnp_httpd_sup?
-module(etorrent_upnp_handler).
-behaviour(cowboy_http_handler).

-export([init/3, handle/2, terminate/3]).

%% API
-export([get_port/0]).

%%===================================================================
%% API
%%===================================================================
-define(UPNP_PORT, 1234).
get_port() ->
    ?UPNP_PORT.

init({tcp, http}, Req, _Opts) ->
    {ok, Req, undefined_state}.

handle(Req, State) ->
    case cowboy_req:method(Req) of
        {<<"NOTIFY">>, Req1} ->
            {ok, ReqBody, Req2} = cowboy_req:body(Req1),
            %% @todo: intention here is to use eventing to monitor if there's
            %%        someone else steals etorrent's port mapping. but seems
            %%        the router used to test against it (linksys srt54g) doesn't
            %%        send out notifition for port mapping. so the port mapping
            %%        protection is yet to be implemented. only the eventing
            %%        subscribe / unsubscribe skeleton is done.
            case etorrent_upnp_proto:parse_notify_msg(ReqBody) of
                undefined ->
                    ignore
%%                Content ->
%%                    etorrent_upnp_entity:notify(Content)
            end,
            {ok, Reply} = cowboy_req:reply(200, [{'Content-type', <<"text/plain">>}],
                                           <<>>, Req2),
            {ok, Reply, State}
    end.

terminate(_Reason, _Req, _State) ->
    ok.
