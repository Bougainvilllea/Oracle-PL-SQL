DELETE FROM E_TASK_STATES;
DELETE FROM E_Task_Type;

INSERT INTO E_TASK_STATES (id, status_name, sort_order) VALUES (1, 'Создано', 1);
INSERT INTO E_Task_states (id, status_name, sort_order) VALUES (2, 'В работе', 2);
INSERT INTO E_Task_states (id, status_name, sort_order) VALUES (3, 'Выполнено', 3);
INSERT INTO E_Task_states (id, status_name, sort_order) VALUES (4, 'На тестировании', 4);
INSERT INTO E_Task_states (id, status_name, sort_order) VALUES (5, 'Протестировано', 5);
INSERT INTO E_Task_states (id, status_name, sort_order) VALUES (6, 'Перенесено в продакшен', 6);

INSERT INTO E_Task_Type (id, type_name) VALUES (1, 'Новый функционал');
INSERT INTO E_Task_Type (id, type_name) VALUES (2, 'Усовершенствование');
INSERT INTO E_Task_Type (id, type_name) VALUES (3, 'Исправление ошибок');

COMMIT;
