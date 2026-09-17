-- Функция, возвращающая список задач по фильтру и п.5 Пользователь может видеть задачи только тех проектов,
--    в которых состоит.
CREATE OR REPLACE FUNCTION get_tasks_by_filter (
	p_user_id      IN NUMBER, 
    p_project_id   IN NUMBER DEFAULT NULL,
    p_performer_id IN NUMBER DEFAULT NULL,
    p_status_id    IN NUMBER DEFAULT NULL
) RETURN SYS_REFCURSOR IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT 
            t.id,
            t.title,
            t.deadline,
            t.created_at,
            u.last_name    AS performer_name,
            s.status_name,
            p.name         AS project_name
        FROM E_Tasks t
        LEFT JOIN E_Users u        ON t.performer_id = u.id
        LEFT JOIN E_Task_states s  ON t.status_id = s.id
        LEFT JOIN E_Project p      ON t.project_id = p.id
        WHERE t.project_id IN (
                  SELECT project_id
                  FROM E_Involvement
                  WHERE user_id = p_user_id
              )
          AND (p_project_id   IS NULL OR t.project_id   = p_project_id)
          AND (p_performer_id IS NULL OR t.performer_id = p_performer_id)
          AND (p_status_id    IS NULL OR t.status_id    = p_status_id)
        ORDER BY t.id;
    
    RETURN v_cursor;
END;


CREATE OR REPLACE VIEW v_tasks_filtered AS
SELECT 
    t.id,
    t.title,
    t.deadline,
    t.created_at,
    t.performer_id,
    t.status_id,
    t.project_id,
    u.last_name    AS performer_name,
    s.status_name,
    p.name         AS project_name
FROM E_Tasks t
LEFT JOIN E_Users u       ON t.performer_id = u.id
LEFT JOIN E_Task_states s ON t.status_id = s.id
LEFT JOIN E_Project p     ON t.project_id = p.id;

SELECT * FROM v_tasks_filtered;
SELECT * FROM v_tasks_filtered WHERE project_id = 1;
SELECT * FROM v_tasks_filtered WHERE status_id = 2;
SELECT * FROM v_tasks_filtered WHERE performer_id = 3;

