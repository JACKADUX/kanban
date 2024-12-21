class_name DBHelper


	
static func pk():
	return {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true, "unique": true}
static func fk(table: String, field: String = "id", data_type := "int") -> Dictionary:
	return {"data_type": data_type, "foreign_key": table + "." + field}
static func f_text(not_null:=false):
	return {"data_type": "text", "not_null": not_null}
static func f_int(not_null:=false):
	return {"data_type": "int", "not_null": true}
static func f_bool(not_null:=false):
	return {"data_type": "int", "not_null": true}
static func f_date():
	return {"data_type": "text", "not_null": true}
static func f_json():
	return {"data_type": "text"}

const id = "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
const created_at = "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
const updated_at = "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,"
const foreign_key = "FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE"

const trigger_updated_at := """
			CREATE TRIGGER IF NOT EXISTS trigger_{table}_updated_at AFTER UPDATE ON {table}
			BEGIN
				UPDATE {table} SET updated_at = CURRENT_TIMESTAMP WHERE rowid == NEW.rowid;
			END
		"""#.format({"table":"NAME"})

func create_table(db):
	db.query("""
		CREATE TABLE IF NOT EXISTS %s (
			id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
			card_id INTEGER,
			name TEXT NOT NULL,
			position INTEGER,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			FOREIGN KEY (card_id) REFERENCES %s(id) ON DELETE CASCADE
		);
	"""%["table_name", "fk_table_name"])


static func print_result(db):
	for d in db.query_result:
		print(d.values())

func show_all(db, table:String):
	db.query("""
		SELECT * FROM %s
	"""%table)
	for d in db.query_result:
		print(d.values())

func print_all_table_names(db):
	db.query("""
		SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'; 
	""")
	print(db.query_result)
