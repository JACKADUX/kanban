class_name NS_Table

const BaseTable = DBHelper.BaseTable

class Project extends BaseTable:
	const NAME := "project"
	const id := "id"
	const category_id := "category_id"
	const name := "name"
	
	static func create_table(db:SQLite):
		db.create_table(NAME, {
			id: pk(),
			category_id:fk(Category.NAME),
			name:f_text(),
		}.merged(datetime()))
	
	static func new_project(db:SQLite, p_name:String, p_category_id:int):
		var dt = Time.get_datetime_string_from_system(false, true)
		db.query_with_bindings("""
			INSERT INTO %s (%s, %s, %s, %s) VALUES (?, ?, ?, ?)
		"""%[NAME, name, category_id, created_at, updated_at]
		,[p_name, p_category_id, dt, dt]
		)
	
class Category extends BaseTable:
	const NAME := "category"
	const id := "id"
	const parent_id := "parent_id"
	const name := "name"
	
	static func create_table(db:SQLite):
		db.create_table(NAME, {
			id: pk(),
			parent_id:fk(Category.NAME),
			name:f_text(),
		}.merged(datetime()))
	
	static func new_category(db:SQLite, p_name:String):
		var dt = Time.get_datetime_string_from_system(false, true)
		#var db = dbhelper.db
		db.query_with_bindings("""
			INSERT INTO %s (%s, %s, %s) VALUES (?, ?, ?)
		"""%[NAME, name, created_at, updated_at]
		,[p_name, dt, dt]
		)
		
	
class Asset extends BaseTable:
	const NAME := "asset"
	const id := "id"
	const project_id := "project_id"
	const type_id := "type_id"
	const name := "name"
	const data := "data"
	
	static func create_table(db:SQLite):
		db.create_table(NAME, {
			id: pk(),
			project_id:fk(Project.NAME),
			type_id:fk(AssetType.NAME),
			name:f_text(),
			data:f_json(),
		}.merged(datetime()))
		
class AssetType extends BaseTable:
	const NAME := "asset_type"
	const id := "id"
	const type := "type"
	
	static func create_table(db:SQLite):
		db.create_table(NAME, {
			id: pk(),
			type:f_text(),
		})

class FilePath extends BaseTable:
	const NAME := "file_path"
	const id := "id"
	const path := "path"
	
	static func create_table(db:SQLite):
		db.create_table(NAME, {
			id: pk(),
			path:f_text(),
		})
	
class TaskState extends BaseTable:
	const NAME := "task_state"
	const id := "id"
	const state := "state"
	
	static func create_table(db:SQLite):
		db.create_table(NAME, {
			id: pk(),
			state:f_int(),
		})

class TaskType extends BaseTable:
	const NAME := "task_type"
	const id := "id"
	const type := "type"
	
	static func create_table(db:SQLite):
		db.create_table(NAME, {
			id: pk(),
			type:f_int(),
		})

class Task extends BaseTable:
	const NAME := "task"
	const id := "id"
	const project_id := "project_id"
	const type_id := "type_id"
	const state_id := "state_id"
	const data := "data"
	
	static func create_table(db:SQLite):
		db.create_table(NAME, {
			id: pk(),
			project_id:fk(Project.NAME),
			type_id:fk(TaskType.NAME),
			state_id:fk(TaskState.NAME),
			data:f_json(),
		}.merged(datetime()))

class ProjectFilePath extends BaseTable:
	const NAME := "project_file_path"
	const project_id := "project_id"
	const file_path_id := "file_path_id"
	const order_index := "order_index"
	
	static func create_table(db:SQLite):
		db.create_table(NAME, {
			project_id:fk(Project.NAME),
			file_path_id:fk(FilePath.NAME),
			order_index: f_int(),
		})

class AssetFilePath extends BaseTable:
	const NAME := "asset_file_path"
	const asset_id := "asset_id"
	const file_path_id := "file_path_id"
	const order_index := "order_index"
	
	static func create_table(db:SQLite):
		db.create_table(NAME, {
			asset_id:fk(Asset.NAME),
			file_path_id:fk(FilePath.NAME),
			order_index: f_int(),
		})
