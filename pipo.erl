-module(pipo).
-export([start/0, pong/0, ping/1]).

-define(ping(Msg, From), {ping, Msg, From}).
-define(pong(Msg, From), {pong, Msg, From}).
-define(log(From, Msg, Args), io:format("[" ++ From ++ "] " ++ Msg, Args)).

start() ->
    Ponger = spawn(?MODULE, pong, []),
    Pinger = spawn(?MODULE, ping, [Ponger]),
    ?log("console", "Started: pinger: ~p, ponger: ~p~n", [Pinger, Ponger]),
    ok.

pong() ->
    receive
        ?ping(Msg, Pinger) ->
            ?log("ponger", "Got ping from pinger ~p: ~p~n", [Pinger, Msg]),
            ?log("ponger", "Sending pong back to ~p~n", [Pinger]),
            Pinger ! ?pong(Msg, self()),
            timer:sleep(5000);
        StrangeThing ->
            ?log("ponger", "Got some strange thing: ~p~n", [StrangeThing])
    end,
    pong().

ping(Ponger) ->
    ?log("pinger", "Sending ping to ~p~n", [Ponger]),
    Ponger ! ?ping("Weeeee!", self()),
    receive
        ?pong(Msg, Ponger) ->
            ?log("pinger", "Got pong from ponger ~p: ~p~n", [Ponger, Msg]),
            timer:sleep(5000);
        ?pong(Msg, SomeGuy) ->
            ?log("pinger", "Got pong from some guy ~p: ~p~n", [SomeGuy, Msg]);
        StrangeThing ->
            ?log("pinger", "Got some strange thing: ~p~n", [StrangeThing])
    end,
    ping(Ponger).
