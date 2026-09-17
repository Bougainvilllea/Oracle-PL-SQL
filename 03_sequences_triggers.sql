CREATE SEQUENCE seq_e_users        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_e_project      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_e_involvement  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_e_tasks        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_e_tasks_audit  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_e_logs         START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_e_users_id
BEFORE INSERT ON E_Users
FOR EACH ROW

BEGIN
	IF :NEW.id IS NULL THEN
		SELECT seq_e_users.NEXTVAL INTO :NEW.id FROM dual;
	END IF;
END;


CREATE OR REPLACE TRIGGER trg_e_project_id
BEFORE INSERT ON E_Project
FOR EACH ROW

BEGIN
	IF :NEW.id IS NULL THEN
		SELECT seq_e_project.NEXTVAL INTO :NEW.id FROM dual;
	END IF;
END;


CREATE OR REPLACE TRIGGER trg_e_involvement_id
BEFORE INSERT ON E_Involvement
FOR EACH ROW

BEGIN
	IF :NEW.id IS NULL THEN
		SELECT seq_e_involvement.NEXTVAL INTO :NEW.id FROM dual;
	END IF;
END;


CREATE OR REPLACE TRIGGER trg_e_tasks_id
BEFORE INSERT ON E_Tasks
FOR EACH ROW

BEGIN
	IF :NEW.id IS NULL THEN
		SELECT seq_e_tasks.NEXTVAL INTO :NEW.id FROM dual;
	END IF;
END;


CREATE OR REPLACE TRIGGER trg_e_tasks_audit_id
BEFORE INSERT ON E_Tasks_Audit
FOR EACH ROW

BEGIN
	IF :NEW.id IS NULL THEN
		SELECT seq_e_tasks_audit.NEXTVAL INTO :NEW.id FROM dual;
	END IF;
END;


CREATE OR REPLACE TRIGGER trg_e_logs_id
BEFORE INSERT ON E_Logs
FOR EACH ROW

BEGIN
	IF :NEW.id IS NULL THEN
		SELECT seq_e_logs.NEXTVAL INTO :NEW.id FROM dual;
	END IF;
END;

-- триггер на изменение
CREATE OR REPLACE TRIGGER trg_e_tasks_audit
AFTER UPDATE ON E_Tasks
FOR EACH ROW
DECLARE
    v_user VARCHAR2(100);
	v_now  DATE;
BEGIN
	v_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
	v_now := SYSDATE;

	IF (:OLD.title IS NULL AND :NEW.title IS NOT NULL)
		OR (:OLD.title IS NOT NULL AND :NEW.title IS NULL)
		OR (:OLD.title != :NEW.title) THEN 
		INSERT INTO E_Tasks_Audit (task_id, db_user, field_name, old_value, new_value, date_of_change)
		VALUES (:OLD.id, v_user, 'title', :OLD.title, :NEW.title, v_now);
	END IF;
		
	IF (:OLD.performer_id IS NULL AND :NEW.performer_id IS NOT NULL)
		OR (:OLD.performer_id IS NOT NULL AND :NEW.performer_id IS NULL)
		OR (:OLD.performer_id != :NEW.performer_id) THEN 
		INSERT INTO E_Tasks_Audit (task_id, db_user, field_name, old_value, new_value, date_of_change)
		VALUES (:OLD.id, v_user, 'performer_id', TO_CHAR(:OLD.performer_id), TO_CHAR(:NEW.performer_id), v_now);
	END IF;
	
	IF (:OLD.deadline IS NULL AND :NEW.deadline IS NOT NULL)
		OR (:OLD.deadline IS NOT NULL AND :NEW.deadline IS NULL)
		OR (:OLD.deadline != :NEW.deadline) THEN 
		INSERT INTO E_Tasks_Audit (task_id, db_user, field_name, old_value, new_value, date_of_change)
		VALUES (:OLD.id, v_user, 'deadline', TO_CHAR(:OLD.deadline, 'YYYY-MM-DD HH24:MI:SS'), TO_CHAR(:NEW.deadline, 'YYYY-MM-DD HH24:MI:SS'), v_now);
	END IF;
	
	IF (:OLD.status_id IS NULL AND :NEW.status_id IS NOT NULL)
		OR (:OLD.status_id IS NOT NULL AND :NEW.status_id IS NULL)
		OR (:OLD.status_id != :NEW.status_id) THEN 
		INSERT INTO E_Tasks_Audit (task_id, db_user, field_name, old_value, new_value, date_of_change)
		VALUES (:OLD.id, v_user, 'status_id', TO_CHAR(:OLD.status_id), TO_CHAR(:NEW.status_id), v_now);
	END IF;
	
	IF (:OLD.type_id IS NULL AND :NEW.type_id IS NOT NULL)
		OR (:OLD.type_id IS NOT NULL AND :NEW.type_id IS NULL)
		OR (:OLD.type_id != :NEW.type_id) THEN 
		INSERT INTO E_Tasks_Audit (task_id, db_user, field_name, old_value, new_value, date_of_change)
		VALUES (:OLD.id, v_user, 'type_id', TO_CHAR(:OLD.type_id), TO_CHAR(:NEW.type_id), v_now);
	END IF;
	
	IF (:OLD.project_id IS NULL AND :NEW.project_id IS NOT NULL)
		OR (:OLD.project_id IS NOT NULL AND :NEW.project_id IS NULL)
		OR (:OLD.project_id != :NEW.project_id) THEN 
		INSERT INTO E_Tasks_Audit (task_id, db_user, field_name, old_value, new_value, date_of_change)
		VALUES (:OLD.id, v_user, 'project_id', TO_CHAR(:OLD.project_id), TO_CHAR(:NEW.project_id), v_now);
	END IF;
END;

-- триггер на смену исполнителя
CREATE OR REPLACE TRIGGER trg_e_tasks_p_im
BEFORE UPDATE OF performer_id ON E_Tasks
FOR EACH ROW
BEGIN
	IF :OLD.performer_id IS NOT NULL
		AND (:NEW.performer_id IS NULL OR :NEW.performer_id != :OLD.performer_id)
	THEN 
		RAISE_APPLICATION_ERROR(-20001, 'Смена исполнителя запрещена.');
	END IF;
	
END;

-- триггер на вставку
CREATE OR REPLACE TRIGGER trg_e_tasks_audit_ins
AFTER INSERT ON E_Tasks
FOR EACH ROW
BEGIN
    INSERT INTO E_Tasks_Audit (task_id, db_user, field_name, old_value, new_value, date_of_change)
    VALUES (:NEW.id, SYS_CONTEXT('USERENV', 'SESSION_USER'), 'INSERT', 
            NULL, 
            'title=' || :NEW.title || ', project_id=' || :NEW.project_id, 
            SYSDATE);
END;

-- триггер на удаление
CREATE OR REPLACE TRIGGER trg_e_tasks_audit_del
AFTER DELETE ON E_Tasks
FOR EACH ROW
BEGIN
    INSERT INTO E_Tasks_Audit (task_id, db_user, field_name, old_value, new_value, date_of_change)
    VALUES (:OLD.id, SYS_CONTEXT('USERENV', 'SESSION_USER'), 'DELETE', 
            'title=' || :OLD.title || ', project_id=' || :OLD.project_id, 
            NULL, 
            SYSDATE);
END;

