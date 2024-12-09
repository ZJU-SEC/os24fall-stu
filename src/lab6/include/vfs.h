#ifndef __VFS_H__
#define __VFS_H__

int64_t stdout_write(struct file *file, const void *buf, uint64_t len);
int64_t stderr_write(struct file *file, const void *buf, uint64_t len);
int64_t stdin_read(struct file *file, void *buf, uint64_t len);

#endif