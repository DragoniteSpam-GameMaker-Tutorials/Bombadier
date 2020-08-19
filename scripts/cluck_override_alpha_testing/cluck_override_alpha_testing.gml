#macro gpu_set_alphatestref __override_cluck_set_alpha_ref
#macro __legacy_gpu_set_alphatestref gpu_set_alphatestref

function __override_cluck_set_alpha_ref(alpha_ref) {
    cluck_set_alpha_ref(alpha_ref);
    __legacy_gpu_set_alphatestref(alpha_ref);
}

#macro gpu_set_alphatestenable __override_cluck_set_alpha_test_enable
#macro __legacy_gpu_set_alphatestenable gpu_set_alphatestenable

function __override_cluck_set_alpha_test_enable(test_enabled) {
    cluck_set_alpha_ref(test_enabled);
    __legacy_gpu_set_alphatestenable(test_enabled);
}