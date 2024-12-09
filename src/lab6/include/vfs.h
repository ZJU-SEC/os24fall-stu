#ifndef _VFS_H
#define _VFS_H

int64_t stdout_write(struct file* file, const void* buf, uint64_t len);
int64_t stderr_write(struct file* file, const void* buf, uint64_t len);
int64_t stdin_read(struct file* file, void* buf, uint64_t len);
uint32_t get_fs_type(const char* filename);

#endif