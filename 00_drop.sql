DROP VIEW v_tasks_filtered;
DROP VIEW v_report_overdue_tasks;
DROP VIEW v_report_tasks_by_performer;
DROP VIEW v_report_unfinished_tasks;
DROP VIEW v_report_users_without_tasks;
DROP VIEW v_report_top3_performers;

DROP PROCEDURE assign_user_to_project;
DROP PROCEDURE create_task;
DROP PROCEDURE assign_performer;
DROP PROCEDURE change_status;

DROP TRIGGER trg_e_users_id;
DROP TRIGGER trg_e_project_id;
DROP TRIGGER trg_e_involvement_id;
DROP TRIGGER trg_e_tasks_id;
DROP TRIGGER trg_e_tasks_audit_id;
DROP TRIGGER trg_e_logs_id;
DROP TRIGGER trg_e_tasks_audit;
DROP TRIGGER trg_e_tasks_p_im;

DROP TABLE E_Logs CASCADE CONSTRAINTS;
DROP TABLE E_Tasks_Audit CASCADE CONSTRAINTS;
DROP TABLE E_Tasks CASCADE CONSTRAINTS;
DROP TABLE E_Involvement CASCADE CONSTRAINTS;
DROP TABLE E_Task_Type CASCADE CONSTRAINTS;
DROP TABLE E_Task_states CASCADE CONSTRAINTS;
DROP TABLE E_Project CASCADE CONSTRAINTS;
DROP TABLE E_Users CASCADE CONSTRAINTS;

DROP SEQUENCE seq_e_users;
DROP SEQUENCE seq_e_project;
DROP SEQUENCE seq_e_involvement;
DROP SEQUENCE seq_e_tasks;
DROP SEQUENCE seq_e_tasks_audit;
DROP SEQUENCE seq_e_logs;