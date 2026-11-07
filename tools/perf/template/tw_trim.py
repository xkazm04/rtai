"""Applies the perf L9 transfer-worker staging trim to a Godot 4.7.2 tree (cwd)."""
p = 'servers/rendering/rendering_device.h'
s = open(p, encoding='utf-8').read()
a = "\t\tbool submitted = false;\n\t\tBinaryMutex thread_mutex;"
assert a in s
s = s.replace(a, "\t\tbool submitted = false;\n\t\tuint64_t submitted_frame = 0; // gtai perf L9: the frame of the last submit\n\t\tBinaryMutex thread_mutex;", 1)
a = "\tuint32_t transfer_worker_pool_max_size = 1;\n"
assert a in s
s = s.replace(a, a + "\tuint32_t transfer_worker_trim_bytes = 0; // gtai perf L9: free an idle worker's staging buffer above this (0 = never)\n"
              "\tbool transfer_worker_log = false; // gtai perf L9: GTAI_TW_LOG=1 prints staging allocations and trims\n", 1)
open(p, 'w', encoding='utf-8', newline='').write(s)

p = 'servers/rendering/rendering_device.cpp'
s = open(p, encoding='utf-8').read()
a = "\t\t\ttransfer_worker->staging_buffer = driver->buffer_create(new_staging_buffer_size, RDD::BUFFER_USAGE_TRANSFER_FROM_BIT, RDD::MEMORY_ALLOCATION_TYPE_CPU, frames_drawn);\n"
assert a in s
s = s.replace(a, a + "\t\t\tif (transfer_worker_log) {\n"
              "\t\t\t\tprint_line(vformat(\"gtai-tw: alloc worker %d %d KB (pool %d)\", transfer_worker->index, new_staging_buffer_size >> 10, transfer_worker_pool_size));\n"
              "\t\t\t}\n", 1)
a = "\tp_transfer_worker->submitted = true;\n"
assert a in s
s = s.replace(a, a + "\tp_transfer_worker->submitted_frame = frames_drawn;\n", 1)
a = ("\tfor (uint32_t i = 0; i < transfer_worker_pool_size; i++) {\n"
     "\t\tTransferWorker *worker = transfer_worker_pool[i];\n"
     "\t\tif (p_draw_command_buffer) {\n"
     "\t\t\tMutexLock lock(worker->operations_mutex);")
assert a in s
b = ("\tfor (uint32_t i = 0; i < transfer_worker_pool_size; i++) {\n"
     "\t\tTransferWorker *worker = transfer_worker_pool[i];\n"
     "\t\tif (p_draw_command_buffer && transfer_worker_trim_bytes > 0) {\n"
     "\t\t\t// gtai perf L9: a worker's CPU staging buffer only ever grows (the next power of two of the largest\n"
     "\t\t\t// upload it took) and lives until shutdown. Free it once the worker is idle and its last submit is\n"
     "\t\t\t// older than the frame ring (the GPU has consumed it); the next upload re-creates it.\n"
     "\t\t\tMutexLock trim_lock(worker->thread_mutex);\n"
     "\t\t\tif (!worker->recording && worker->staging_buffer_size_allocated > transfer_worker_trim_bytes && (!worker->submitted || frames_drawn > worker->submitted_frame + frames.size())) {\n"
     "\t\t\t\tif (worker->submitted) {\n"
     "\t\t\t\t\t_wait_for_transfer_worker(worker);\n"
     "\t\t\t\t}\n"
     "\t\t\t\tif (transfer_worker_log) {\n"
     "\t\t\t\t\tprint_line(vformat(\"gtai-tw: trim worker %d %d KB\", worker->index, worker->staging_buffer_size_allocated >> 10));\n"
     "\t\t\t\t}\n"
     "\t\t\t\tdriver->buffer_free(worker->staging_buffer);\n"
     "\t\t\t\tworker->staging_buffer = RDD::BufferID();\n"
     "\t\t\t\tworker->staging_buffer_size_allocated = 0;\n"
     "\t\t\t\tworker->max_transfer_size = 0;\n"
     "\t\t\t}\n"
     "\t\t}\n"
     "\t\tif (p_draw_command_buffer) {\n"
     "\t\t\tMutexLock lock(worker->operations_mutex);")
s = s.replace(a, b, 1)
a = "\ttransfer_worker_pool_max_size = OS::get_singleton()->get_processor_count();\n"
assert a in s
s = s.replace(a, a + "\t{\n"
              "\t\t// gtai perf L9: GTAI_TW_TRIM_MB (default 4; 0 = the stock behaviour) and GTAI_TW_LOG=1.\n"
              "\t\tString trim_mb = OS::get_singleton()->get_environment(\"GTAI_TW_TRIM_MB\");\n"
              "\t\ttransfer_worker_trim_bytes = (trim_mb.is_empty() ? 4u : (uint32_t)MAX(0, trim_mb.to_int())) * 1024u * 1024u;\n"
              "\t\ttransfer_worker_log = OS::get_singleton()->get_environment(\"GTAI_TW_LOG\") == \"1\";\n"
              "\t}\n", 1)
open(p, 'w', encoding='utf-8', newline='').write(s)
print('ok')
