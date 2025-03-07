//
//  dynsignpost.h
//  dynamic-signpost
//
//  Created by Ethan Arbuckle on 3/6/25.
//

#import <Foundation/Foundation.h>
#import <os/signpost.h>
#import <os/log.h>

#ifdef __cplusplus
extern "C" {
#endif

extern os_log_t get_signpost_log(void);

#ifdef __cplusplus
} // extern "C"
#endif

// Decide if signposts are enabled, with consideration for unit testing
#ifndef UNIT_TESTING_SIGNPOST
  #define UNIT_TESTING_SIGNPOST 0
#endif

#ifndef SIGNPOSTS_ENABLED
  // Signposts default to enabled unless otherwise specified
  #define SIGNPOSTS_ENABLED 1
#endif

// When unit testing, make sure signposts are enabled
#if UNIT_TESTING_SIGNPOST
  #undef SIGNPOSTS_ENABLED
  #define SIGNPOSTS_ENABLED 1
#endif


#if SIGNPOSTS_ENABLED

// __builtin_os_log_format_buffer_size and __builtin_os_log_format are compiler builtins
// that can build dynamic strings for signposts at runtime
#ifndef dyn_os_signpost_emit_with_name_impl
#define dyn_os_signpost_emit_with_name_impl(log, type, spid, name, format, ...) \
    if (os_signpost_enabled(log)) { \
        uint8_t _os_fmt_buf[__builtin_os_log_format_buffer_size(format)]; \
        _os_signpost_emit_with_name_impl(&__dso_handle,                  \
                                         log,                            \
                                         type,                           \
                                         spid,                           \
                                         name,                           \
                                         format,                         \
                                         (uint8_t *)__builtin_os_log_format(_os_fmt_buf, format, ##__VA_ARGS__), \
                                         (uint32_t)sizeof(_os_fmt_buf)); \
    }
#endif

#else // SIGNPOSTS_ENABLED == 0

// No-op if signposts are disabled
#ifndef dyn_os_signpost_emit_with_name_impl
#define dyn_os_signpost_emit_with_name_impl(log, type, spid, name, format, ...)
#endif

#endif // SIGNPOSTS_ENABLED


#ifdef UNIT_TESTING_SIGNPOST

// For unit tests, redefine the emit macro to call a mock function that captures the emitted signposts
#undef dyn_os_signpost_emit_with_name_impl
#define dyn_os_signpost_emit_with_name_impl(log, type, spid, name, format, ...) \
    if (os_signpost_enabled(log)) { \
        uint8_t _os_fmt_buf[__builtin_os_log_format_buffer_size(format)]; \
        uint8_t *compiledBuf = (uint8_t *)__builtin_os_log_format(_os_fmt_buf, format, ##__VA_ARGS__); \
        mock_signpost_emit(&__dso_handle, log, type, spid, name, format, compiledBuf, (uint32_t)sizeof(_os_fmt_buf)); \
    }

void mock_signpost_emit(void *dso, os_log_t log, os_signpost_type_t type, os_signpost_id_t spid, const char *name, const char *format, uint8_t *buffer, uint32_t bufsize);

NSArray<NSString *> *SignpostTestUtils_CapturedMessages(void);
void SignpostTestUtils_PurgeMessages(void);

#endif // UNIT_TESTING_SIGNPOST


#define dyn_os_signpost_emit_with_type(log, type, spid, name, format, ...) \
    dyn_os_signpost_emit_with_name_impl(log, type, spid, name, format, ##__VA_ARGS__)

#define dyn_os_signpost_interval_begin(log, spid, name, format, ...) \
    dyn_os_signpost_emit_with_type(log, OS_SIGNPOST_INTERVAL_BEGIN, spid, name, format, ##__VA_ARGS__)

#define dyn_os_signpost_interval_end(log, spid, name, format, ...) \
    dyn_os_signpost_emit_with_type(log, OS_SIGNPOST_INTERVAL_END, spid, name, format, ##__VA_ARGS__)


#if SIGNPOSTS_ENABLED

// Execute a block with a signpost interval around it. Name can be static or dynamic (i.e. constructed at runtime)
#define EXECUTE_WITH_SIGNPOST(name_str, block) do { \
    os_log_t mp_signpost_log = get_signpost_log(); \
    os_signpost_id_t signpost_id = os_signpost_id_generate(mp_signpost_log); \
    dyn_os_signpost_interval_begin(mp_signpost_log, signpost_id, name_str, ""); \
    block(); \
    dyn_os_signpost_interval_end(mp_signpost_log, signpost_id, name_str, ""); \
} while (0)

// Begin a signpost interval
#define SIGNPOST_BEGIN(name_str) \
    do { \
        os_log_t mp_signpost_log = get_signpost_log(); \
        os_signpost_id_t signpost_id = os_signpost_id_generate(mp_signpost_log); \
        dyn_os_signpost_interval_begin(mp_signpost_log, signpost_id, name_str, ""); \
    } while (0)

// End a signpost interval
#define SIGNPOST_END(name_str) \
    do { \
        os_log_t mp_signpost_log = get_signpost_log(); \
        os_signpost_id_t signpost_id = os_signpost_id_generate(mp_signpost_log); \
        dyn_os_signpost_interval_end(mp_signpost_log, signpost_id, name_str, ""); \
    } while (0)

#else // SIGNPOSTS_ENABLED == 0

// No-op if signposts are disabled
#define EXECUTE_WITH_SIGNPOST(name_str, block) block()
#define SIGNPOST_BEGIN(name_str)
#define SIGNPOST_END(name_str)

#endif // SIGNPOSTS_ENABLED
