#class_name DBManager

var app_user: AppUser
var board: Board
var list: List
var card: Card
var checklist_item: ChecklistItem

var db := SQLite.new()
var user_id: int = 0

func _init(path: String) -> void:
	db.path = path
	db.foreign_keys = true
	db.open_db()
	
	app_user = AppUser.new(db)
	board = Board.new(db)
	list = List.new(db)
	card = Card.new(db)
	checklist_item = ChecklistItem.new(db)

	
func test_loop():
	# WARNING : query 的调用比较消耗性能，所以尽量避免在for循环中调用，推荐直接使用等效的SQL语法
	var dt = Time.get_ticks_msec()
	for i in range(100): # 7313 ms
		db.query_with_bindings("""
			INSERT INTO test (name, value) VALUES (?, ?)
		""", ["TEST%d"%i, i])
	
	var qu = "INSERT INTO test (name, value) VALUES "
	for i in range(100): # 84 ms
		qu += "('%s', '%d')," % ["TEST%d"%i, i]
	db.query(qu.rstrip(","))
	print(Time.get_ticks_msec() - dt)

## -------------------------------------------------------------------------------------------------
class BaseTable:
	var db: SQLite
	func _init(p_db: SQLite):
		db = p_db
		
class AppUser extends BaseTable:
	const NAME := "app_user"
	
	func _init(p_db: SQLite):
		super(p_db)
		#db.drop_table("app_user")
		db.query("""
			CREATE TABLE IF NOT EXISTS %s(
				id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				username TEXT NOT NULL,
				is_active INTEGER,
				created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
			);
		""" % [NAME])
		
	func has_user(username: String) -> bool:
		db.query_with_bindings("""
			SELECT username FROM app_user WHERE username = (?)
		""", [username])
		return not db.query_result.is_empty()
			
	func create_user(username: String):
		if has_user(username):
			print("用户名已存在")
			return
		db.query_with_bindings("""
			INSERT INTO app_user (username, is_active) VALUES (?,0)
		""", [username, 0])
	
	func get_user_id(username: String) -> int:
		db.query_with_bindings("""
			SELECT id FROM app_user WHERE username = (?)
		""", [username])
		if not db.query_result:
			return 0
		return db.query_result[0].id
	
	func set_active_user(username: String):
		var user_id = get_user_id(username)
		assert(user_id, "username 无效")
		db.query_with_bindings("""
			UPDATE app_user SET is_active = 0;
			UPDATE app_user SET is_active = 1 WHERE id = (?);
		""", [user_id])
	
class Board extends BaseTable:
	const NAME := "board"
	
	func _init(p_db: SQLite):
		super(p_db)
		db.query("""
			CREATE TABLE IF NOT EXISTS %s (
				id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				user_id INTEGER,
				name TEXT NOT NULL,
				created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
				FOREIGN KEY (user_id) REFERENCES %s (id) ON DELETE CASCADE
			);
		""" % [NAME, AppUser.NAME])
		
	func new_board(user_id: int, p_name: String) -> Dictionary:
		if not p_name:
			return {}
		db.query_with_bindings("""
			INSERT INTO board (user_id, name) VALUES (?,?);
			SELECT id FROM board WHERE rowid = last_insert_rowid();
		""", [user_id, p_name])
		return db.query_result[0]
	
	func get_board_data(board_id: int) -> Dictionary:
		db.query("""
			SELECT id, name FROM board WHERE id =%d
		"""%board_id)
		return db.query_result[0]
	

	func get_all_board_data(user_id: int) -> Array:
		db.query("""
			SELECT id, name FROM board WHERE user_id =%d
			ORDER BY created_at ASC
		"""%user_id)
		return db.query_result
	
	func set_name(board_id: int, p_name: String):
		db.query_with_bindings("""
			UPDATE board SET name = (?) WHERE id = (?)
		""", [p_name, board_id])
		
