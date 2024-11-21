#include "defs.h"
#include "string.h"
#include "mm.h"
#include "proc.h"
#include "printk.h"


/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));//8字节*512=4KiB（页表大小）

void setup_vm() {
    /* 
     * 1. 由于是进行 1GiB 的映射，这里不需要使用多级页表 
     * 2. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index(512)
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
   
    //将early_pgtbl清零
    memset(early_pgtbl,0,PGSIZE);
    int index;
    //得到PHY_START->VM_START的index值(等值映射)
    index = PHY_START >> 30 & 0x1ff;//中间9bit作index
    //从PHY_START得到PPN[2]的值放入early_pgtbl[index]中，且后四位设为1
    early_pgtbl[index] = ((PHY_START >> 30) << 28) | 0xf;

    //映射到 direct mapping area
    index = VM_START >> 30 & 0x1ff;
    early_pgtbl[index] = ((PHY_START >> 30) << 28) | 0xf; 
    printk("setup_vm done!\n");
}

/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

extern void _stext();
extern void _etext();
extern void _srodata();
extern void _erodata();
extern void _sdata();

void setup_vm_final() {
    printk("setup_vm_final start!\n");
    memset(swapper_pg_dir, 0x0, PGSIZE);
    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir, (uint64_t)_stext, (uint64_t)_stext - PA2VA_OFFSET, (uint64_t)_etext - (uint64_t)_stext,11);

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir, (uint64_t)_srodata, (uint64_t)_srodata - PA2VA_OFFSET, (uint64_t)_erodata - (uint64_t)_srodata, 3);

    // mapping other memory -|W|R|V
    create_mapping(swapper_pg_dir, (uint64_t)_sdata, (uint64_t)_sdata - PA2VA_OFFSET, PHY_SIZE - (uint64_t)_srodata + (uint64_t)_stext, 7);

    // set satp with swapper_pg_dir
    
    // YOUR CODE HERE
    
    /*# PPN
    la t1, early_pgtbl # VA of early_pgtbl
    sub t1, t1, t0 # PA of early_pgtbl
    srli t1, t1, 12 # PPN=PA>>12
    # ASID=0
    # MODE=8 (Sv39)
    addi t0, x0, 1
    li t2, 63
    sll t0, t0, t2
    or t1, t1, t0
    csrw satp, t1*/
    uint64_t satpswapper = (((uint64_t)swapper_pg_dir - PA2VA_OFFSET) >> 12) | (0x8000000000000000);
    csr_write(satp, satpswapper);


    // flush TLB
    asm volatile("sfence.vma zero, zero");
    printk("setup_vm_final done!\n");
    return;
}


/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
    /*
     * pgtbl 为根页表的基地址
     * va, pa 为需要映射的虚拟地址、物理地址
     * sz 为映射的大小，单位为字节
     * perm 为映射的权限（即页表项的低 8 位）
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/

    // 确认映射的范围
    uint64_t end = va + sz;
    while (va < end) 
    {
        uint64_t *table;

        // get vpn[2]
        uint64_t vpn2 = ((va)>>30) & 0x1ff;
        //not valid, alloc a new page
        if ((pgtbl[vpn2] & 1) == 0) 
        {
            uint64_t newpage = (uint64_t)kalloc();
            //newpage是虚拟地址，减去PA2VA_OFFSET得到物理地址，右移12位得到PPN，左移10位得到页表项
            pgtbl[vpn2] = ((((uint64_t)newpage - PA2VA_OFFSET) >> 12) << 10) | 1;//valid=1
        }
        //pgtbl[vpn2]得到下一级页表，右移10位左移12位得到物理地址，加上PA2VA_OFFSET得到下一级页表的基虚拟地址
        table = (uint64_t*)(((pgtbl[vpn2] >> 10) << 12) + PA2VA_OFFSET);

        // vpn1
        uint64_t vpn1 = ((va)>>21) & 0x1ff;
        if ((table[vpn1] & 1) == 0) 
        {
            uint64_t newpage = (uint64_t)kalloc();
            table[vpn1] = ((((uint64_t)newpage - PA2VA_OFFSET) >> 12) << 10) | 1;
        }
        table = (uint64_t*)(((table[vpn1] >> 10) << 12) + PA2VA_OFFSET);

        // vpn0，不用检查有效性
        uint64_t vpn0 = ((va)>>12) & 0x1ff;
        table[vpn0] = ((pa >> 12) << 10) | perm | 1;

        va += PGSIZE;
        pa += PGSIZE;
    }
}