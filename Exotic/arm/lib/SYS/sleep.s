.IFNDEF SLEEP
.EQU SLEEP,1

///////////////////////////////////////////////////////////////////////////////

// void _sleep(struct timespec* req, struct timespec* rem)
// Suspends execution for the time specified in {req}.
// {rem} receives the remaining time if interrupted by a signal (can be NULL).
// timespec layout:
//   offset 0x00 (8 bytes) — tv_sec:  seconds
//   offset 0x08 (8 bytes) — tv_nsec: nanoseconds (0 to 999999999)
// struct timespec {
//     int64_t tv_sec;   // segundos
//     int64_t tv_nsec;  // nanosegundos (0 a 999999999)
// };
// @param req X0 — pointer to timespec specifying sleep duration
// @param rem X1 — pointer to timespec for remaining time, or NULL (0)
// @return X0 — 0 on success, negative errno on failure (e.g. -EINTR if interrupted)
.MACRO _sleep

	mov x8, #101
	SVC #0

.ENDM

.ENDIF