class List extends BaseTable:
	const NAME := "list"
	
	func _init(p_db: SQLite):
		super(p_db)
		db.query("""
			CREATE TABLE IF NOT EXISTS %s (
				id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				board_id INTEGER,
				name TEXT NOT NULL,
				position INTEGER,
				FOREIGN KEY (board_id) REFERENCES %s (id) ON DELETE CASCADE
			);
		""" % [NAME, Board.NAME])
	
	func new_list(board_id: int, p_name: String, position: int = 0) -> Dictionary:
		if not p_name:
			return {}
		db.query_with_bindings("""
			INSERT INTO list (board_id, name, position) VALUES (?,?,?);
			SELECT id FROM list WHERE rowid = last_insert_rowid();
		""", [board_id, p_name, position])
		return db.query_result[0]
	
	func get_list_data(list_id: int) -> Dictionary:
		db.query("""
			SELECT * FROM list WHERE id =%d
		"""%list_id)
		if not db.query_result:
			return {}
		return db.query_result[0]
		
	func get_all_list_data(board_id: int) -> Array:
		db.query("""
			SELECT * FROM list WHERE board_id =%d
			ORDER BY position ASC
		"""%board_id)
		return db.query_result
	
	func delete_list(list_id: int):
		return db.query_with_bindings("""
			DELETE FROM list WHERE id = (?);
		""", [list_id])
	
	func set_name(list_id: int, p_name: String):
		db.query_with_bindings("""
			UPDATE list SET name = (?) WHERE id = (?)
		""", [p_name, list_id])
	
	func update_order(ordered_ids: Array):
		var case_str = ""
		var ids_str = ",".join(ordered_ids)
		for index in ordered_ids.size():
			var id = ordered_ids[index]
			case_str += "WHEN %d THEN %d\n" % [id, index]
		db.query("""
			BEGIN TRANSACTION;
			UPDATE list
			SET position = CASE id
				%s -- WHEN 1 THEN 3
			END
			WHERE id IN (%s);
			COMMIT;
		""" % [case_str, ids_str])
	
class Card extends BaseTable:
	const NAME := "card"
	
	func _init(p_db: SQLite):
		super(p_db)
		db.query(""" 
			CREATE TABLE IF NOT EXISTS %s (
				id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				list_id INTEGER,
				name TEXT NOT NULL,
				position INTEGER,
				FOREIGN KEY (list_id) REFERENCES %s (id) ON DELETE CASCADE
			);
		""" % [NAME, List.NAME])
	
	func new_card(list_id: int, p_name: String, position: int = 0) -> Dictionary:
		if not p_name:
			return {}
		db.query_with_bindings("""
			INSERT INTO card (list_id, name, position) VALUES (?,?,?);
			SELECT id FROM card WHERE rowid = last_insert_rowid();
		""", [list_id, p_name, position])
		return db.query_result[0]
	
	func get_all_card_data(list_id: int) -> Array:
		db.query("""
			SELECT * FROM card WHERE list_id =%d
			ORDER BY position ASC
		"""%list_id)
		return db.query_result
	
	func get_card_data(card_id: int) -> Dictionary:
		db.query("""
			SELECT * FROM card WHERE id =%d
		"""%card_id)
		if not db.query_result:
			return {}
		return db.query_result[0]
	
	func delete_card(card_id: int):
		return db.query_with_bindings("""
			DELETE FROM card WHERE id = (?);
		""", [card_id])
	
	func set_name(card_id: int, p_name: String):
		db.query_with_bindings("""
			UPDATE card SET name = (?) WHERE id = (?)
		""", [p_name, card_id])
	
class ChecklistItem extends BaseTable:
	const NAME := "checklist_item"
	
	func _init(p_db: SQLite):
		super(p_db)
		db.query("""
			CREATE TABLE IF NOT EXISTS %s (
				id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				card_id INTEGER,
				name TEXT NOT NULL,
				position INTEGER,
				is_checked INTEGER,
				created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
				updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
				FOREIGN KEY (card_id) REFERENCES %s (id) ON DELETE CASCADE
			);
		""" % [NAME, Card.NAME])
		db.query(DBHelper.trigger_updated_at.format({"table": NAME}))
