#include <stdio.h> 
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
//#include <sys/types.h>
//#include <sys/sysmacros.h>

#define STRINGIF(x) XSTR(x)
#define XSTR(x)      #x
#define STRINGLENGTH 100
#define DUMP(...) \
    do { \
        char debugtempobuffer[STRINGLENGTH]; \
        char debug2tempobuffer[STRINGLENGTH]; \
        sprintf(debugtempobuffer, __VA_ARGS__); \
        sprintf(debug2tempobuffer,"%s",STRINGIF((__VA_ARGS__))); \
        printf("%s : %s : %d\n",debugtempobuffer,debug2tempobuffer,__LINE__); \
    } while (0);

#define DUMPA(expr) \
  DUMP("%Lx",expr)

#define PERMS_READ               1U
#define PERMS_WRITE              2U
#define PERMS_EXEC               4U
#define PERMS_SHARED             8U
#define PERMS_PRIVATE           16U

typedef struct address_range address_range;
struct address_range {
    struct address_range    *next;
    void                    *start;
    void                    *end;
//    unsigned long            offset;
//    dev_t                    device;
//    ino_t                    inode;
    unsigned char            perms;
    char                     name[];
};

void free_mem_stats(address_range *list)
{
    while (list) {
        address_range *curr = list;

        list = list->next;

        curr->next = NULL;
        curr->end = NULL;
        curr->perms = 0U;
        curr->name[0] = '\0';

        free(curr);
    }
}

address_range *mem_stats(int pid)
{
    address_range *list = NULL;
    char          *line = NULL;
    size_t         size = 0;
    FILE          *maps;

    if (pid > 0) {
        char namebuf[128];
        int  namelen;

        namelen = snprintf(namebuf, sizeof namebuf, "/proc/%ld/maps", (long)pid);
        if (namelen < 12) {
            errno = EINVAL;
            return NULL;
        }

        maps = fopen(namebuf, "r");
    } else
        maps = fopen("/proc/self/maps", "r");

    if (!maps)
        return NULL;

    while (getline(&line, &size, maps) > 0) {
        address_range *curr;
        char           perms[8];
        unsigned int   devmajor, devminor;
        unsigned long  addr_start, addr_end;
        unsigned long  offset, inode;
        int            name_start = 0;
        int            name_end = 0;

        if (sscanf(line, "%lx-%lx %7s %lx %u:%u %lu %n%*[^\n]%n",
                         &addr_start, &addr_end, perms, &offset,
                         &devmajor, &devminor, &inode,
                         &name_start, &name_end) < 7) {
            fclose(maps);
            free(line);
            free_mem_stats(list);
            errno = EIO;
            return NULL;
        }

        if (name_end <= name_start)
            name_start = name_end = 0;

        curr = malloc(sizeof (address_range) + (size_t)(name_end - name_start) + 1);
        if (!curr) {
            fclose(maps);
            free(line);
            free_mem_stats(list);
            errno = ENOMEM;
            return NULL;
        }

        if (name_end > name_start)
            memcpy(curr->name, line + name_start, name_end - name_start);
        curr->name[name_end - name_start] = '\0';

        curr->start = (void *)addr_start;
        curr->end = (void *)addr_end;
//        curr->offset = offset;
//        curr->device = makedev(devmajor, devminor);
//        curr->inode = (ino_t)inode;

        curr->perms = 0U;
        if (strchr(perms, 'r'))
            curr->perms |= PERMS_READ;
        if (strchr(perms, 'w'))
            curr->perms |= PERMS_WRITE;
        if (strchr(perms, 'x'))
            curr->perms |= PERMS_EXEC;
        if (strchr(perms, 's'))
            curr->perms |= PERMS_SHARED;
        if (strchr(perms, 'p'))
            curr->perms |= PERMS_PRIVATE;

        curr->next = list;
        list = curr;
    }

    free(line);

    if (!feof(maps) || ferror(maps)) {
        fclose(maps);
        free_mem_stats(list);
        errno = EIO;
        return NULL;
    }
    if (fclose(maps)) {
        free_mem_stats(list);
        errno = EIO;
        return NULL;
    }

    errno = 0;
    return list;
}

address_range *get_address_range(address_range *list,const void * const ptr) {

    address_range *curr;

    for (curr = list; curr != NULL; curr = curr->next)
        if ( (ptr > curr->start) && (ptr < curr->end) ) {
            return curr ;
        }
    return NULL;
}

const int my_const = 1;
int my_data = 1;
int my_bss ;
__thread int my_tdata = 1;
__thread int my_tbss ;

static address_range *list;

address_range *get_curr(const void * const ptr, char *ptrname) {
    address_range *curr = get_address_range(list,ptr);
//    printf("%lx-%lu %lx-%lu %s\n",(unsigned long)curr->start,(unsigned long)curr->start,(unsigned long)curr->end,(unsigned long)curr->end,curr->name);
//    printf("\t %s:%lx-%lu \n",ptrname,(unsigned long)ptr,(unsigned long)ptr);
    return curr;
}

#define CURR(_var) \
    get_curr(_var,STRINGIF(_var))

#include <stdint.h>
uintptr_t my___executable_start;
uintptr_t my_end;
uintptr_t tls_start;
uintptr_t tls_end;
uintptr_t my_stack_start;
int prepare_memory(JNIEnv *env,jobject jobj)
{
    int pid = getpid();
    list = mem_stats(pid);
    if (!list) {
        fprintf(stderr, "Cannot obtain memory usage of process %d: %s.\n", pid, strerror(errno));
        return EXIT_FAILURE;
    }

    my___executable_start = (uintptr_t) CURR(&prepare_memory)->start;
    my_end = (uintptr_t) CURR(&my_bss)->end;
    tls_start = (uintptr_t) CURR(&my_tdata)->start;
    tls_end = (uintptr_t) CURR(&my_tbss)->end;
    my_stack_start = (uintptr_t) CURR(&pid)->start;

    Java_org_contikios_cooja_corecomm_Lib1_init(env,jobj);
//    main();
//
//    free_mem_stats(list);
    return EXIT_SUCCESS;
}
