-- 1)	Отчет по задач с просроченным дедлайном
CREATE OR REPLACE VIEW v_report_overdue_tasks AS
SELECT t.title, NVL(u.last_name || ' ' || u.first_name || ' ' || NVL(u.middle_name, ''), '(не назначен)') AS performer_fio,
	p.name, ts.status_name, TRUNC(SYSDATE) - TRUNC(t.deadline) AS days_overdue
FROM E_Tasks t
LEFT JOIN E_Users u ON t.performer_id = u.id
LEFT JOIN E_Project p ON t.project_id = p.id
LEFT JOIN E_Task_states ts ON t.status_id = ts.id
WHERE t.deadline IS NOT NULL
  AND t.deadline < SYSDATE;


-- 2)	Отчет по количество задач у каждого исполнителя в разрезе статусов. 
CREATE OR REPLACE VIEW v_report_tasks_by_performer AS
SELECT NVL(u.last_name || ' ' || u.first_name || ' ' || NVL(u.middle_name, ''), '(не назначен)') AS performer_fio,
	ts.status_name, COUNT(*) AS task_count
FROM E_Tasks t
LEFT JOIN E_Users u ON t.performer_id = u.id
LEFT JOIN E_Task_states ts ON t.status_id = ts.id
GROUP BY u.last_name, u.first_name, u.middle_name, ts.status_name
ORDER BY performer_fio, ts.status_name;


-- 3)	Отчет по  невыполненным задачам, то есть задачам, имеющим статусы «создано», «в работе».
CREATE OR REPLACE VIEW v_report_unfinished_tasks AS
SELECT t.title, NVL(u.last_name || ' ' || u.first_name || ' ' || NVL(u.middle_name, ''), '(не назначен)') AS performer_fio,
	t.deadline, ts.status_name
FROM E_Tasks t
LEFT JOIN E_Users u ON t.performer_id = u.id
LEFT JOIN E_Task_states ts ON t.status_id = ts.id
WHERE ts.status_name IN ('Создано', 'В работе')
ORDER BY t.deadline;


-- 4)	Отчет по пользователям, назначенным на проект, но не имеющим ни одной задачи. 
CREATE OR REPLACE VIEW v_report_users_without_tasks AS
SELECT (u.last_name || ' ' || u.first_name || ' ' || NVL(u.middle_name, '')) AS performer_fio, p.name
FROM E_Involvement i
JOIN E_Users u    ON i.user_id = u.id
JOIN E_Project p  ON i.project_id = p.id
WHERE NOT EXISTS (
    SELECT 1
    FROM E_Tasks t
    WHERE t.performer_id = i.user_id
      AND t.project_id   = i.project_id
)
ORDER BY performer_fio, p.name;


-- 5)	Отчет, показывающий топ – 3 исполнителя, имеющих за последний месяц больше всего задач.
CREATE OR REPLACE VIEW v_report_top3_performers AS
SELECT * FROM (
    SELECT 
        u.last_name || ' ' || u.first_name || ' ' || NVL(u.middle_name, '') AS performer_fio,
        TRIM(TO_CHAR(t.created_at, 'Month')) AS month_name,
        TO_CHAR(t.created_at, 'YYYY')        AS year_num,
        COUNT(*)                             AS task_count
    FROM E_Tasks t
    JOIN E_Users u ON t.performer_id = u.id
    WHERE t.created_at >= ADD_MONTHS(SYSDATE, -1)
    GROUP BY u.last_name, u.first_name, u.middle_name,
             TRIM(TO_CHAR(t.created_at, 'Month')),
             TO_CHAR(t.created_at, 'YYYY')
    ORDER BY COUNT(*) DESC
)
WHERE ROWNUM <= 3;



