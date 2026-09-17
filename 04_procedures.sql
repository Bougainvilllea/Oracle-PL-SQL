--2)	Процедура назначения исполнителя на проект.
CREATE OR REPLACE PROCEDURE assign_user_to_project (
	p_user_id    IN NUMBER,
    p_project_id IN NUMBER 
    ) IS
    	v_count NUMBER;
		v_log_text  VARCHAR2(4000);
	BEGIN
		SELECT COUNT(*) INTO v_count
		FROM E_Involvement
		WHERE user_id = p_user_id AND project_id = p_project_id;
		
		IF v_count > 0 THEN
			RAISE_APPLICATION_ERROR(-20003, 'Пользователь ' || TO_CHAR(p_user_id) || ' уже состоит в проекте ' || TO_CHAR(p_project_id));
		END IF;
		
		INSERT INTO E_Involvement (user_id, project_id)
		VALUES (p_user_id, p_project_id);
		
		v_log_text := 'User ' || TO_CHAR(p_user_id) || ' add Project ' || TO_CHAR(p_project_id);
		
		INSERT INTO E_Logs (method_name, log_date, error_text)
		VALUES ('assign_user_to_project', SYSDATE, v_log_text);
		
		COMMIT;
	
	EXCEPTION 
		WHEN OTHERS THEN
			v_log_text := SUBSTR(SQLERRM, 1, 4000);
		
			INSERT INTO E_Logs (method_name, log_date, error_text)
        	VALUES ('assign_user_to_project', SYSDATE, v_log_text);
        	COMMIT;
        	RAISE;
	END;
	
	
--1)	Процедура для создания задачи.
CREATE OR REPLACE PROCEDURE create_task (
	p_title        IN VARCHAR2,
    p_author_id    IN NUMBER,
    p_project_id   IN NUMBER,
    p_type_id      IN NUMBER,
    p_deadline     IN DATE DEFAULT NULL,
    p_performer_id IN NUMBER DEFAULT NULL,
    p_task_id      OUT NUMBER
    ) IS
    	v_count NUMBER;
		v_status_id NUMBER;
		v_log_text  VARCHAR2(4000);
	BEGIN
		SELECT id INTO v_status_id
		FROM E_Task_states
    	WHERE status_name = 'Создано';
		
		SELECT COUNT(*) INTO v_count
		FROM E_Involvement
		WHERE user_id = p_author_id AND project_id = p_project_id;
		
		IF v_count = 0 THEN
			RAISE_APPLICATION_ERROR(-20003, 'Автор ' || TO_CHAR(p_author_id) || ' не состоит в проекте ' || TO_CHAR(p_project_id));
		END IF;
		
		IF p_performer_id IS NOT NULL THEN
			SELECT COUNT(*) INTO v_count
			FROM E_Involvement
			WHERE user_id = p_performer_id AND project_id = p_project_id;
		END IF;
		
		IF v_count = 0 THEN
			RAISE_APPLICATION_ERROR(-20003, 'Исполнитель ' || TO_CHAR(p_performer_id) || ' не состоит в проекте ' || TO_CHAR(p_project_id));
		END IF;
		
		INSERT INTO E_Tasks (title, performer_id, author_id, deadline, status_id, type_id, project_id, created_at)
		VALUES (p_title, p_performer_id, p_author_id, p_deadline, v_status_id, p_type_id, p_project_id, SYSDATE)
		RETURNING id INTO p_task_id;
		
		INSERT INTO E_Logs (method_name, log_date, error_text)
		VALUES ('create_task', SYSDATE, 'Created task ID=' || p_task_id || ', title=' || p_title);
		
		COMMIT;
		
		EXCEPTION 
			WHEN NO_DATA_FOUND THEN
				INSERT INTO E_Logs (method_name, log_date, error_text)
				VALUES ('create_task', SYSDATE, 'Status "Создано" not found');
	        	COMMIT;
	        	RAISE;
		
			WHEN OTHERS THEN
				v_log_text := SUBSTR(SQLERRM, 1, 4000);
				INSERT INTO E_Logs (method_name, log_date, error_text)
	        	VALUES ('create_task', SYSDATE, v_log_text);
	        	COMMIT;
	        	RAISE;
			
	END;
	
