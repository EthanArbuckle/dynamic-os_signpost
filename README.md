### Dynamic-Signpost

Emits `os_signpost` intervals and events with **runtime strings**—not just compile-time literals.

#### Why?
You might want to tag signposts with data discovered or generated at runtime (e.g., user-provided filenames, loop counters, etc.). Apple’s standard macros require compile-time strings; this project provides a way to use runtime strings.


### Demonstrating Apple's Limitation

**Apple's `os_signpost_interval_begin`**:

```
for (int i = 0; i < 5; i++) {
    // Build a dynamic name for the signpost
    NSString *dynamicName = [NSString stringWithFormat:@"pass_%d", i];

    // Attempt to use the dynamic name will cause a compile-time error
    os_signpost_interval_begin(get_signpost_log(), os_signpost_id_generate(get_signpost_log()), dynamicName.UTF8String, "Foo");
}
```

**`dyn_os_signpost_interval_begin:`**

```
for (int i = 0; i < 5; i++) {
    // Build a dynamic name for the signpost
    NSString *dynamicName = [NSString stringWithFormat:@"pass_%d", i];

    // Use the dynamic name with Dynamic-Signpost
    dyn_os_signpost_interval_begin(get_signpost_log(), os_signpost_id_generate(get_signpost_log()), dynamicName.UTF8String, "Foo");

    // <...> Do some work

    dyn_os_signpost_interval_end(log, spid, dynamicName.UTF8String, "Another: %@", @"HelloSignpost");
}
```

### Usage Examples

#### Block-Based Signpost

Wrap a block with `EXECUTE_WITH_SIGNPOST` to emit a signpost interval with a dynamic or static/hardcoded names.

```
NSString *signpostName = [@"Dynamic" stringByAppendingString:@"Signpost"];
EXECUTE_WITH_SIGNPOST(signpostName.UTF8String, ^{
    NSLog(@"Foo");
});
```

#### Manual Begin/End Signpost

Use `dyn_os_signpost_interval_begin` and `dyn_os_signpost_interval_end` to emit a signpost interval with dynamic names.

```
NSString *dynamicName = [NSString stringWithFormat:@"pass_%d", i];
```

```
dyn_os_signpost_interval_begin(get_signpost_log(), os_signpost_id_generate(get_signpost_log()), dynamicName.UTF8String, "Foo");
```
```
dyn_os_signpost_interval_begin(get_signpost_log(), os_signpost_id_generate(get_signpost_log()), dynamicName.UTF8String, "Another: %@", @"HelloSignpost");
```