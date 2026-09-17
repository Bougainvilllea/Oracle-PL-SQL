INSERT INTO E_Users (first_name, last_name, middle_name, email, salary, date_of_employment)
VALUES ('Иван', 'Иванов', 'Петрович', 'ivanov@test.com', 100000, DATE '2020-01-15');

INSERT INTO E_Users (first_name, last_name, middle_name, email, salary, date_of_employment)
VALUES ('Петр', 'Петров', 'Сергеевич', 'petrov@test.com', 120000, DATE '2019-03-10');

INSERT INTO E_Users (first_name, last_name, middle_name, email, salary, date_of_employment)
VALUES ('Анна', 'Сидорова', 'Ивановна', 'sidorova@test.com', 150000, DATE '2018-06-01');

INSERT INTO E_Users (first_name, last_name, middle_name, email, salary, date_of_employment)
VALUES ('Мария', 'Кузнецова', 'Олеговна', 'kuznetsova@test.com', 130000, DATE '2021-09-20');

INSERT INTO E_Users (first_name, last_name, middle_name, email, salary, date_of_employment)
VALUES ('Алексей', 'Смирнов', 'Дмитриевич', 'smirnov@test.com', 110000, DATE '2022-04-05');

COMMIT;

INSERT INTO E_Project (name, start_date, end_date, budget)
VALUES ('CRM System', DATE '2024-01-01', DATE '2025-12-31', 5000000);

INSERT INTO E_Project (name, start_date, end_date, budget)
VALUES ('Mobile App', DATE '2024-03-01', DATE '2025-06-30', 3000000);

INSERT INTO E_Project (name, start_date, end_date, budget)
VALUES ('Data Warehouse', DATE '2024-06-01', NULL, 8000000);

COMMIT;

BEGIN
    assign_user_to_project(1, 1);
    assign_user_to_project(2, 1);
    assign_user_to_project(3, 1);
    assign_user_to_project(1, 2);
    assign_user_to_project(4, 2);
    assign_user_to_project(3, 3);
    assign_user_to_project(4, 3);
    assign_user_to_project(5, 3);
END;


DECLARE
    v_id NUMBER;
BEGIN
    create_task('Написать API для CRM', 1, 1, 1, SYSDATE - 10, NULL, v_id);
    create_task('Исправить баг входа', 2, 1, 3, SYSDATE - 3, NULL, v_id);
    create_task('Дизайн главного экрана', 1, 2, 2, SYSDATE + 21, NULL, v_id);
    create_task('Настроить ETL', 3, 3, 1, SYSDATE + 30, NULL, v_id);
    create_task('Обновить документацию', 1, 1, 2, SYSDATE + 7, NULL, v_id);
    create_task('Оптимизация запросов', 2, 1, 2, SYSDATE - 1, NULL, v_id);
    create_task('Релиз мобильной версии', 1, 2, 1, SYSDATE + 14, NULL, v_id);
    create_task('Анализ логов', 3, 3, 3, SYSDATE + 60, NULL, v_id);
    create_task('Задача 9', 1, 1, 1, SYSDATE + 5, NULL, v_id);
    create_task('Задача 10', 2, 1, 2, SYSDATE + 6, NULL, v_id);
    create_task('Задача 11', 3, 3, 3, SYSDATE + 8, NULL, v_id);
    create_task('Задача 12', 1, 1, 1, SYSDATE + 9, NULL, v_id);
    create_task('Задача 13', 1, 2, 2, SYSDATE + 10, NULL, v_id);
    create_task('Задача 14', 2, 1, 1, SYSDATE + 11, NULL, v_id);
END;


BEGIN
    assign_performer(1, 3);
    assign_performer(2, 2);
    assign_performer(3, 4);
    assign_performer(4, 3);
    assign_performer(5, 1);
    assign_performer(6, 3);
    assign_performer(7, 4);
    assign_performer(9, 3);
    assign_performer(10, 3);
    assign_performer(11, 3);
    assign_performer(12, 1);
    assign_performer(13, 4);
    assign_performer(14, 2);
END;

BEGIN
    change_status(1, 2);
    change_status(2, 2);
    change_status(2, 3);
    change_status(2, 4);
    change_status(3, 2);
    change_status(6, 2);
    change_status(6, 3);
    change_status(7, 2);
    change_status(7, 3);
    change_status(7, 4);
    change_status(7, 5);
    change_status(7, 6);
    change_status(9, 2);
    change_status(10, 2);
    change_status(11, 2);
    change_status(13, 2);
    change_status(14, 2);
END;

