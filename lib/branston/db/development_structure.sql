CREATE TABLE "iterations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "velocity" integer, "name" varchar(255), "start_date" datetime, "end_date" datetime, "created_at" datetime, "updated_at" datetime, "release_id" integer);
CREATE TABLE "outcomes" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "description" varchar(255), "scenario_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "participations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "iteration_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "preconditions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "description" varchar(255), "scenario_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "releases" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "release_date" date, "notes" text, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "scenarios" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "story_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "stories" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "description" text, "points" integer, "iteration_id" integer, "created_at" datetime, "updated_at" datetime, "author_id" integer, "title" varchar(40));
CREATE TABLE "user_roles" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "created_at" datetime, "updated_at" datetime, "story_id" integer);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "login" varchar(40), "name" varchar(100) DEFAULT '', "email" varchar(100), "crypted_password" varchar(40), "salt" varchar(40), "created_at" datetime, "updated_at" datetime, "remember_token" varchar(40), "remember_token_expires_at" datetime);
CREATE UNIQUE INDEX "index_users_on_login" ON "users" ("login");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20091127114237');

INSERT INTO schema_migrations (version) VALUES ('20091127120627');

INSERT INTO schema_migrations (version) VALUES ('20091127122422');

INSERT INTO schema_migrations (version) VALUES ('20091127144645');

INSERT INTO schema_migrations (version) VALUES ('20091127131037');

INSERT INTO schema_migrations (version) VALUES ('20091127164217');

INSERT INTO schema_migrations (version) VALUES ('20091127164446');

INSERT INTO schema_migrations (version) VALUES ('20091127164705');

INSERT INTO schema_migrations (version) VALUES ('20091127172950');

INSERT INTO schema_migrations (version) VALUES ('20091127173744');

INSERT INTO schema_migrations (version) VALUES ('20091127172849');

INSERT INTO schema_migrations (version) VALUES ('20091202105555');