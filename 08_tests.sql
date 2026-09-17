-- Отчеты
SELECT * FROM v_report_overdue_tasks; -- 1)	Отчет по задач с просроченным дедлайном
SELECT * FROM v_report_tasks_by_performer; -- 2) Отчет по количество задач у каждого исполнителя в разрезе статусов
SELECT * FROM v_report_unfinished_tasks; -- 3) Отчет по  невыполненным задачам, то есть задачам, имеющим статусы «создано», «в работе». 
SELECT * FROM v_report_users_without_tasks; -- 4) Отчет по пользователям, назначенным на проект, но не имеющим ни одной задачи.
SELECT * FROM v_report_top3_performers; -- 5) Отчет, показывающий топ – 3 исполнителя

-- Функции

-- user_id=1 состоит в задачи 1 и 2
DECLARE
    v_cur  SYS_REFCURSOR;
    v_id   NUMBER; v_title VARCHAR2(255); v_dl DATE; v_cr DATE;
    v_perf VARCHAR2(255); v_stat VARCHAR2(255); v_proj VARCHAR2(255);
    v_cnt  NUMBER := 0;
BEGIN
    v_cur := get_tasks_by_filter(1, NULL, NULL, NULL);
    LOOP
        FETCH v_cur INTO v_id, v_title, v_dl, v_cr, v_perf, v_stat, v_proj;
        EXIT WHEN v_cur%NOTFOUND;
        v_cnt := v_cnt + 1;
    END LOOP;
    CLOSE v_cur;
    IF v_cnt > 0 THEN
        DBMS_OUTPUT.PUT_LINE('PASS: вернулось ' || v_cnt || ' задач');
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL: 0 задач');
    END IF;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('FAIL: ' || SQLERRM);
END;

-- user_id = 1 не состоит в проекте 3, ожидается 0 строк
DECLARE
    v_cur SYS_REFCURSOR;
    v1 NUMBER; v2 VARCHAR2(255); v3 DATE; v4 DATE;
    v5 VARCHAR2(255); v6 VARCHAR2(255); v7 VARCHAR2(255);
    v_cnt NUMBER := 0;
BEGIN
    v_cur := get_tasks_by_filter(1, 3, NULL, NULL);
    LOOP
        FETCH v_cur INTO v1, v2, v3, v4, v5, v6, v7;
        EXIT WHEN v_cur%NOTFOUND;
        v_cnt := v_cnt + 1;
    END LOOP;
    CLOSE v_cur;
    DBMS_OUTPUT.PUT_LINE('ТЕСТ 4 (чужой проект): ' ||
        CASE WHEN v_cnt = 0 THEN 'PASS' ELSE 'FAIL' END ||
        ' [' || v_cnt || ' строк]');
END;

-- Процедуры

-- assign_user_to_project
-- повторное назначение уже состоящего в проекте пользователя
BEGIN
    assign_user_to_project(1, 1);
    DBMS_OUTPUT.PUT_LINE('FAIL: повторное назначение прошло');
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('PASS: ' || SQLERRM);
END;

-- create_task
-- успешное создание задачи автором (user_id=1) в проекте 1
DECLARE
    v_id NUMBER;
BEGIN
    create_task('Тестовая задача', 1, 1, 1, SYSDATE + 5, NULL, v_id);
    DBMS_OUTPUT.PUT_LINE('PASS: создана задача ID=' || v_id);
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('FAIL: ' || SQLERRM);
END;

--assign_performer 
-- попытка сменить уже назначенного исполнителя у задачи 1
BEGIN
    assign_performer(1, 2);
    DBMS_OUTPUT.PUT_LINE('FAIL: смена прошла');
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('PASS: ' || SQLERRM);
END;

--change_status 
-- попытка вернуть задачу 1 в статус "Создано" (id=1)
BEGIN
    change_status(1, 1);
    DBMS_OUTPUT.PUT_LINE('FAIL: возврат прошёл');
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('PASS: ' || SQLERRM);
END;

--audit
DECLARE
    v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM E_Tasks_Audit;
    IF v_cnt > 0 THEN
        DBMS_OUTPUT.PUT_LINE('PASS: записей в аудите — ' || v_cnt);
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL: аудит пуст');
    END IF;
END;

SELECT * FROM E_TASKS_AUDIT;

--logs
DECLARE
    v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM E_Logs;
    IF v_cnt > 0 THEN
        DBMS_OUTPUT.PUT_LINE('PASS: записей в логах — ' || v_cnt);
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL: логи пусты');
    END IF;
END;

SELECT * FROM E_LOGS;
