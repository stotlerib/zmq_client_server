%%%-------------------------------------------------------------------
%% @doc client top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(client_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = #{
        strategy => one_for_one,
        intensity => 3,
        period => 5
    },

    ChildSpecs = [
        #{
            id => client_worker,
            start => {client_worker, start_link, []},
            restart => permanent,
            shutdown => 2000,
            type => worker,
            modules => [client_worker]
        }
    ],

    {ok, {SupFlags, ChildSpecs}}.