-module(client_worker).

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {socket}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    application:ensure_all_started(chumak),

    gen_server:cast(self(), connect),

    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(connect, State) ->
    SocketPath = os:getenv("SOCKET_PATH"),

    {ok, Socket} = chumak:socket(sub),

    %% Chumak natively supports only TCP. To bypass its guard clauses
    %% (which strictly enforce 'is_list' for the Host), a custom fork was used.
    %% The 'chumak_peer:connect/6' function was overloaded to accept an IPC 
    %% SocketPath string as the Host and map it into a '{local, SocketPath}' tuple,
    %% enabling OTP gen_tcp's IPC support.
    case chumak:connect(Socket, ipc, SocketPath, 0) of
        {ok, _Pid} ->
            ok = chumak:subscribe(Socket, <<>>),

            gen_server:cast(self(), recv),

            {noreply, State#state{socket = Socket}};
        {error, Reason} ->
            {stop, {connection_failed, Reason}, State}
    end;

handle_cast(recv, #state{socket = Socket} = State) ->
    case chumak:recv(Socket) of
        {ok, Message} ->
            io:format("[Message received]: ~s~n", [Message]),

            gen_server:cast(self(), recv),

            {noreply, State};
        {error, Reason} ->
            io:format("Error receiving message: ~p~n", [Reason]),

            {stop, {error, Reason}, State}
    end;

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{socket = _Socket}) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.