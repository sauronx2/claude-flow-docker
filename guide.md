⏺ Claude-Flow Architecture: Полная картина

  1. Компоненты системы

  ┌─────────────────────────────────────────────────────────────┐
  │                         MAC (HOST)                           │
  │                                                               │
  │  ┌────────────────────────────────────────────────────────┐ │
  │  │  ~/WorkProjects/                                        │ │
  │  │  ├── android-favbet-3.0/         ← Твои проекты        │ │
  │  │  ├── mna-mobile-native-autotests/                      │ │
  │  │  └── erlybetclient_redesign/                           │ │
  │  └────────────────────────────────────────────────────────┘ │
  │                                                               │
  │  ┌────────────────────────────────────────────────────────┐ │
  │  │  ~/.claude.json                                         │ │
  │  │  {                                                      │ │
  │  │    "mcpServers": {                                      │ │
  │  │      "claude-flow": {                                   │ │
  │  │        "type": "sse",                                   │ │
  │  │        "url": "http://localhost:8080/sse"  ←───────┐   │ │
  │  │      }                                              │   │ │
  │  │    }                                                │   │ │
  │  │  }                                                  │   │ │
  │  └─────────────────────────────────────────────────────│───┘ │
  │                                                         │     │
  │  ┌────────────────────────────────────────────────────┐│     │
  │  │  Claude Code (я, в терминале)                      ││     │
  │  │                                                     ││     │
  │  │  Ты → claude (команда)                             ││     │
  │  │       ↓                                             ││     │
  │  │  Я запускаюсь, читаю ~/.claude.json                ││     │
  │  │       ↓                                             ││     │
  │  │  Вижу claude-flow MCP server                       ││     │
  │  │       ↓                                             ││     │
  │  │  Коннечусь по SSE к http://localhost:8080/sse ─────┘│     │
  │  │       ↓                                              │     │
  │  │  Получаю список tools от Claude-Flow MCP            │     │
  │  └─────────────────────────────────────────────────────┘     │
  │                          ↓                                    │
  │                   SSE соединение                              │
  │                   (Server-Sent Events)                        │
  │                          ↓                                    │
  └──────────────────────────│────────────────────────────────────┘
                             │
                      localhost:8080
                             │
  ┌──────────────────────────▼────────────────────────────────────┐
  │                    DOCKER CONTAINER                            │
  │                    (claude-flow)                               │
  │                                                                │
  │  ┌──────────────────────────────────────────────────────────┐ │
  │  │  mcp-proxy (порт 8080)                                   │ │
  │  │                                                           │ │
  │  │  Слушает HTTP/SSE запросы на порту 8080                 │ │
  │  │         ↓                                                 │ │
  │  │  Конвертирует SSE → stdio                                │ │
  │  │         ↓                                                 │ │
  │  │  Передаёт в Claude-Flow MCP через stdin/stdout          │ │
  │  └───────────────────────┬───────────────────────────────────┘ │
  │                          │ stdio                               │
  │                          ↓                                     │
  │  ┌──────────────────────────────────────────────────────────┐ │
  │  │  Claude-Flow MCP Server                                  │ │
  │  │  (npx claude-flow@alpha mcp start)                       │ │
  │  │                                                           │ │
  │  │  Предоставляет MCP tools:                                │ │
  │  │  ├── spawn_agent         (создать агента)               │ │
  │  │  ├── swarm_orchestrate   (запустить swarm)              │ │
  │  │  ├── hive_mind_init      (инициализировать hive)        │ │
  │  │  ├── queen_coordinate    (координация Queen)            │ │
  │  │  ├── worker_assign       (назначить задачу Worker)      │ │
  │  │  ├── memory_store        (сохранить в память)           │ │
  │  │  └── ... ещё ~20 tools                                   │ │
  │  │                                                           │ │
  │  │  Использует:                                             │ │
  │  │  ├── SQLite БД (/.swarm/memory.db)                      │ │
  │  │  ├── AgentDB (векторная память)                         │ │
  │  │  └── ReasoningBank (паттерны решений)                   │ │
  │  └──────────────────────────────────────────────────────────┘ │
  │                                                                │
  │  ┌──────────────────────────────────────────────────────────┐ │
  │  │  Volumes (персистентное хранилище)                       │ │
  │  │                                                           │ │
  │  │  claude-flow-db (Docker volume)                          │ │
  │  │  └── /.swarm/memory.db    ← База знаний агентов         │ │
  │  │      ├── decisions         (решения)                     │ │
  │  │      ├── performance       (метрики)                     │ │
  │  │      ├── patterns          (паттерны)                    │ │
  │  │      └── sessions          (сессии работы)               │ │
  │  └──────────────────────────────────────────────────────────┘ │
  └────────────────────────────────────────────────────────────────┘

  2. Workflow: Как всё работает пошагово

  Шаг 1: Запуск Docker контейнера

  cd ~/claude-flow-docker
  make start

  Что происходит:
  1. Docker Compose читает docker-compose.yml
  2. Запускает контейнер claude-flow
  3. Внутри контейнера выполняется CMD из Dockerfile:
  mcp-proxy --port 8080 npx claude-flow@alpha mcp start
  4. mcp-proxy запускается на порту 8080
  5. mcp-proxy запускает npx claude-flow@alpha mcp start как дочерний процесс
  6. Claude-Flow MCP стартует в stdio режиме
  7. mcp-proxy слушает SSE запросы на http://0.0.0.0:8080/sse
  8. Docker пробрасывает порт 8080 наружу (ports: - "8080:8080")

  Результат: MCP server доступен на http://localhost:8080/sse с твоего Mac

  ---
  Шаг 2: Подключение Claude Code к MCP server

  claude mcp add --transport sse claude-flow --scope user http://localhost:8080/sse

  Что происходит:
  1. Команда добавляет запись в ~/.claude.json:
  {
    "mcpServers": {
      "claude-flow": {
        "type": "sse",
        "url": "http://localhost:8080/sse"
      }
    }
  }
  2. Теперь при запуске claude, я читаю этот конфиг
  3. Коннечусь к http://localhost:8080/sse через SSE протокол
  4. Получаю список доступных tools от Claude-Flow

  ---
  Шаг 3: Запуск Claude Code

  claude

  Что происходит:
  1. Я (Claude Code) запускаюсь в терминале
  2. Читаю ~/.claude.json
  3. Вижу claude-flow MCP server
  4. Открываю SSE соединение к http://localhost:8080/sse
  5. Отправляю MCP запрос: initialize
  6. mcp-proxy получает HTTP запрос
  7. mcp-proxy конвертирует его в JSON через stdio
  8. Claude-Flow MCP получает запрос через stdin
  9. Claude-Flow MCP отвечает через stdout
  10. mcp-proxy конвертирует ответ в SSE event
  11. Я получаю список tools:
  ✓ spawn_agent
  ✓ swarm_orchestrate
  ✓ hive_mind_init
  ✓ queen_coordinate
  ... и ещё ~20 tools

  Результат: У меня есть доступ к Claude-Flow tools!

  ---
  Шаг 4: Ты даёшь мне задачу

  Ты: "Запусти 3 агента параллельно:
       1. Добавь тесты для авторизации
       2. Добавь локаторы для регистрации
       3. Исправь баг в MainActivity"

  Что происходит:

  1. Я анализирую твою задачу
  2. Понимаю что нужно запустить параллельных агентов
  3. Решаю использовать Claude-Flow MCP tool: swarm_orchestrate
  4. Формирую MCP запрос:
  {
    "method": "tools/call",
    "params": {
      "name": "swarm_orchestrate",
      "arguments": {
        "tasks": [
          {
            "id": "task-1",
            "description": "Добавь тесты для авторизации",
            "role": "tester"
          },
          {
            "id": "task-2",
            "description": "Добавь локаторы для регистрации",
            "role": "coder"
          },
          {
            "id": "task-3",
            "description": "Исправь баг в MainActivity",
            "role": "coder"
          }
        ],
        "mode": "parallel"
      }
    }
  }
  5. Отправляю через SSE к http://localhost:8080/sse

  ---
  Шаг 5: Обработка в Docker контейнере

  mcp-proxy (порт 8080):
  1. Получает HTTP POST запрос с JSON
  2. Конвертирует в JSON-RPC через stdio
  3. Передаёт в stdin процесса npx claude-flow@alpha mcp start

  Claude-Flow MCP Server:
  1. Получает запрос через stdin
  2. Парсит JSON: swarm_orchestrate + аргументы
  3. Инициализирует Swarm систему
  4. Создаёт 3 агента (Worker agents):
    - Agent 1: role=tester, task="тесты для авторизации"
    - Agent 2: role=coder, task="локаторы для регистрации"
    - Agent 3: role=coder, task="баг в MainActivity"
  5. Queen Agent координирует Workers
  6. Агенты начинают работать ПАРАЛЛЕЛЬНО
  7. Каждый агент:
    - Анализирует задачу
    - Использует свои tools (read files, edit, write, etc)
    - Записывает прогресс в SQLite (/.swarm/memory.db)
    - Отчитывается Queen
  8. Queen собирает результаты
  9. Claude-Flow MCP формирует ответ
  10. Отправляет через stdout

  mcp-proxy:
  1. Получает ответ через stdout
  2. Конвертирует в SSE event
  3. Отправляет HTTP response

  Я (Claude Code):
  1. Получаю SSE event с результатами
  2. Парсю ответ от агентов
  3. Формирую понятный ответ тебе

  ---
  Шаг 6: Ты видишь результат

  Я: "✅ Готово! 3 агента завершили работу:

  Agent 1 (Tester):
  - Добавил тесты в app/src/test/java/AuthTest.kt
  - Покрытие: логин, регистрация, forgot password
  - Все тесты проходят ✓

  Agent 2 (Coder):
  - Добавил contentDescription во fragment_registration.xml
  - Локаторы: email_input, password_input, register_button
  - Готово для автотестов ✓

  Agent 3 (Coder):
  - Исправил NullPointerException в MainActivity.kt:47
  - Проблема: user?.name без null-check
  - Добавил safe call: user?.name ?: "Guest" ✓"

  ---
  3. Где что находится

  На Mac (Host):

  ~/WorkProjects/                  ← Твои проекты (НЕ в Docker!)
    ├── android-favbet-3.0/
    ├── mna-mobile-native-autotests/
    └── erlybetclient_redesign/

  ~/.claude.json                   ← Конфиг Claude Code + MCP серверы
    └── mcpServers.claude-flow     ← Подключение к Docker MCP

  ~/claude-flow-docker/            ← Docker setup
    ├── Dockerfile                 ← Образ с Claude-Flow + mcp-proxy
    ├── docker-compose.yml         ← Конфиг контейнера
    └── Makefile                   ← Удобные команды

  В Docker контейнере:

  / (root контейнера)
  ├── usr/local/lib/node_modules/
  │   ├── claude-flow/            ← Установлен глобально
  │   └── mcp-proxy/              ← Установлен глобально
  │
  ├── .swarm/                     ← Рабочая директория Claude-Flow
  │   └── memory.db               ← SQLite база (AgentDB + ReasoningBank)
  │
  └── .claude/                    ← Конфиг Claude-Flow
      ├── agents/                 ← 64+ специализированных агентов
      ├── commands/               ← Команды для работы
      └── settings.json           ← Настройки

  Docker Volumes (персистентные):

  claude-flow-db (named volume)
    └── Хранит /.swarm/memory.db между перезапусками

  node-modules-cache (named volume)
    └── Кеш npm пакетов

  ---
  4. Как общаются компоненты

  Протоколы:

  1. SSE (Server-Sent Events):
  - Между Claude Code (я) и mcp-proxy
  - HTTP long-polling соединение
  - Однонаправленный поток: server → client (events)
  - Запросы через HTTP POST, ответы через SSE events

  2. stdio (Standard Input/Output):
  - Между mcp-proxy и Claude-Flow MCP
  - JSON-RPC через stdin/stdout
  - Двунаправленный: запросы через stdin, ответы через stdout

  3. Docker port mapping:
  - 8080:8080 в docker-compose.yml
  - Контейнер слушает 0.0.0.0:8080
  - Host видит localhost:8080

  ---
  5. MCP Tools от Claude-Flow

  Swarm Orchestration:
  - swarm_orchestrate - запустить swarm агентов
  - spawn_agent - создать одного агента
  - swarm_status - статус swarm

  Hive-Mind System:
  - hive_mind_init - инициализировать hive
  - queen_coordinate - Queen координирует Workers
  - worker_assign - назначить задачу Worker
  - consensus_vote - голосование агентов

  Memory System:
  - memory_store - сохранить в SQLite
  - memory_query - запросить из памяти
  - memory_search - семантический поиск (AgentDB)

  Performance:
  - performance_metrics - метрики агентов
  - neural_sync - синхронизация паттернов

  ---
  6. Данные и персистентность

  SQLite Database (/.swarm/memory.db):

  -- Таблицы в базе:

  decisions            -- Решения агентов
  performance_metrics  -- Метрики производительности
  learned_patterns     -- Выученные паттерны
  agent_sessions       -- Сессии работы агентов
  task_history         -- История выполненных задач
  reasoning_chains     -- Цепочки рассуждений
  vector_embeddings    -- Векторные эмбеддинги (AgentDB)

  Персистентность:
  - Volume claude-flow-db сохраняется между перезапусками
  - Даже после make stop и make start - данные остаются
  - make clean удалит всё (включая память)

  ---
  7. Жизненный цикл запроса

  1. Ты пишешь задачу
     ↓
  2. Я (Claude Code на Mac) получаю текст
     ↓
  3. Решаю использовать Claude-Flow MCP tool
     ↓
  4. Формирую MCP запрос (JSON-RPC)
     ↓
  5. Отправляю через SSE к localhost:8080/sse
     ↓
  6. mcp-proxy (в Docker) получает HTTP
     ↓
  7. mcp-proxy конвертирует в stdio JSON
     ↓
  8. Claude-Flow MCP получает через stdin
     ↓
  9. Claude-Flow создаёт/координирует агентов
     ↓
  10. Агенты работают параллельно
     ↓
  11. Записывают прогресс в SQLite
     ↓
  12. Claude-Flow собирает результаты
     ↓
  13. Отправляет ответ через stdout
     ↓
  14. mcp-proxy конвертирует в SSE event
     ↓
  15. mcp-proxy отправляет HTTP response
     ↓
  16. Я (Claude Code) получаю результаты
     ↓
  17. Форматирую и показываю тебе

  ---
  8. Что НЕ в Docker

  ❌ Твои проекты - остаются в ~/WorkProjects/
  ❌ Claude Code (я) - запускаюсь на Mac
  ❌ Основная работа - всё на Mac как обычно

  ✅ В Docker ТОЛЬКО Claude-Flow MCP server (сервис для spawning агентов)

  ---
  Итог:

  Docker контейнер = фоновый сервис который предоставляет MCP tools

  Ты → Я (Claude Code на Mac) → Docker MCP → Swarm агенты

  Проекты остаются на Mac, Docker только для оркестрации агентов!
