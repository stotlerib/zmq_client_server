-module(client_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    application:ensure_all_started(chumak),

    {ok, Socket} = chumak:socket(sub),

    Port = application:get_env(client_app, port, 5555),

    case chumak:connect(Socket, tcp, "127.0.0.1", Port) of
        {ok, _Pid} -> 
            ok = chumak:subscribe(Socket, <<>>),

            loop(Socket);
        {error, Reason} -> 
            io:format("Connection failed: ~p~n", [Reason])
    end.

stop(_State) ->
    ok.

loop(Socket) ->
    case chumak:recv(Socket) of
        {ok, Message} ->
            io:format("Message received:~n~s~n", [Message]),
            loop(Socket);
        {error, Reason} ->
            io:format("Error receiving message: ~p~n", [Reason])
    end.