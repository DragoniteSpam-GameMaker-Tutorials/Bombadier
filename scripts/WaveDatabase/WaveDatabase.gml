function DefineAllWaves(queue) {
    ds_queue_clear(queue);
    ds_queue_enqueue(queue,
        new Wave(foe_ant,            8, 1, 1),
        new Wave(foe_pillbugs,       8, 1, 1),
        new Wave(foe_aphid,         25, 1, 4),
        new Wave(foe_ant,           10, 3, 1),
        new Wave(foe_grasshopper,    4, 3, 0.5),
        
        new Wave(foe_gnat,          30, 3, 2),
        new Wave(foe_aphid,         40, 5, 4),
        new Wave(foe_ant,           12, 5, 1),
        new Wave(foe_ant,           12, 6, 1),
        new Wave(foe_grasshopper,    4, 6, 0.5),
        
        new Wave(foe_ant,           10, 6, 1),
        new Wave(foe_aphid,         15, 6, 4),
        new Wave(foe_gnat,          30, 7, 2),
        new Wave(foe_ant,           10, 8, 1),
        new Wave(foe_pillbugs,      12, 8, 1),
        new Wave(foe_grasshopper,    6, 10, 0.3),
    );
}