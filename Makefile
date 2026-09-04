SOCKET_PATH ?= /tmp/zmq_client_server_0
PORT        ?= 5555

CC          = gcc
CFLAGS      = -Wall -Wextra -O2
LIBS        = -lzmq
C_TARGET    = server/zmq_server
C_SRC       = server/main.c

ERL_DIR     = client

.PHONY: all
all: build

.PHONY: build
build: build_server build_client

.PHONY: clean
clean: clean_server clean_client

.PHONY: build_server
build_server:
	$(CC) $(CFLAGS) $(C_SRC) -o $(C_TARGET) $(LIBS)

.PHONY: run_server
run_server: build_server
	./$(C_TARGET) "$(SOCKET_PATH)"

.PHONY: clean_server
clean_server:
	rm -f $(C_TARGET)
	rm -f $(SOCKET_PATH)

.PHONY: build_client
build_client:
	@cd $(ERL_DIR) && rebar3 compile

.PHONY: run_client
run_client: build_client
	@cd $(ERL_DIR) && ERL_FLAGS="-client_app port $(PORT)" rebar3 shell

.PHONY: clean_client
clean_client:
	@cd $(ERL_DIR) && rebar3 clean --all
	rm -rf $(ERL_DIR)/_build
	rm -rf $(ERL_DIR)/.rebar3
	rm -f $(ERL_DIR)/rebar.lock
	rm -f $(ERL_DIR)/erl_crash.dump ./erl_crash.dump

.PHONY: run_socat
run_socat:
	socat TCP-LISTEN:$(PORT),reuseaddr,fork UNIX-CONNECT:$(SOCKET_PATH)