CREATE TABLE E_Users (
    id                 NUMBER PRIMARY KEY,                          -- ID пользователя
    first_name         VARCHAR2(255) NOT NULL,                      -- Имя
    last_name          VARCHAR2(255) NOT NULL,                      -- Фамилия
    middle_name        VARCHAR2(255),                               -- Отчество
    email              VARCHAR2(255) NOT NULL,                      -- Email
    date_of_employment DATE,                                        -- Дата приёма
    salary             NUMBER,                                      -- Зарплата

    CONSTRAINT uq_users_email UNIQUE (email)                        -- Email уникален
);

CREATE TABLE E_Project (
    id                 NUMBER PRIMARY KEY,                          -- ID проекта
    name               VARCHAR2(255) NOT NULL,                      -- Название
    start_date         DATE,                                        -- Дата начала
    end_date           DATE,                                        -- Дата окончания
    is_active          NUMBER(1) DEFAULT 1 NOT NULL,                -- Активен (1/0)
    budget             NUMBER,                                      -- Бюджет

    CONSTRAINT uq_project_name UNIQUE (name),                       -- Название уникально
    CONSTRAINT chk_project_active CHECK (is_active IN (0, 1))       -- Только 0 или 1
);

CREATE TABLE E_Involvement (
    id                 NUMBER PRIMARY KEY,                          -- ID записи
    user_id            NUMBER NOT NULL,                             -- ID пользователя
    project_id         NUMBER NOT NULL,                             -- ID проекта

    CONSTRAINT uq_involvement UNIQUE (user_id, project_id),         -- Уникальная пара
    CONSTRAINT fk_inv_user    FOREIGN KEY (user_id)    REFERENCES E_Users(id),   -- FK на пользователя
    CONSTRAINT fk_inv_project FOREIGN KEY (project_id) REFERENCES E_Project(id)  -- FK на проект
);

CREATE TABLE E_Task_states (
    id                 NUMBER PRIMARY KEY,                          -- ID статуса
    status_name        VARCHAR2(255) NOT NULL,                      -- Название статуса
    sort_order         NUMBER NOT NULL,                             -- Порядок перехода

    CONSTRAINT uq_status_name  UNIQUE (status_name),                -- Название уникально
    CONSTRAINT uq_status_order UNIQUE (sort_order)                  -- Порядок уникален
);

CREATE TABLE E_Task_Type (
    id                 NUMBER PRIMARY KEY,                          -- ID типа
    type_name          VARCHAR2(255) NOT NULL,                      -- Название типа

    CONSTRAINT uq_type_name UNIQUE (type_name)                      -- Название уникально
);

CREATE TABLE E_Tasks (
    id                 NUMBER PRIMARY KEY,                          -- ID задачи
    title              VARCHAR2(255) NOT NULL,                      -- Название
    performer_id       NUMBER,                                      -- ID исполнителя
    author_id          NUMBER NOT NULL,                             -- ID автора
    deadline           DATE,                                        -- Срок
    status_id          NUMBER NOT NULL,                             -- ID статуса
    type_id            NUMBER NOT NULL,                             -- ID типа
    project_id         NUMBER NOT NULL,                             -- ID проекта
    created_at         DATE,                                        -- Дата создания

    CONSTRAINT fk_task_performer FOREIGN KEY (performer_id) REFERENCES E_Users(id),        -- FK исполнитель
    CONSTRAINT fk_task_author    FOREIGN KEY (author_id)    REFERENCES E_Users(id),        -- FK автор
    CONSTRAINT fk_task_status    FOREIGN KEY (status_id)    REFERENCES E_Task_states(id),  -- FK статус
    CONSTRAINT fk_task_type      FOREIGN KEY (type_id)      REFERENCES E_Task_Type(id),    -- FK тип
    CONSTRAINT fk_task_project   FOREIGN KEY (project_id)   REFERENCES E_Project(id)       -- FK проект
);

CREATE TABLE E_Tasks_Audit (
    id                 NUMBER PRIMARY KEY,                          -- ID записи
    task_id            NUMBER NOT NULL,                             -- ID задачи
    field_name         VARCHAR2(50),                                -- Поле
    old_value          VARCHAR2(4000),                              -- Старое значение
    new_value          VARCHAR2(4000),                              -- Новое значение
    db_user            VARCHAR2(100),                               -- Пользователь БД
    date_of_change     DATE                                         -- Дата изменения
);

CREATE TABLE E_Logs (
    id                 NUMBER PRIMARY KEY,                          -- ID записи
    method_name        VARCHAR2(255),                               -- Метод
    log_date           DATE,                                        -- Дата
    error_text         VARCHAR2(4000)                               -- Текст ошибки
);

CREATE INDEX idx_e_inv_user ON E_Involvement(user_id);
CREATE INDEX idx_e_inv_project ON E_Involvement(project_id);

CREATE INDEX idx_e_tasks_performer ON E_Tasks(performer_id);
CREATE INDEX idx_e_tasks_author    ON E_Tasks(author_id);
CREATE INDEX idx_e_tasks_status    ON E_Tasks(status_id);
CREATE INDEX idx_e_tasks_type      ON E_Tasks(type_id);
CREATE INDEX idx_e_tasks_project   ON E_Tasks(project_id);   

CREATE INDEX idx_e_tasks_deadline  ON E_Tasks(deadline);
CREATE INDEX idx_e_tasks_created   ON E_Tasks(created_at);


