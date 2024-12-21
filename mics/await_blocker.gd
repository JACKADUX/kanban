class_name AwaitBloker

# NOTE: 用来作为 await 信号的中继器
signal continued

#var blocker = AwaitBloker.new()
#WorkerThreadPool.add_task(func():
	# havey_task()
	# blocker.go_on_deferred()  # 否则多线程会报错
#)
#await blocker.continued

func go_on_deferred():
	continued.emit.call_deferred()


	
