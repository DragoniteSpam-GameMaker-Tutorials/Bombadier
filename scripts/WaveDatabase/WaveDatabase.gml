function DefineAllWaves(queue) {
    ds_queue_clear(queue);
    ds_queue_enqueue(queue,
        new Wave(foe_ant,            8, 1, 1),
        new Wave(foe_pillbugs,       8, 1, 1),
        new Wave(foe_aphid,         40, 1, 4),
        new Wave(foe_ant,           10, 3, 1),
        new Wave(foe_grasshopper,    4, 3, 0.5),
        new Wave(foe_gnat,          60, 3, 2),
        new Wave(foe_aphid,         60, 6, 4),
        new Wave(foe_grasshopper,    4, 5, 0.5),
    );
}