#ifndef __FS_H__
#define __FS_H__

#include "defs.h"

#define MAX_PATH_LENGTH 80
#define MAX_FILE_NUMBER 16

#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

#define ERROR_FILE_NOT_OPEN 255

#define FILE_READABLE 0x1
#define FILE_WRITABLE 0x2

#define FS_TYPE_FAT32 0x1
#define FS_TYPE_EXT2  0x2

struct fat32_dir {
    uint32_t cluster;
    uint32_t index;     // entry index in the cluster
};

struct fat32_file {
    uint32_t cluster;
    struct fat32_dir dir;
};

struct file {   // Opened file in a thread.
    uint32_t opened;
    uint32_t perms;
    int64_t cfo;
    uint32_t fs_type;

    union {
        struct fat32_file fat32_file;
    };

    int64_t (*lseek) (struct file *file, int64_t offset, uint64_t whence);
    int64_t (*write) (struct file *file, const void *buf, uint64_t len);
    int64_t (*read)  (struct file *file, void *buf, uint64_t len);

    char path[MAX_PATH_LENGTH];
};

struct files_struct {
    struct file fd_array[MAX_FILE_NUMBER];
};

struct files_struct *file_init();
int32_t file_open(struct file *file, const char *path, int flags);
uint32_t get_fs_type(const char *filename);

#endif