function approach(value, target, step) {
    return value + clamp(target - value, -step, step);
};