--3)	Процедура назначения исполнителя на задачу.	
CREATE OR REPLACE PROCEDURE assign_performer (
    p_task_id      IN NUMBER,
    p_performer_id IN NUMBER
) IS
    v_current_perf NUMBER;
    v_project_id   NUMBER;
    v_count        NUMBER;
	v_log_text  VARCHAR2(4000);
BEGIN
    SELECT performer_id, project_id
    INTO v_current_perf, v_project_id
    FROM E_Tasks
    WHERE id = p_task_id
    FOR UPDATE;
    
    IF v_current_perf IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20004, 
            'Исполнитель уже назначен (ID=' || v_current_perf || 
            '). Смена запрещена.');
    END IF;
    
    SELECT COUNT(*) INTO v_count
    FROM E_Involvement
    WHERE user_id = p_performer_id
      AND project_id = v_project_id;
    
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 
            'Исполнитель ID=' || p_performer_id || 
            ' не состоит в проекте ID=' || v_project_id);
    END IF;
    
    UPDATE E_Tasks
    SET performer_id = p_performer_id
    WHERE id = p_task_id;
    
    INSERT INTO E_Logs (method_name, log_date, error_text)
    VALUES ('assign_performer', SYSDATE,
            'Task ' || p_task_id || ' add Performer ' || p_performer_id);
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO E_Logs (method_name, log_date, error_text)
        VALUES ('assign_performer', SYSDATE, 'Task ID=' || p_task_id || ' not found');
        COMMIT;
        RAISE;
    WHEN OTHERS THEN
    	ROLLBACK; 
    	v_log_text := SUBSTR(SQLERRM, 1, 4000);
        INSERT INTO E_Logs (method_name, log_date, error_text)
        VALUES ('assign_performer', SYSDATE, v_log_text);
        COMMIT;
        RAISE;
END;	
	
--4)	Процедура смены статуса задачи.
CREATE OR REPLACE PROCEDURE change_status (
    p_task_id    IN NUMBER,
    p_new_status IN NUMBER
) IS
    v_old_status NUMBER;
    v_old_order  NUMBER;
    v_new_order  NUMBER;
    v_old_name   VARCHAR2(255);
    v_new_name   VARCHAR2(255);
	v_log_text  VARCHAR2(4000);
BEGIN
    SELECT status_id INTO v_old_status
    FROM E_Tasks
    WHERE id = p_task_id
    FOR UPDATE;
    
    SELECT sort_order, status_name INTO v_old_order, v_old_name
    FROM E_Task_states WHERE id = v_old_status;
    
    SELECT sort_order, status_name INTO v_new_order, v_new_name
    FROM E_Task_states WHERE id = p_new_status;
    
    IF v_old_order = 6 THEN
        RAISE_APPLICATION_ERROR(-20010, 
            'Статус "Перенесено в продакшен" конечный. Переход невозможен.');
    END IF;
    
    IF v_new_order = 1 THEN
        RAISE_APPLICATION_ERROR(-20011, 
            'Возврат в статус "Создано" запрещен.');
    END IF;
    
    IF ABS(v_new_order - v_old_order) > 1 THEN
        RAISE_APPLICATION_ERROR(-20012, 
            'Недопустимый переход: ' || v_old_name || ' -> ' || v_new_name || 
            '. Разрешен только на один шаг.');
    END IF;
    
    UPDATE E_Tasks SET status_id = p_new_status WHERE id = p_task_id;
    
    INSERT INTO E_Logs (method_name, log_date, error_text)
    VALUES ('change_status', SYSDATE,
            'Task ' || p_task_id || ': ' || v_old_name || ' -> ' || v_new_name);
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO E_Logs (method_name, log_date, error_text)
        VALUES ('change_status', SYSDATE, 
                'Task ID=' || p_task_id || ' or status not found');
        COMMIT;
        RAISE;
    WHEN OTHERS THEN
    	ROLLBACK; 
    	v_log_text := SUBSTR(SQLERRM, 1, 4000);
        INSERT INTO E_Logs (method_name, log_date, error_text)
        VALUES ('change_status', SYSDATE, v_log_text);
        COMMIT;
        RAISE;
END;

