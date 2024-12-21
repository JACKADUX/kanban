extends Control
# https://github.com/2shady4u/godot-sqlite
var db = SQLite.new()

var f_text = {"data_type": "text", "not_null": true}
var f_int = {"data_type": "int"}

const t_project_type := "project_type"
const t_project := "project"
const t_category := "category"



func _ready():
	db.path = "res://my_database"
	db.foreign_keys = true
	#db.verbosity_level = 0
	#for i in range(10):
		#add_one("name%d"%i, "xxx%d@qq.com"%i, randi_range(5, 56))
	
	db.open_db()
	db.insert_row("category",{
		"name": "新项目",
		"order_index":1,
	})
	
	#db.insert_row("project", {
		#"name": "定制影集",
		#"project_type_id":1,
		#"category_id":1,
	#})
	db.query_with_bindings("""
		INSERT INTO project (name, project_type_id, category_id)
		VALUES (?, 1, last_insert_rowid())
	""",
	["定制影集"]
	)
	
func open_with(fn:Callable):
	db.open_db()
	fn.call()
	db.close_db()

func add_one(p_name:String, email:String, age:int):
	
	#db.query_with_bindings("""
		#INSERT INTO customers VALUES (?,?,?,?,?)
	#""", [null, null, p_name, email, age])
	db.open_db()
	db.insert_row("customers",{
		"name":p_name,
		"email":email,
		"age":age,
	})
	db.close_db()
	
func delete(id:int):
	db.open_db()
	db.query_with_bindings("""
		DELETE FROM customers WHERE id = ?
	""",
	[id]
	)
	db.close_db()

func test_base():
	pass
	## create table
	#db.query("""
		#CREATE TABLE customers (
			#first_name text,
			#last_name text,
			#email text
		#)
	#""")

	#db.create_table(t_project, {
		#"id": pk(),
		#"category_id":fk(t_category),
		#"project_type_id":fk(t_project_type),
		#"name":f_text
	#})

	##db.drop_table(t_category)
	#db.create_table(t_category, {
		#"id": pk(),
		#"parent_id":fk(t_category),
		#"name":f_text,
		#"order_index":f_int,
	#})

	## insert data
	#db.query("""
	#INSERT INTO customers VALUES ('jack', 'adux', '1505@qq.com')
	#""")
	#db.insert_row("customers", {
		#"first_name": "enam",
		#"email":"123@ww.com"
	#})
	
	## binds
	#db.query_with_bindings("""
		#INSERT INTO customers VALUES (?,?,?)
	#""",
	#["A", "B", "5"]
	#)
	
	## select
	#db.query("""
		#SELECT * FROM customers
	#""")
	#print(db.query_result)
	#
	
	## where
	#db.query("""
		#SELECT * FROM customers WHERE first_name = 'jack'
	#""")
	#db.query("""
		#SELECT * FROM customers WHERE first_name LIKE 'J%'
	#""")
	#print(db.query_result)
	
	## update
	#db.query("""
		#UPDATE customers SET first_name = 'bob'
		#WHERE last_name = 'adux'
	#""")
	
	## delete
	#db.query("""
		#DELETE FROM customers WHERE first_name = 'John'
	#""")
	
	## order  -- DESC 倒叙
	#db.query("""
		#SELECT rowid,* FROM customers ORDER BY rowid DESC
	#""")
	
	## and / or
	#db.query("""
		#SELECT rowid,* FROM customers  
		#WHERE last_name LIKE 'E%' AND rowid = 4
	#""")
	
	## limit 
	#db.query("""
		#SELECT * FROM customers  
		#LIMIT 2
	#""")
	
	## drop table
	#db.query("""
		#DROP TABLE customers
	#""")
	
	#db.query("""
		#CREATE TABLE customers (
			#id INTEGER NOT NULL UNIQUE, 
			#manager_id int, 
			#name text,
			#email text,
			#age int,
			#PRIMARY KEY("id" AUTOINCREMENT),
			#FOREIGN KEY("manager_id") REFERENCES "customers"("id")
		#)
	#""")
	
func show_all():
	## print
	db.query("""
		SELECT * FROM customers
	""")
	for d in db.query_result:
		print(d.values())
	
	##
	#for i in range(10):
		#db.insert_row(t_project, {
			#"name":"project_name%d"%i,
			#"category_id":
		#})
		#db.insert_row(t_category, {
			#"parent_id": null,
			#"name":"test_project_name%d"%i,
			#"order_index":i
		#})
		
func create_project_type():
	db.drop_table(t_project_type)
	db.create_table(t_project_type, {
		"id": pk(),
		"type": f_text,
	})
	for i in ["IMAGESETS"]:
		db.insert_row(t_project_type, {
			"type": i,
		})
