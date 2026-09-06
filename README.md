# Взаимодействие приложений C и Erlang через ZeroMQ (PUB/SUB) с использованием Chumak

Реализация тестового задания по организации межпроцессного взаимодействия (IPC) между сервером на языке **C (Publisher)** и клиентом на **Erlang (Subscriber)** с использованием библиотеки **Chumak**.

## Особенности архитектуры
По условиям задания сокет должен работать по протоколу `ipc/inproc`. Однако Erlang-библиотека **Chumak** нативно поддерживает только протокол `tcp`. 

Для решения используется утилита `socat` в качестве моста между `ipc` и `tcp` протоколами.

**Схема работы:**
`[C Сервер (PUB)]` (ipc://) --> `[socat мост]` (tcp://) --> `[Erlang Клиент (SUB)]`

---

## Зависимости

Для сборки и запуска проекта в операционной системе Linux (тестировалось на **Debian**) использовались:

*   `gcc` и утилита `make`
*   `libzmq`
*   **Erlang/OTP:** Версия 24 или выше
*   **Библиотека Chumak:** Версия 1.5.0
*   `rebar3`
*   `socat`

---

## Сборка и запуск

Все этапы автоматизированы с помощью корневого `Makefile`.

### 1. Сборка
*   ```bash
    make
    ```

### 2. Запуск

*   ```bash
    make run_socat
    ```

*   ```bash
    make run_server
    ```

*   ```bash
    make run_client
    ```

### 3. Очистка

*   ```bash
    make clean
    ```

---

## Пример работы

1. Запуск утилиты socat:
   ```text
   make run_socat
   socat TCP-LISTEN:5555,reuseaddr,fork UNIX-CONNECT:/tmp/zmq_client_server_0
   ```
2. После запуска сервера в консоли появится приглашение к вводу:
   ```text
   make run_server
   Server is running and bound to ipc:///tmp/zmq_client_server_0:
   Type 'send' to send the message
   send
   [Message sent] Current time: 2026-09-01 13:40:55
   ```
3. В консоли клиента отобразится полученное сообщение:
   ```text
   make run_client
   [Message received] Current time: 2026-09-01 13:40:55
   ```

---

### Установка зависимостей в Debian:
```bash
sudo apt update
sudo apt install build-essential erlang rebar3 libzmq3-dev socat
```